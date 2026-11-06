/*
 * Protein conformational transitions calculations tutorial using BioExcel Building Blocks (biobb) and GOdMD
 * Nextflow version of biobb_wf_godmd/python/workflow.py, with the BioBB Nextflow modules in modules/.
 * Ported by hand: nextflow_wf_generator.py can't translate the python logic of workflow.py (step2 and step3 only run
 * when their molecules property is not empty). Regenerating it only refreshes the modules.
 * Usage: nextflow run main.nf -profile docker [--input samplesheet.csv] [-params-file molecules.yml]
 */

include { BIOBB_STRUCTURE_UTILS_EXTRACT_CHAIN as STEP0_EXTRACT_CHAIN } from './modules/bioexcel/biobb_structure_utils/extract_chain'
include { BIOBB_STRUCTURE_UTILS_EXTRACT_CHAIN as STEP1_EXTRACT_CHAIN } from './modules/bioexcel/biobb_structure_utils/extract_chain'
include { BIOBB_STRUCTURE_UTILS_REMOVE_MOLECULES as STEP2_REMOVE_MOLECULES } from './modules/bioexcel/biobb_structure_utils/remove_molecules'
include { BIOBB_STRUCTURE_UTILS_REMOVE_MOLECULES as STEP3_REMOVE_MOLECULES } from './modules/bioexcel/biobb_structure_utils/remove_molecules'
include { BIOBB_GODMD_GODMD_PREP as STEP4_GODMD_PREP } from './modules/bioexcel/biobb_godmd/godmd_prep'
include { BIOBB_GODMD_GODMD_RUN as STEP5_GODMD_RUN } from './modules/bioexcel/biobb_godmd/godmd_run'
include { BIOBB_ANALYSIS_CPPTRAJ_CONVERT as STEP6_CPPTRAJ_CONVERT } from './modules/bioexcel/biobb_analysis/cpptraj_convert'

params {
    // CSV with an id column and one column per input file: one workflow run per row
    input: String = "${projectDir}/samplesheet.csv"
    // molecules property of step2 (origin) and step3 (target): the step is skipped when it is empty, as in the python workflow
    step2_molecules: List = [[name: 'AP5']]
    step3_molecules: List = []
}

workflow {
    main:
    // One [meta, files] item per samplesheet row: the steps of every row run in parallel
    ch_samples = channel.fromPath(params.input)
        .splitCsv(header: true)
        .map { row -> [[id: row.id], [origin: samplePath(row.origin), target: samplePath(row.target)]] }

    // step0_extract_chain: Extracting the interesting chains from the origin structure
    STEP0_EXTRACT_CHAIN(ch_samples.map { meta, files -> [meta, files.origin] })
    // step1_extract_chain: Extracting the interesting chains from the target structure
    STEP1_EXTRACT_CHAIN(ch_samples.map { meta, files -> [meta, files.target] })
    // step2_remove_molecules: Removing the inhibitor from the closed conformation (origin)
    STEP2_REMOVE_MOLECULES(STEP0_EXTRACT_CHAIN.out.output_structure_path.filter { params.step2_molecules })
    // step3_remove_molecules: Removing the inhibitor from the closed conformation (target)
    STEP3_REMOVE_MOLECULES(STEP1_EXTRACT_CHAIN.out.output_structure_path.filter { params.step3_molecules })
    // Without molecules to remove, step4 and step5 take the chains extracted by step0 / step1
    ch_origin = params.step2_molecules ? STEP2_REMOVE_MOLECULES.out.output_molecules_path : STEP0_EXTRACT_CHAIN.out.output_structure_path
    ch_target = params.step3_molecules ? STEP3_REMOVE_MOLECULES.out.output_molecules_path : STEP1_EXTRACT_CHAIN.out.output_structure_path
    // step4_godmd_prep: Computing the mapping
    STEP4_GODMD_PREP(
        ch_origin
            .join(ch_target)
    )
    // step5_godmd_run: Running GOdMD
    STEP5_GODMD_RUN(
        ch_origin
            .join(ch_target)
            .join(STEP4_GODMD_PREP.out.output_aln_orig_path)
            .join(STEP4_GODMD_PREP.out.output_aln_target_path)
            .map { meta, pdb_orig, pdb_target, aln_orig, aln_target -> [meta, pdb_orig, pdb_target, aln_orig, aln_target, []] }
    )
    // step6_cpptraj_convert: Converting trajectory to DCD
    STEP6_CPPTRAJ_CONVERT(
        STEP5_GODMD_RUN.out.output_pdb_path
            .join(STEP5_GODMD_RUN.out.output_pdb_path)
    )

    publish:
    results = channel.empty().mix(
        STEP0_EXTRACT_CHAIN.out.output_structure_path.map { meta, result -> [meta, 'step0_extract_chain', result] },
        STEP1_EXTRACT_CHAIN.out.output_structure_path.map { meta, result -> [meta, 'step1_extract_chain', result] },
        STEP2_REMOVE_MOLECULES.out.output_molecules_path.map { meta, result -> [meta, 'step2_remove_molecules', result] },
        STEP3_REMOVE_MOLECULES.out.output_molecules_path.map { meta, result -> [meta, 'step3_remove_molecules', result] },
        STEP4_GODMD_PREP.out.output_aln_orig_path.mix(STEP4_GODMD_PREP.out.output_aln_target_path).map { meta, result -> [meta, 'step4_godmd_prep', result] },
        STEP5_GODMD_RUN.out.output_log_path.mix(STEP5_GODMD_RUN.out.output_ene_path, STEP5_GODMD_RUN.out.output_trj_path, STEP5_GODMD_RUN.out.output_pdb_path).map { meta, result -> [meta, 'step5_godmd_run', result] },
        STEP6_CPPTRAJ_CONVERT.out.output_cpptraj_path.map { meta, result -> [meta, 'step6_cpptraj_convert', result] }
    )
}

output {
    // results/<id>/<step>/<id>_<step>_<role>.<ext>
    results {
        path { meta, step, _result -> "${meta.id}/${step}" }
    }
}

// Path of a samplesheet column: absolute, or relative to the samplesheet folder
def samplePath(String value) {
    file(file(params.input).parent.resolve(value).toString(), checkIfExists: true)
}
