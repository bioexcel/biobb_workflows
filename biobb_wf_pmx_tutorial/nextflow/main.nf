/*
 * Mutation Free Energy Calculations using BioExcel Building Blocks (biobb)
 * Nextflow version of biobb_wf_pmx_tutorial/python/workflow.py, with the BioBB Nextflow modules in modules/.
 * Ported by hand: nextflow_wf_generator.py can't translate the python logic of workflow.py (loops over the states and
 * over the frames extracted from their trajectories, energy minimization only in stateB, zips of the dhdl files,
 * GMXLIB of the conda env). Regenerating it only refreshes the modules.
 * Usage: nextflow run main.nf -profile docker [--input samplesheet.csv] [--stateA_mutation <mutation>] [--stateB_mutation <mutation>]
 */

include { BIOBB_ANALYSIS_GMX_TRJCONV_STR_ENS as STEP0_TRJCONV } from './modules/bioexcel/biobb_analysis/gmx_trjconv_str_ens'
include { BIOBB_PMX_PMXMUTATE as STEP1_PMX_MUTATE } from './modules/bioexcel/biobb_pmx/pmxmutate'
include { BIOBB_GROMACS_PDB2GMX as STEP2_GMX_PDB2GMX } from './modules/bioexcel/biobb_gromacs/pdb2gmx'
include { BIOBB_PMX_PMXGENTOP as STEP3_PMX_GENTOP } from './modules/bioexcel/biobb_pmx/pmxgentop'
include { BIOBB_GROMACS_MAKE_NDX as STEP4_GMX_MAKENDX } from './modules/bioexcel/biobb_gromacs/make_ndx'
include { BIOBB_GROMACS_GROMPP as STEP5_GMX_GROMPP } from './modules/bioexcel/biobb_gromacs/grompp'
include { BIOBB_GROMACS_MDRUN as STEP6_GMX_MDRUN } from './modules/bioexcel/biobb_gromacs/mdrun'
include { BIOBB_GROMACS_GROMPP as STEP7_GMX_GROMPP } from './modules/bioexcel/biobb_gromacs/grompp'
include { BIOBB_GROMACS_MDRUN as STEP8_GMX_MDRUN } from './modules/bioexcel/biobb_gromacs/mdrun'
include { BIOBB_GROMACS_GROMPP as STEP9_GMX_GROMPP } from './modules/bioexcel/biobb_gromacs/grompp'
include { BIOBB_GROMACS_MDRUN as STEP10_GMX_MDRUN } from './modules/bioexcel/biobb_gromacs/mdrun'
include { BIOBB_PMX_PMXANALYSE as STEP11_PMX_ANALYSE } from './modules/bioexcel/biobb_pmx/pmxanalyse'
// Python logic of workflow.py
include { UNZIP as UNZIP_FRAMES } from './modules/local/unzip'
include { ZIP as ZIP_DHDL } from './modules/local/zip'

params {
    // CSV with an id column and the tpr and trajectory of both states: one workflow run per row
    input: String = "${projectDir}/samplesheet.csv"
    // Mutation of every frame of each state (mutations global property of the python workflow)
    stateA_mutation: String = '10Ala'
    stateB_mutation: String = '10Ile'
}

