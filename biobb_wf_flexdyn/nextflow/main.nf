/*
 * Conformational ensembles generation, data representation and visualization of predicted flexibility properties using BioExcel Building Blocks (biobb) and FlexDyn tools
 * Nextflow version of biobb_wf_flexdyn/python/workflow.py, with the BioBB Nextflow modules in modules/.
 * Ported by hand: nextflow_wf_generator.py can't translate the python logic of workflow.py (zip of the ensembles
 * for step25_trjcat, CONCOORDLIB of the conda env). Regenerating it only refreshes the modules.
 * Usage: nextflow run main.nf -profile docker [--input samplesheet.csv]
 */

include { BIOBB_STRUCTURE_UTILS_EXTRACT_MODEL as STEP0_EXTRACT_MODEL } from './modules/bioexcel/biobb_structure_utils/extract_model'
include { BIOBB_STRUCTURE_UTILS_EXTRACT_CHAIN as STEP1_EXTRACT_CHAIN } from './modules/bioexcel/biobb_structure_utils/extract_chain'
include { BIOBB_ANALYSIS_CPPTRAJ_MASK as STEP2_CPPTRAJ_MASK } from './modules/bioexcel/biobb_analysis/cpptraj_mask'
include { BIOBB_ANALYSIS_CPPTRAJ_MASK as STEP3_CPPTRAJ_MASK } from './modules/bioexcel/biobb_analysis/cpptraj_mask'
include { BIOBB_FLEXDYN_CONCOORD_DIST as STEP4_CONCOORD_DIST } from './modules/bioexcel/biobb_flexdyn/concoord_dist'
include { BIOBB_FLEXDYN_CONCOORD_DISCO as STEP5_CONCOORD_DISCO } from './modules/bioexcel/biobb_flexdyn/concoord_disco'
include { BIOBB_ANALYSIS_CPPTRAJ_RMS as STEP6_CPPTRAJ_RMS } from './modules/bioexcel/biobb_analysis/cpptraj_rms'
include { BIOBB_ANALYSIS_CPPTRAJ_CONVERT as STEP7_CPPTRAJ_CONVERT } from './modules/bioexcel/biobb_analysis/cpptraj_convert'
include { BIOBB_FLEXDYN_PRODY_ANM as STEP8_PRODY_ANM } from './modules/bioexcel/biobb_flexdyn/prody_anm'
include { BIOBB_ANALYSIS_CPPTRAJ_RMS as STEP9_CPPTRAJ_RMS } from './modules/bioexcel/biobb_analysis/cpptraj_rms'
include { BIOBB_ANALYSIS_CPPTRAJ_CONVERT as STEP10_CPPTRAJ_CONVERT } from './modules/bioexcel/biobb_analysis/cpptraj_convert'
include { BIOBB_FLEXSERV_BD_RUN as STEP11_BD_RUN } from './modules/bioexcel/biobb_flexserv/bd_run'
include { BIOBB_ANALYSIS_CPPTRAJ_RMS as STEP12_CPPTRAJ_RMS } from './modules/bioexcel/biobb_analysis/cpptraj_rms'
include { BIOBB_FLEXSERV_DMD_RUN as STEP13_DMD_RUN } from './modules/bioexcel/biobb_flexserv/dmd_run'
include { BIOBB_ANALYSIS_CPPTRAJ_RMS as STEP14_CPPTRAJ_RMS } from './modules/bioexcel/biobb_analysis/cpptraj_rms'
include { BIOBB_FLEXSERV_NMA_RUN as STEP15_NMA_RUN } from './modules/bioexcel/biobb_flexserv/nma_run'
include { BIOBB_ANALYSIS_CPPTRAJ_RMS as STEP16_CPPTRAJ_RMS } from './modules/bioexcel/biobb_analysis/cpptraj_rms'
include { BIOBB_ANALYSIS_CPPTRAJ_CONVERT as STEP17_CPPTRAJ_CONVERT } from './modules/bioexcel/biobb_analysis/cpptraj_convert'
include { BIOBB_FLEXDYN_NOLB_NMA as STEP18_NOLB_NMA } from './modules/bioexcel/biobb_flexdyn/nolb_nma'
include { BIOBB_ANALYSIS_CPPTRAJ_RMS as STEP19_CPPTRAJ_RMS } from './modules/bioexcel/biobb_analysis/cpptraj_rms'
include { BIOBB_ANALYSIS_CPPTRAJ_CONVERT as STEP20_CPPTRAJ_CONVERT } from './modules/bioexcel/biobb_analysis/cpptraj_convert'
include { BIOBB_FLEXDYN_IMOD_IMODE as STEP21_IMOD_IMODE } from './modules/bioexcel/biobb_flexdyn/imod_imode'
include { BIOBB_FLEXDYN_IMOD_IMC as STEP22_IMOD_IMC } from './modules/bioexcel/biobb_flexdyn/imod_imc'
include { BIOBB_ANALYSIS_CPPTRAJ_RMS as STEP23_CPPTRAJ_RMS } from './modules/bioexcel/biobb_analysis/cpptraj_rms'
include { BIOBB_ANALYSIS_CPPTRAJ_CONVERT as STEP24_CPPTRAJ_CONVERT } from './modules/bioexcel/biobb_analysis/cpptraj_convert'
include { BIOBB_GROMACS_TRJCAT as STEP25_TRJCAT } from './modules/bioexcel/biobb_gromacs/trjcat'
include { BIOBB_GROMACS_MAKE_NDX as STEP26_MAKE_NDX } from './modules/bioexcel/biobb_gromacs/make_ndx'
include { BIOBB_ANALYSIS_GMX_CLUSTER as STEP27_GMX_CLUSTER } from './modules/bioexcel/biobb_analysis/gmx_cluster'
include { BIOBB_ANALYSIS_CPPTRAJ_RMS as STEP28_CPPTRAJ_RMS } from './modules/bioexcel/biobb_analysis/cpptraj_rms'
include { BIOBB_FLEXSERV_PCZ_ZIP as STEP29_PCZ_ZIP } from './modules/bioexcel/biobb_flexserv/pcz_zip'
include { BIOBB_FLEXSERV_PCZ_ZIP as STEP30_PCZ_ZIP } from './modules/bioexcel/biobb_flexserv/pcz_zip'
include { BIOBB_FLEXSERV_PCZ_INFO as STEP31_PCZ_INFO } from './modules/bioexcel/biobb_flexserv/pcz_info'
include { BIOBB_FLEXSERV_PCZ_EVECS as STEP32_PCZ_EVECS } from './modules/bioexcel/biobb_flexserv/pcz_evecs'
include { BIOBB_FLEXSERV_PCZ_ANIMATE as STEP33_PCZ_ANIMATE } from './modules/bioexcel/biobb_flexserv/pcz_animate'
include { BIOBB_ANALYSIS_CPPTRAJ_CONVERT as STEP34_CPPTRAJ_CONVERT } from './modules/bioexcel/biobb_analysis/cpptraj_convert'
include { BIOBB_FLEXSERV_PCZ_BFACTOR as STEP35_PCZ_BFACTOR } from './modules/bioexcel/biobb_flexserv/pcz_bfactor'
include { BIOBB_FLEXSERV_PCZ_HINGES as STEP36_PCZ_HINGES } from './modules/bioexcel/biobb_flexserv/pcz_hinges'
include { BIOBB_FLEXSERV_PCZ_HINGES as STEP37_PCZ_HINGES } from './modules/bioexcel/biobb_flexserv/pcz_hinges'
include { BIOBB_FLEXSERV_PCZ_HINGES as STEP38_PCZ_HINGES } from './modules/bioexcel/biobb_flexserv/pcz_hinges'
include { BIOBB_FLEXSERV_PCZ_STIFFNESS as STEP39_PCZ_STIFFNESS } from './modules/bioexcel/biobb_flexserv/pcz_stiffness'
include { BIOBB_FLEXSERV_PCZ_COLLECTIVITY as STEP40_PCZ_COLLECTIVITY } from './modules/bioexcel/biobb_flexserv/pcz_collectivity'
// Python logic of workflow.py
include { ZIP as ZIP_TRAJECTORIES } from './modules/local/zip'