workflow {
    main:
    // One [meta, files] item per samplesheet row: the steps of every row run in parallel
    ch_samples = channel.fromPath(params.input)
        .splitCsv(header: true)
        .map { row -> [[id: row.id], [stateA_tpr: samplePath(row.stateA_tpr), stateA_traj: samplePath(row.stateA_traj), stateB_tpr: samplePath(row.stateB_tpr), stateB_traj: samplePath(row.stateB_traj)]] }
    // One item per state of the python loop, with its mutation
    ch_states = ch_samples.flatMap { meta, files ->
        [stateA: params.stateA_mutation, stateB: params.stateB_mutation].collect { state, mutation ->
            [meta + [state: state, mutation: mutation], files["${state}_traj".toString()], files["${state}_tpr".toString()]]
        }
    }

    // step0_trjconv: Extract snapshots from equilibrium trajectories
    STEP0_TRJCONV(ch_states.map { meta, traj, tpr -> [meta, traj, tpr, []] })
    // Frames of every state (python loop over the extracted PDB files), with the pmx force field folder (GMXLIB of the GROMACS steps)
    UNZIP_FRAMES(STEP0_TRJCONV.out.output_str_ens_path)
    MUTFF()
    ch_frames = UNZIP_FRAMES.out.files
        .flatMap { meta, frames -> [frames].flatten().collect { frame -> [meta + [frame: frame.baseName], frame] } }
        .combine(MUTFF.out.mutff)
        .map { meta, frame, mutff -> [meta + [gmx_lib: mutff.toString()], frame] }

    // step1_pmx_mutate: Generate Hybrid Structure
    STEP1_PMX_MUTATE(ch_frames.map { meta, frame -> [meta, frame, []] })
    // step2_gmx_pdb2gmx: Generate Topology
    STEP2_GMX_PDB2GMX(STEP1_PMX_MUTATE.out.output_structure_path)
    // step3_pmx_gentop: Generate Hybrid Topology
    STEP3_PMX_GENTOP(STEP2_GMX_PDB2GMX.out.output_top_zip_path)
    // step4_gmx_makendx: Generate Gromacs Index file to select atoms to freeze
    STEP4_GMX_MAKENDX(
        STEP2_GMX_PDB2GMX.out.output_gro_path
            .map { meta, structure -> [meta, structure, []] }
    )
    // step5_gmx_grompp: Creating portable binary run file for energy minimization (stateB only)
    STEP5_GMX_GROMPP(
        STEP2_GMX_PDB2GMX.out.output_gro_path
            .filter { meta, _gro -> meta.state == 'stateB' }
            .join(STEP3_PMX_GENTOP.out.output_top_zip_path)
            .join(STEP4_GMX_MAKENDX.out.output_ndx_path)
            .map { meta, gro, top_zip, ndx -> [meta, gro, top_zip, [], ndx, []] }
    )
    // step6_gmx_mdrun: Running energy minimization (stateB only)
    STEP6_GMX_MDRUN(
        STEP5_GMX_GROMPP.out.output_tpr_path
            .map { meta, tpr -> [meta, tpr, []] }
    )
    // stateA has no dummies at lambda=0: no energy minimization, step7 takes the step2 structure
    ch_minimized = STEP2_GMX_PDB2GMX.out.output_gro_path
        .filter { meta, _gro -> meta.state == 'stateA' }
        .mix(STEP6_GMX_MDRUN.out.output_gro_path)
    // step7_gmx_grompp: Creating portable binary run file for system equilibration
    STEP7_GMX_GROMPP(
        ch_minimized
            .join(STEP3_PMX_GENTOP.out.output_top_zip_path)
            .join(STEP4_GMX_MAKENDX.out.output_ndx_path)
            .map { meta, gro, top_zip, ndx -> [meta, gro, top_zip, [], ndx, []] }
    )
    // step8_gmx_mdrun: Running system equilibration
    STEP8_GMX_MDRUN(
        STEP7_GMX_GROMPP.out.output_tpr_path
            .map { meta, tpr -> [meta, tpr, []] }
    )
    // step9_gmx_grompp: Creating portable binary run file for thermodynamic integration (ti)
    STEP9_GMX_GROMPP(
        STEP8_GMX_MDRUN.out.output_gro_path
            .join(STEP3_PMX_GENTOP.out.output_top_zip_path)
            .join(STEP4_GMX_MAKENDX.out.output_ndx_path)
            .map { meta, gro, top_zip, ndx -> [meta, gro, top_zip, [], ndx, []] }
    )
    // step10_gmx_mdrun: Running thermodynamic integration
    STEP10_GMX_MDRUN(
        STEP9_GMX_GROMPP.out.output_tpr_path
            .map { meta, tpr -> [meta, tpr, []] }
    )

    // Creating zip file containing all the dhdl files of each state, in frame order
    ZIP_DHDL(
        STEP10_GMX_MDRUN.out.output_dhdl_path
            .map { meta, dhdl -> [sampleMeta(meta) + [state: meta.state], [meta.frame, dhdl]] }
            .groupTuple()
            .map { meta, frame_dhdls -> [meta, frame_dhdls.sort { frame_dhdl -> frameNumber(frame_dhdl[0]) }.collect { frame_dhdl -> frame_dhdl[1] }] }
    )
    // step11_pmx_analyse: Calculate free energies from fast growth thermodynamic integration simulations
    STEP11_PMX_ANALYSE(
        ZIP_DHDL.out.zip
            .map { meta, zip -> [sampleMeta(meta), [meta.state, zip]] }
            .groupTuple(size: 2)
            .map { meta, state_zips -> [meta, state_zips.find { state_zip -> state_zip[0] == 'stateA' }[1], state_zips.find { state_zip -> state_zip[0] == 'stateB' }[1]] }
    )

    publish:
    results = channel.empty().mix(
        STEP0_TRJCONV.out.output_str_ens_path.map { meta, result -> [meta, 'step0_trjconv', result] },
        STEP1_PMX_MUTATE.out.output_structure_path.map { meta, result -> [meta, 'step1_pmx_mutate', result] },
        STEP2_GMX_PDB2GMX.out.output_gro_path.mix(STEP2_GMX_PDB2GMX.out.output_top_zip_path).map { meta, result -> [meta, 'step2_gmx_pdb2gmx', result] },
        STEP3_PMX_GENTOP.out.output_top_zip_path.map { meta, result -> [meta, 'step3_pmx_gentop', result] },
        STEP4_GMX_MAKENDX.out.output_ndx_path.map { meta, result -> [meta, 'step4_gmx_makendx', result] },
        STEP5_GMX_GROMPP.out.output_tpr_path.map { meta, result -> [meta, 'step5_gmx_grompp', result] },
        STEP6_GMX_MDRUN.out.output_gro_path.mix(STEP6_GMX_MDRUN.out.output_edr_path, STEP6_GMX_MDRUN.out.output_log_path, STEP6_GMX_MDRUN.out.output_trr_path).map { meta, result -> [meta, 'step6_gmx_mdrun', result] },
        STEP7_GMX_GROMPP.out.output_tpr_path.map { meta, result -> [meta, 'step7_gmx_grompp', result] },
        STEP8_GMX_MDRUN.out.output_gro_path.mix(STEP8_GMX_MDRUN.out.output_edr_path, STEP8_GMX_MDRUN.out.output_log_path, STEP8_GMX_MDRUN.out.output_trr_path).map { meta, result -> [meta, 'step8_gmx_mdrun', result] },
        STEP9_GMX_GROMPP.out.output_tpr_path.map { meta, result -> [meta, 'step9_gmx_grompp', result] },
        STEP10_GMX_MDRUN.out.output_gro_path.mix(STEP10_GMX_MDRUN.out.output_edr_path, STEP10_GMX_MDRUN.out.output_log_path, STEP10_GMX_MDRUN.out.output_trr_path, STEP10_GMX_MDRUN.out.output_dhdl_path).map { meta, result -> [meta, 'step10_gmx_mdrun', result] },
        ZIP_DHDL.out.zip.map { meta, result -> [sampleMeta(meta), 'step11_pmx_analyse', result] },
        STEP11_PMX_ANALYSE.out.output_result_path.mix(STEP11_PMX_ANALYSE.out.output_work_plot_path).map { meta, result -> [meta, 'step11_pmx_analyse', result] }
    )
}