params {
    // CSV with an id column and one column per input file: one workflow run per row
    input: String = "${projectDir}/samplesheet.csv"
}

workflow {
    main:
    // One [meta, files] item per samplesheet row: the steps of every row run in parallel
    ch_samples = channel.fromPath(params.input)
        .splitCsv(header: true)
        .map { row -> [[id: row.id], [structure: samplePath(row.structure)]] }

    // step0_extract_model: Selecting a model
    STEP0_EXTRACT_MODEL(ch_samples.map { meta, files -> [meta, files.structure] })
    // step1_extract_chain: Selecting a monomer
    STEP1_EXTRACT_CHAIN(STEP0_EXTRACT_MODEL.out.output_structure_path)
    // step2_cpptraj_mask: Generating the reduced (coarse-grained) structure (backbone)
    STEP2_CPPTRAJ_MASK(
        STEP1_EXTRACT_CHAIN.out.output_structure_path
            .join(STEP1_EXTRACT_CHAIN.out.output_structure_path)
    )
    // step3_cpptraj_mask: Generating the reduced (coarse-grained) structure (alpha carbons)
    STEP3_CPPTRAJ_MASK(
        STEP1_EXTRACT_CHAIN.out.output_structure_path
            .join(STEP1_EXTRACT_CHAIN.out.output_structure_path)
    )
    // step4_concoord_dist: CONCOORD dist
    STEP4_CONCOORD_DIST(STEP1_EXTRACT_CHAIN.out.output_structure_path)
    // step5_concoord_disco: CONCOORD disco
    STEP5_CONCOORD_DISCO(
        STEP4_CONCOORD_DIST.out.output_pdb_path
            .join(STEP4_CONCOORD_DIST.out.output_dat_path)
    )
    // step6_cpptraj_rms: RMSd distribution of the generated ensemble (CONCOORD)
    STEP6_CPPTRAJ_RMS(
        STEP4_CONCOORD_DIST.out.output_pdb_path
            .join(STEP5_CONCOORD_DISCO.out.output_traj_path)
            .join(STEP1_EXTRACT_CHAIN.out.output_structure_path)
    )
    // step7_cpptraj_convert: Converting the generated ensemble (CONCOORD)
    STEP7_CPPTRAJ_CONVERT(
        STEP4_CONCOORD_DIST.out.output_pdb_path
            .join(STEP5_CONCOORD_DISCO.out.output_traj_path)
    )
    // step8_prody_anm: PRODY Anisotropic network model
    STEP8_PRODY_ANM(STEP1_EXTRACT_CHAIN.out.output_structure_path)
    // step9_cpptraj_rms: RMSd distribution of the generated ensemble (PRODY)
    STEP9_CPPTRAJ_RMS(
        STEP8_PRODY_ANM.out.output_pdb_path
            .join(STEP8_PRODY_ANM.out.output_pdb_path)
            .join(STEP1_EXTRACT_CHAIN.out.output_structure_path)
    )
    // step10_cpptraj_convert: Converting the generated ensemble (PRODY)
    STEP10_CPPTRAJ_CONVERT(
        STEP2_CPPTRAJ_MASK.out.output_cpptraj_path
            .join(STEP8_PRODY_ANM.out.output_pdb_path)
    )
    // step11_bd_run: Brownian Dynamics (BD)
    STEP11_BD_RUN(STEP3_CPPTRAJ_MASK.out.output_cpptraj_path)
    // step12_cpptraj_rms: Fitting and converting the generated ensemble (BD)
    STEP12_CPPTRAJ_RMS(
        STEP3_CPPTRAJ_MASK.out.output_cpptraj_path
            .join(STEP11_BD_RUN.out.output_crd_path)
            .join(STEP1_EXTRACT_CHAIN.out.output_structure_path)
    )
    // step13_dmd_run: Discrete Molecular Dynamics (DMD)
    STEP13_DMD_RUN(STEP3_CPPTRAJ_MASK.out.output_cpptraj_path)
    // step14_cpptraj_rms: RMSd distribution of the generated ensemble (DMD)
    STEP14_CPPTRAJ_RMS(
        STEP3_CPPTRAJ_MASK.out.output_cpptraj_path
            .join(STEP13_DMD_RUN.out.output_crd_path)
            .join(STEP1_EXTRACT_CHAIN.out.output_structure_path)
    )
    // step15_nma_run: Normal Mode Analysis (NMA)
    STEP15_NMA_RUN(STEP3_CPPTRAJ_MASK.out.output_cpptraj_path)
    // step16_cpptraj_rms: RMSd distribution of the generated ensemble (NMA)
    STEP16_CPPTRAJ_RMS(
        STEP3_CPPTRAJ_MASK.out.output_cpptraj_path
            .join(STEP15_NMA_RUN.out.output_crd_path)
            .join(STEP1_EXTRACT_CHAIN.out.output_structure_path)
    )
    // step17_cpptraj_convert: Converting the generated ensemble (NMA)
    STEP17_CPPTRAJ_CONVERT(
        STEP3_CPPTRAJ_MASK.out.output_cpptraj_path
            .join(STEP15_NMA_RUN.out.output_crd_path)
    )
    // step18_nolb_nma: NOn-Linear rigid Block NMA approach (NOLB)
    STEP18_NOLB_NMA(STEP3_CPPTRAJ_MASK.out.output_cpptraj_path)
    // step19_cpptraj_rms: RMSd distribution of the generated ensemble (NOLB)
    STEP19_CPPTRAJ_RMS(
        STEP3_CPPTRAJ_MASK.out.output_cpptraj_path
            .join(STEP18_NOLB_NMA.out.output_pdb_path)
            .join(STEP1_EXTRACT_CHAIN.out.output_structure_path)
    )
    // step20_cpptraj_convert: Converting the generated ensemble (NOLB)
    STEP20_CPPTRAJ_CONVERT(
        STEP3_CPPTRAJ_MASK.out.output_cpptraj_path
            .join(STEP18_NOLB_NMA.out.output_pdb_path)
    )
    // step21_imod_imode: iMOD imode
    STEP21_IMOD_IMODE(STEP1_EXTRACT_CHAIN.out.output_structure_path)
    // step22_imod_imc: iMOD imc
    STEP22_IMOD_IMC(
        STEP1_EXTRACT_CHAIN.out.output_structure_path
            .join(STEP21_IMOD_IMODE.out.output_dat_path)
    )
    // step23_cpptraj_rms: RMSd distribution of the generated ensemble (iMOD)
    STEP23_CPPTRAJ_RMS(
        STEP22_IMOD_IMC.out.output_traj_path
            .join(STEP22_IMOD_IMC.out.output_traj_path)
            .join(STEP1_EXTRACT_CHAIN.out.output_structure_path)
    )
    // step24_cpptraj_convert: Converting the generated ensemble (iMOD)
    STEP24_CPPTRAJ_CONVERT(
        STEP22_IMOD_IMC.out.output_traj_path
            .join(STEP22_IMOD_IMC.out.output_traj_path)
    )
    // step25_trjcat: Compressing trajectories (CONCOORD, PRODY, iMOD, BD and NMA ensembles, in the python order)
    ZIP_TRAJECTORIES(
        STEP7_CPPTRAJ_CONVERT.out.output_cpptraj_path
            .join(STEP10_CPPTRAJ_CONVERT.out.output_cpptraj_path)
            .join(STEP24_CPPTRAJ_CONVERT.out.output_cpptraj_path)
            .join(STEP12_CPPTRAJ_RMS.out.output_traj_path)
            .join(STEP17_CPPTRAJ_CONVERT.out.output_cpptraj_path)
            .map { meta, concoord, prody, imod, bd, nma -> [meta, [concoord, prody, imod, bd, nma]] }
    )
    // step25_trjcat: Building the meta-trajectory
    STEP25_TRJCAT(ZIP_TRAJECTORIES.out.zip)
    // step26_make_ndx: Clustering the meta-trajectory: make index
    STEP26_MAKE_NDX(
        STEP3_CPPTRAJ_MASK.out.output_cpptraj_path
            .map { meta, structure -> [meta, structure, []] }
    )
    // step27_gmx_cluster: Clustering the meta-trajectory: clustering
    STEP27_GMX_CLUSTER(
        STEP3_CPPTRAJ_MASK.out.output_cpptraj_path
            .join(STEP25_TRJCAT.out.output_trj_path)
            .join(STEP26_MAKE_NDX.out.output_ndx_path)
    )
    // step28_cpptraj_rms: Fitting and converting the generated ensemble (meta-trajectory)
    STEP28_CPPTRAJ_RMS(
        STEP3_CPPTRAJ_MASK.out.output_cpptraj_path
            .join(STEP27_GMX_CLUSTER.out.output_pdb_path)
            .join(STEP3_CPPTRAJ_MASK.out.output_cpptraj_path)
    )
    // step29_pcz_zip: Computing the Principal Component Analysis (PCA) - ensemble
    STEP29_PCZ_ZIP(
        STEP3_CPPTRAJ_MASK.out.output_cpptraj_path
            .join(STEP28_CPPTRAJ_RMS.out.output_traj_path)
    )
    // step30_pcz_zip: Computing the Principal Component Analysis (PCA) - ensemble gaussian
    STEP30_PCZ_ZIP(
        STEP3_CPPTRAJ_MASK.out.output_cpptraj_path
            .join(STEP28_CPPTRAJ_RMS.out.output_traj_path)
    )
    // step31_pcz_info: Analysing the PCA report
    STEP31_PCZ_INFO(STEP29_PCZ_ZIP.out.output_pcz_path)
    // step32_pcz_evecs: PCA Eigenvectors & Eigenvalues
    STEP32_PCZ_EVECS(STEP29_PCZ_ZIP.out.output_pcz_path)
    // step33_pcz_animate: Animate Principal Components
    STEP33_PCZ_ANIMATE(STEP29_PCZ_ZIP.out.output_pcz_path)
    // step34_cpptraj_convert: Converting the generated ensemble (PCA)
    STEP34_CPPTRAJ_CONVERT(
        STEP3_CPPTRAJ_MASK.out.output_cpptraj_path
            .join(STEP33_PCZ_ANIMATE.out.output_crd_path)
    )
    // step35_pcz_bfactor: B-Factor x Principal Components
    STEP35_PCZ_BFACTOR(STEP29_PCZ_ZIP.out.output_pcz_path)
    // step36_pcz_hinges: Hinge Points Prediction - Bfactor_slope
    STEP36_PCZ_HINGES(STEP30_PCZ_ZIP.out.output_pcz_path)
    // step37_pcz_hinges: Hinge Points Prediction - Dynamic_domain
    STEP37_PCZ_HINGES(STEP30_PCZ_ZIP.out.output_pcz_path)
    // step38_pcz_hinges: Hinge Points Prediction - Force_constant
    STEP38_PCZ_HINGES(STEP30_PCZ_ZIP.out.output_pcz_path)
    // step39_pcz_stiffness: Apparent Stiffness
    STEP39_PCZ_STIFFNESS(STEP29_PCZ_ZIP.out.output_pcz_path)
    // step40_pcz_collectivity: Collectivity Index
    STEP40_PCZ_COLLECTIVITY(STEP29_PCZ_ZIP.out.output_pcz_path)

    publish:
    results = channel.empty().mix(
        STEP0_EXTRACT_MODEL.out.output_structure_path.map { meta, result -> [meta, 'step0_extract_model', result] },
        STEP1_EXTRACT_CHAIN.out.output_structure_path.map { meta, result -> [meta, 'step1_extract_chain', result] },
        STEP2_CPPTRAJ_MASK.out.output_cpptraj_path.map { meta, result -> [meta, 'step2_cpptraj_mask', result] },
        STEP3_CPPTRAJ_MASK.out.output_cpptraj_path.map { meta, result -> [meta, 'step3_cpptraj_mask', result] },
        STEP4_CONCOORD_DIST.out.output_pdb_path.mix(STEP4_CONCOORD_DIST.out.output_gro_path, STEP4_CONCOORD_DIST.out.output_dat_path).map { meta, result -> [meta, 'step4_concoord_dist', result] },
        STEP5_CONCOORD_DISCO.out.output_traj_path.mix(STEP5_CONCOORD_DISCO.out.output_rmsd_path, STEP5_CONCOORD_DISCO.out.output_bfactor_path).map { meta, result -> [meta, 'step5_concoord_disco', result] },
        STEP6_CPPTRAJ_RMS.out.output_cpptraj_path.map { meta, result -> [meta, 'step6_cpptraj_rms', result] },
        STEP7_CPPTRAJ_CONVERT.out.output_cpptraj_path.map { meta, result -> [meta, 'step7_cpptraj_convert', result] },
        STEP8_PRODY_ANM.out.output_pdb_path.map { meta, result -> [meta, 'step8_prody_anm', result] },
        STEP9_CPPTRAJ_RMS.out.output_cpptraj_path.map { meta, result -> [meta, 'step9_cpptraj_rms', result] },
        STEP10_CPPTRAJ_CONVERT.out.output_cpptraj_path.map { meta, result -> [meta, 'step10_cpptraj_convert', result] },
        STEP11_BD_RUN.out.output_log_path.mix(STEP11_BD_RUN.out.output_crd_path).map { meta, result -> [meta, 'step11_bd_run', result] },
        STEP12_CPPTRAJ_RMS.out.output_cpptraj_path.mix(STEP12_CPPTRAJ_RMS.out.output_traj_path).map { meta, result -> [meta, 'step12_cpptraj_rms', result] },
        STEP13_DMD_RUN.out.output_log_path.mix(STEP13_DMD_RUN.out.output_crd_path).map { meta, result -> [meta, 'step13_dmd_run', result] },
        STEP14_CPPTRAJ_RMS.out.output_cpptraj_path.mix(STEP14_CPPTRAJ_RMS.out.output_traj_path).map { meta, result -> [meta, 'step14_cpptraj_rms', result] },
        STEP15_NMA_RUN.out.output_log_path.mix(STEP15_NMA_RUN.out.output_crd_path).map { meta, result -> [meta, 'step15_nma_run', result] },
        STEP16_CPPTRAJ_RMS.out.output_cpptraj_path.map { meta, result -> [meta, 'step16_cpptraj_rms', result] },
        STEP17_CPPTRAJ_CONVERT.out.output_cpptraj_path.map { meta, result -> [meta, 'step17_cpptraj_convert', result] },
        STEP18_NOLB_NMA.out.output_pdb_path.map { meta, result -> [meta, 'step18_nolb_nma', result] },
        STEP19_CPPTRAJ_RMS.out.output_cpptraj_path.map { meta, result -> [meta, 'step19_cpptraj_rms', result] },
        STEP20_CPPTRAJ_CONVERT.out.output_cpptraj_path.map { meta, result -> [meta, 'step20_cpptraj_convert', result] },
        STEP21_IMOD_IMODE.out.output_dat_path.map { meta, result -> [meta, 'step21_imod_imode', result] },
        STEP22_IMOD_IMC.out.output_traj_path.map { meta, result -> [meta, 'step22_imod_imc', result] },
        STEP23_CPPTRAJ_RMS.out.output_cpptraj_path.map { meta, result -> [meta, 'step23_cpptraj_rms', result] },
        STEP24_CPPTRAJ_CONVERT.out.output_cpptraj_path.map { meta, result -> [meta, 'step24_cpptraj_convert', result] },
        ZIP_TRAJECTORIES.out.zip.mix(STEP25_TRJCAT.out.output_trj_path).map { meta, result -> [meta, 'step25_trjcat', result] },
        STEP26_MAKE_NDX.out.output_ndx_path.map { meta, result -> [meta, 'step26_make_ndx', result] },
        STEP27_GMX_CLUSTER.out.output_pdb_path.map { meta, result -> [meta, 'step27_gmx_cluster', result] },
        STEP28_CPPTRAJ_RMS.out.output_cpptraj_path.mix(STEP28_CPPTRAJ_RMS.out.output_traj_path).map { meta, result -> [meta, 'step28_cpptraj_rms', result] },
        STEP29_PCZ_ZIP.out.output_pcz_path.map { meta, result -> [meta, 'step29_pcz_zip', result] },
        STEP30_PCZ_ZIP.out.output_pcz_path.map { meta, result -> [meta, 'step30_pcz_zip', result] },
        STEP31_PCZ_INFO.out.output_json_path.map { meta, result -> [meta, 'step31_pcz_info', result] },
        STEP32_PCZ_EVECS.out.output_json_path.map { meta, result -> [meta, 'step32_pcz_evecs', result] },
        STEP33_PCZ_ANIMATE.out.output_crd_path.map { meta, result -> [meta, 'step33_pcz_animate', result] },
        STEP34_CPPTRAJ_CONVERT.out.output_cpptraj_path.map { meta, result -> [meta, 'step34_cpptraj_convert', result] },
        STEP35_PCZ_BFACTOR.out.output_dat_path.mix(STEP35_PCZ_BFACTOR.out.output_pdb_path).map { meta, result -> [meta, 'step35_pcz_bfactor', result] },
        STEP36_PCZ_HINGES.out.output_json_path.map { meta, result -> [meta, 'step36_pcz_hinges', result] },
        STEP37_PCZ_HINGES.out.output_json_path.map { meta, result -> [meta, 'step37_pcz_hinges', result] },
        STEP38_PCZ_HINGES.out.output_json_path.map { meta, result -> [meta, 'step38_pcz_hinges', result] },
        STEP39_PCZ_STIFFNESS.out.output_json_path.map { meta, result -> [meta, 'step39_pcz_stiffness', result] },
        STEP40_PCZ_COLLECTIVITY.out.output_json_path.map { meta, result -> [meta, 'step40_pcz_collectivity', result] }
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