output {
    // results/<id>/<state>/<frame>/<step>/<id>_<step>_<role>.<ext> for the steps of the python loops, results/<id>/<step>/ for the others
    results {
        path { meta, step, _result -> [meta.id, meta.state, meta.frame, step].findAll { value -> value }.join('/') }
    }
}

// Python logic of workflow.py: the pmx force field folder (pmx/data/mutff), the GMXLIB of pdb2gmx, grompp and the pmx blocks
process MUTFF {
    label 'process_single'

    conda 'bioconda::biobb_pmx=5.3.1'
    container "${workflow.containerEngine in ['singularity', 'apptainer'] && !task.ext.singularity_pull_docker_container
        ? 'https://depot.galaxyproject.org/singularity/biobb_pmx:5.3.1--pyhdfd78af_0'
        : 'quay.io/biocontainers/biobb_pmx:5.3.1--pyhdfd78af_0'}"

    output:
    path 'mutff', emit: mutff

    script:
    """
    #!/usr/bin/env python3
    import shutil
    from pathlib import Path

    import pmx

    shutil.copytree(Path(pmx.__file__).parent / 'data' / 'mutff', 'mutff')
    """

    stub:
    """
    mkdir mutff
    """
}

// Path of a samplesheet column: absolute, or relative to the samplesheet folder
def samplePath(String value) {
    file(file(params.input).parent.resolve(value).toString(), checkIfExists: true)
}

// Sample of an item of the state and frame loops
def sampleMeta(Map meta) {
    meta.findAll { key, _value -> !(key in ['state', 'mutation', 'frame', 'gmx_lib']) }
}

// Number of a frame<n> name, to sort the frames
def frameNumber(String frame) {
    frame.replaceAll(/\D/, '').toInteger()
}
