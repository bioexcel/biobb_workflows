/*
 * Protein-protein Docking tutorial using HADDOCK with the BioExcel Building Blocks (biobb)
 * Nextflow version of biobb_wf_haddock/python/workflow.py, with the BioBB Nextflow modules in modules/.
 * Ported by hand: nextflow_wf_generator.py can't translate the python logic of workflow.py (pipelines of pdb_tools
 * blocks for the heavy and light chains, zips of their outputs, inputs of the haddock3 steps made by them).
 * Regenerating it only refreshes the modules.
 * Usage: nextflow run main.nf -profile docker [--input samplesheet.csv]
 */

include { BIOBB_PDB_TOOLS_BIOBB_PDB_TIDY as STEP0_1_PDB_TIDY } from './modules/bioexcel/biobb_pdb_tools/biobb_pdb_tidy'
include { BIOBB_PDB_TOOLS_BIOBB_PDB_SELCHAIN as STEP0_2_PDB_SELCHAIN } from './modules/bioexcel/biobb_pdb_tools/biobb_pdb_selchain'
include { BIOBB_PDB_TOOLS_BIOBB_PDB_DELHETATM as STEP0_3_PDB_DELHETATM } from './modules/bioexcel/biobb_pdb_tools/biobb_pdb_delhetatm'
include { BIOBB_PDB_TOOLS_BIOBB_PDB_FIXINSERT as STEP0_4_PDB_FIXINSERT } from './modules/bioexcel/biobb_pdb_tools/biobb_pdb_fixinsert'
include { BIOBB_PDB_TOOLS_BIOBB_PDB_SELALTLOC as STEP0_5_PDB_SELALTLOC } from './modules/bioexcel/biobb_pdb_tools/biobb_pdb_selaltloc'
include { BIOBB_PDB_TOOLS_BIOBB_PDB_KEEPCOORD as STEP0_6_PDB_KEEPCOORD } from './modules/bioexcel/biobb_pdb_tools/biobb_pdb_keepcoord'
include { BIOBB_PDB_TOOLS_BIOBB_PDB_SELRES as STEP0_7_PDB_SELRES } from './modules/bioexcel/biobb_pdb_tools/biobb_pdb_selres'
include { BIOBB_PDB_TOOLS_BIOBB_PDB_TIDY as STEP0_8_PDB_TIDY } from './modules/bioexcel/biobb_pdb_tools/biobb_pdb_tidy'
include { ZIP as STEP0_ZIP } from './modules/local/zip'
include { BIOBB_PDB_TOOLS_BIOBB_PDB_MERGE as STEP1_BIOBB_PDB_MERGE } from './modules/bioexcel/biobb_pdb_tools/biobb_pdb_merge'
include { BIOBB_PDB_TOOLS_BIOBB_PDB_RERES as STEP2_1_PDB_RERES } from './modules/bioexcel/biobb_pdb_tools/biobb_pdb_reres'
include { BIOBB_PDB_TOOLS_BIOBB_PDB_CHAIN as STEP2_2_PDB_CHAIN } from './modules/bioexcel/biobb_pdb_tools/biobb_pdb_chain'
include { BIOBB_PDB_TOOLS_BIOBB_PDB_CHAINXSEG as STEP2_3_PDB_CHAINXSEG } from './modules/bioexcel/biobb_pdb_tools/biobb_pdb_chainxseg'
include { BIOBB_PDB_TOOLS_BIOBB_PDB_TIDY as STEP2_4_PDB_TIDY } from './modules/bioexcel/biobb_pdb_tools/biobb_pdb_tidy'
include { BIOBB_PDB_TOOLS_BIOBB_PDB_TIDY as STEP3_1_PDB_TIDY } from './modules/bioexcel/biobb_pdb_tools/biobb_pdb_tidy'
include { BIOBB_PDB_TOOLS_BIOBB_PDB_DELHETATM as STEP3_2_PDB_DELHETATM } from './modules/bioexcel/biobb_pdb_tools/biobb_pdb_delhetatm'
include { BIOBB_PDB_TOOLS_BIOBB_PDB_SELALTLOC as STEP3_3_PDB_SELALTLOC } from './modules/bioexcel/biobb_pdb_tools/biobb_pdb_selaltloc'
include { BIOBB_PDB_TOOLS_BIOBB_PDB_KEEPCOORD as STEP3_4_PDB_KEEPCOORD } from './modules/bioexcel/biobb_pdb_tools/biobb_pdb_keepcoord'
include { BIOBB_PDB_TOOLS_BIOBB_PDB_CHAIN as STEP3_5_PDB_CHAIN } from './modules/bioexcel/biobb_pdb_tools/biobb_pdb_chain'
include { BIOBB_PDB_TOOLS_BIOBB_PDB_CHAINXSEG as STEP3_6_PDB_CHAINXSEG } from './modules/bioexcel/biobb_pdb_tools/biobb_pdb_chainxseg'
include { BIOBB_PDB_TOOLS_BIOBB_PDB_TIDY as STEP3_7_PDB_TIDY } from './modules/bioexcel/biobb_pdb_tools/biobb_pdb_tidy'
include { BIOBB_PDB_TOOLS_BIOBB_PDB_SELCHAIN as STEP4_1_PDB_SELCHAIN } from './modules/bioexcel/biobb_pdb_tools/biobb_pdb_selchain'
include { BIOBB_PDB_TOOLS_BIOBB_PDB_DELHETATM as STEP4_2_PDB_DELHETATM } from './modules/bioexcel/biobb_pdb_tools/biobb_pdb_delhetatm'
include { BIOBB_PDB_TOOLS_BIOBB_PDB_FIXINSERT as STEP4_3_PDB_FIXINSERT } from './modules/bioexcel/biobb_pdb_tools/biobb_pdb_fixinsert'
include { BIOBB_PDB_TOOLS_BIOBB_PDB_SELALTLOC as STEP4_4_PDB_SELALTLOC } from './modules/bioexcel/biobb_pdb_tools/biobb_pdb_selaltloc'
include { BIOBB_PDB_TOOLS_BIOBB_PDB_KEEPCOORD as STEP4_5_PDB_KEEPCOORD } from './modules/bioexcel/biobb_pdb_tools/biobb_pdb_keepcoord'
include { BIOBB_PDB_TOOLS_BIOBB_PDB_SELRES as STEP4_6_PDB_SELRES } from './modules/bioexcel/biobb_pdb_tools/biobb_pdb_selres'
include { BIOBB_PDB_TOOLS_BIOBB_PDB_TIDY as STEP4_7_PDB_TIDY } from './modules/bioexcel/biobb_pdb_tools/biobb_pdb_tidy'
include { ZIP as STEP4_ZIP } from './modules/local/zip'
include { BIOBB_PDB_TOOLS_BIOBB_PDB_MERGE as STEP5_BIOBB_PDB_MERGE } from './modules/bioexcel/biobb_pdb_tools/biobb_pdb_merge'
include { BIOBB_PDB_TOOLS_BIOBB_PDB_RERES as STEP6_1_PDB_RERES } from './modules/bioexcel/biobb_pdb_tools/biobb_pdb_reres'
include { BIOBB_PDB_TOOLS_BIOBB_PDB_CHAIN as STEP6_2_PDB_CHAIN } from './modules/bioexcel/biobb_pdb_tools/biobb_pdb_chain'
include { BIOBB_PDB_TOOLS_BIOBB_PDB_CHAINXSEG as STEP6_3_PDB_CHAINXSEG } from './modules/bioexcel/biobb_pdb_tools/biobb_pdb_chainxseg'
include { BIOBB_PDB_TOOLS_BIOBB_PDB_TIDY as STEP6_4_PDB_TIDY } from './modules/bioexcel/biobb_pdb_tools/biobb_pdb_tidy'
include { BIOBB_PDB_TOOLS_BIOBB_PDB_RERES as STEP7_1_PDB_RERES } from './modules/bioexcel/biobb_pdb_tools/biobb_pdb_reres'
include { BIOBB_PDB_TOOLS_BIOBB_PDB_CHAIN as STEP7_2_PDB_CHAIN } from './modules/bioexcel/biobb_pdb_tools/biobb_pdb_chain'
include { BIOBB_PDB_TOOLS_BIOBB_PDB_CHAINXSEG as STEP7_3_PDB_CHAINXSEG } from './modules/bioexcel/biobb_pdb_tools/biobb_pdb_chainxseg'
include { BIOBB_PDB_TOOLS_BIOBB_PDB_TIDY as STEP7_4_PDB_TIDY } from './modules/bioexcel/biobb_pdb_tools/biobb_pdb_tidy'
include { ZIP as STEP7_ZIP } from './modules/local/zip'
include { BIOBB_PDB_TOOLS_BIOBB_PDB_MERGE as STEP8_1_PDB_MERGE } from './modules/bioexcel/biobb_pdb_tools/biobb_pdb_merge'
include { BIOBB_PDB_TOOLS_BIOBB_PDB_TIDY as STEP8_2_PDB_TIDY } from './modules/bioexcel/biobb_pdb_tools/biobb_pdb_tidy'
include { BIOBB_HADDOCK_HADDOCK3_PASSIVE_FROM_ACTIVE as STEP9_HADDOCK3_PASSIVE_FROM_ACTIVE } from './modules/bioexcel/biobb_haddock/haddock3_passive_from_active'
include { BIOBB_HADDOCK_HADDOCK3_ACTPASS_TO_AMBIG as STEP10_HADDOCK3_ACTPASS_TO_AMBIG } from './modules/bioexcel/biobb_haddock/haddock3_actpass_to_ambig'
include { BIOBB_HADDOCK_HADDOCK3_RESTRAIN_BODIES as STEP11_HADDOCK3_RESTRAIN_BODIES } from './modules/bioexcel/biobb_haddock/haddock3_restrain_bodies'
include { BIOBB_HADDOCK_TOPOLOGY as STEP12_TOPOLOGY } from './modules/bioexcel/biobb_haddock/topology'
include { BIOBB_HADDOCK_RIGID_BODY as STEP13_RIGID_BODY } from './modules/bioexcel/biobb_haddock/rigid_body'
include { BIOBB_HADDOCK_CAPRI_EVAL as STEP14_CAPRI_EVAL1 } from './modules/bioexcel/biobb_haddock/capri_eval'
include { BIOBB_HADDOCK_SELE_TOP as STEP15_SELE_TOP } from './modules/bioexcel/biobb_haddock/sele_top'
include { BIOBB_HADDOCK_FLEX_REF as STEP16_FLEX_REF } from './modules/bioexcel/biobb_haddock/flex_ref'
include { BIOBB_HADDOCK_CAPRI_EVAL as STEP17_CAPRI_EVAL2 } from './modules/bioexcel/biobb_haddock/capri_eval'
include { BIOBB_HADDOCK_EM_REF as STEP18_EM_REF } from './modules/bioexcel/biobb_haddock/em_ref'
include { BIOBB_HADDOCK_CAPRI_EVAL as STEP19_CAPRI_EVAL3 } from './modules/bioexcel/biobb_haddock/capri_eval'
include { BIOBB_HADDOCK_CLUST_FCC as STEP20_CLUST_FCC } from './modules/bioexcel/biobb_haddock/clust_fcc'
include { BIOBB_HADDOCK_SELE_TOP_CLUSTS as STEP21_SELE_TOP_CLUSTS } from './modules/bioexcel/biobb_haddock/sele_top_clusts'
include { BIOBB_HADDOCK_CAPRI_EVAL as STEP22_CAPRI_EVAL4 } from './modules/bioexcel/biobb_haddock/capri_eval'
include { BIOBB_HADDOCK_CONTACT_MAP as STEP23_CONTACT_MAP } from './modules/bioexcel/biobb_haddock/contact_map'

params {
    // CSV with an id column and one column per input file: one workflow run per row
    input: String = "${projectDir}/samplesheet.csv"
}

workflow {
    main:
    // One [meta, files] item per samplesheet row: the steps of every row run in parallel
    ch_samples = channel.fromPath(params.input)
        .splitCsv(header: true)
        .map { row -> [[id: row.id], [antigen: samplePath(row.antigen), antibody_actpass: samplePath(row.antibody_actpass), antibody: samplePath(row.antibody), complex: samplePath(row.complex)]] }

    // Heavy (H, residues 1-120) and light (L, residues 1-107) chains of the python loops
    ch_antibody_chains = ch_samples.flatMap { meta, files -> [['H', 120], ['L', 107]].collect { chain, residues -> [meta + [chain: chain, residues: residues], files.antibody] } }
    ch_complex_chains = ch_samples.flatMap { meta, files -> [['H', 120], ['L', 107]].collect { chain, residues -> [meta + [chain: chain, residues: residues], files.complex] } }

    // step0_prepare_antibody_reduce: Select and extract protein regions/chains (pdb_tools pipeline of workflow.py)
    STEP0_1_PDB_TIDY(ch_antibody_chains)
    STEP0_2_PDB_SELCHAIN(STEP0_1_PDB_TIDY.out.output_file_path)
    STEP0_3_PDB_DELHETATM(STEP0_2_PDB_SELCHAIN.out.output_file_path)
    STEP0_4_PDB_FIXINSERT(STEP0_3_PDB_DELHETATM.out.output_file_path)
    STEP0_5_PDB_SELALTLOC(STEP0_4_PDB_FIXINSERT.out.output_file_path)
    STEP0_6_PDB_KEEPCOORD(STEP0_5_PDB_SELALTLOC.out.output_file_path)
    STEP0_7_PDB_SELRES(STEP0_6_PDB_KEEPCOORD.out.output_file_path)
    STEP0_8_PDB_TIDY(STEP0_7_PDB_SELRES.out.output_file_path)
    // step0_prepare_antibody_reduce: zip of the H and L chains (antibody_HL.zip of workflow.py)
    STEP0_ZIP(chainsZip(STEP0_8_PDB_TIDY.out.output_file_path))
    // step1_biobb_pdb_merge: Merge regions into a single file
    STEP1_BIOBB_PDB_MERGE(STEP0_ZIP.out.zip)
    // step2_prepare_antibody_clean: Prepare PDB file to meet HADDOCK3 requirements (pdb_tools pipeline of workflow.py)
    STEP2_1_PDB_RERES(STEP1_BIOBB_PDB_MERGE.out.output_file_path)
    STEP2_2_PDB_CHAIN(STEP2_1_PDB_RERES.out.output_file_path)
    STEP2_3_PDB_CHAINXSEG(STEP2_2_PDB_CHAIN.out.output_file_path)
    STEP2_4_PDB_TIDY(STEP2_3_PDB_CHAINXSEG.out.output_file_path)
    // step3_prepare_antigen_clean: Preparing the antigen structure (pdb_tools pipeline of workflow.py)
    STEP3_1_PDB_TIDY(ch_samples.map { meta, files -> [meta, files.antigen] })
    STEP3_2_PDB_DELHETATM(STEP3_1_PDB_TIDY.out.output_file_path)
    STEP3_3_PDB_SELALTLOC(STEP3_2_PDB_DELHETATM.out.output_file_path)
    STEP3_4_PDB_KEEPCOORD(STEP3_3_PDB_SELALTLOC.out.output_file_path)
    STEP3_5_PDB_CHAIN(STEP3_4_PDB_KEEPCOORD.out.output_file_path)
    STEP3_6_PDB_CHAINXSEG(STEP3_5_PDB_CHAIN.out.output_file_path)
    STEP3_7_PDB_TIDY(STEP3_6_PDB_CHAINXSEG.out.output_file_path)
    // step4_prepare_reference_structure: Select and extract protein regions/chains (pdb_tools pipeline of workflow.py)
    STEP4_1_PDB_SELCHAIN(ch_complex_chains)
    STEP4_2_PDB_DELHETATM(STEP4_1_PDB_SELCHAIN.out.output_file_path)
    STEP4_3_PDB_FIXINSERT(STEP4_2_PDB_DELHETATM.out.output_file_path)
    STEP4_4_PDB_SELALTLOC(STEP4_3_PDB_FIXINSERT.out.output_file_path)
    STEP4_5_PDB_KEEPCOORD(STEP4_4_PDB_SELALTLOC.out.output_file_path)
    STEP4_6_PDB_SELRES(STEP4_5_PDB_KEEPCOORD.out.output_file_path)
    STEP4_7_PDB_TIDY(STEP4_6_PDB_SELRES.out.output_file_path)
    // step4_prepare_reference_structure: zip of the H and L chains (complex_HL.zip of workflow.py)
    STEP4_ZIP(chainsZip(STEP4_7_PDB_TIDY.out.output_file_path))
    // step5_biobb_pdb_merge: Merge Heavy and Light regions (from the complex) into a single file
    STEP5_BIOBB_PDB_MERGE(STEP4_ZIP.out.zip)
    // step6_prepare_complex_antibody_clean: Prepare the Antibody PDB file (from the complex) to match HADDOCK3 requirements (pdb_tools pipeline of workflow.py)
    STEP6_1_PDB_RERES(STEP5_BIOBB_PDB_MERGE.out.output_file_path)
    STEP6_2_PDB_CHAIN(STEP6_1_PDB_RERES.out.output_file_path)
    STEP6_3_PDB_CHAINXSEG(STEP6_2_PDB_CHAIN.out.output_file_path)
    STEP6_4_PDB_TIDY(STEP6_3_PDB_CHAINXSEG.out.output_file_path)
    // step7_prepare_complex_antigen_clean: Prepare the Antigen PDB file (from the complex) to match HADDOCK3 requirements (pdb_tools pipeline of workflow.py)
    STEP7_1_PDB_RERES(ch_samples.map { meta, files -> [meta, files.complex] })
    STEP7_2_PDB_CHAIN(STEP7_1_PDB_RERES.out.output_file_path)
    STEP7_3_PDB_CHAINXSEG(STEP7_2_PDB_CHAIN.out.output_file_path)
    STEP7_4_PDB_TIDY(STEP7_3_PDB_CHAINXSEG.out.output_file_path)
    // step7_prepare_complex_antigen_clean: zip of the antibody (step6) and antigen (step7) of the complex (complex_HL_B.zip of workflow.py)
    STEP7_ZIP(
        STEP6_4_PDB_TIDY.out.output_file_path
            .join(STEP7_4_PDB_TIDY.out.output_file_path)
            .map { meta, antibody, antigen -> [meta, [antibody, antigen]] }
    )
    // step8_merge_heavy_light_antigen: Merge Heavy + Light regions and Antigen (from the complex) into a single file (pdb_tools pipeline of workflow.py)
    STEP8_1_PDB_MERGE(STEP7_ZIP.out.zip)
    STEP8_2_PDB_TIDY(STEP8_1_PDB_MERGE.out.output_file_path)
    // Inputs of the haddock3 steps made by the pdb_tools pipelines
    ch_antibody_clean = STEP2_4_PDB_TIDY.out.output_file_path
    ch_antigen_clean = STEP3_7_PDB_TIDY.out.output_file_path
    ch_complex_clean = STEP8_2_PDB_TIDY.out.output_file_path

    // step9_haddock3_passive_from_active: Passive restraints
    STEP9_HADDOCK3_PASSIVE_FROM_ACTIVE(
        ch_antigen_clean
            .map { meta, pdb -> [meta, pdb, []] }
    )
    // step10_haddock3_actpass_to_ambig: Passive restraints
    STEP10_HADDOCK3_ACTPASS_TO_AMBIG(
        ch_samples.map { meta, files -> [meta, files.antibody_actpass] }
            .join(STEP9_HADDOCK3_PASSIVE_FROM_ACTIVE.out.output_actpass_path)
    )
    // step11_haddock3_restrain_bodies: Passive restraints
    STEP11_HADDOCK3_RESTRAIN_BODIES(ch_antibody_clean)
    // step12_topology: Create topology
    STEP12_TOPOLOGY(
        ch_antibody_clean
            .join(ch_antigen_clean)
            .map { meta, mol1_input_pdb, mol2_input_pdb -> [meta, mol1_input_pdb, mol2_input_pdb, []] }
    )
    // step13_rigid_body: Rigid body sampling
    STEP13_RIGID_BODY(
        STEP12_TOPOLOGY.out.output_haddock_wf_data
            .join(STEP10_HADDOCK3_ACTPASS_TO_AMBIG.out.output_tbl_path)
            .join(STEP11_HADDOCK3_RESTRAIN_BODIES.out.output_tbl_path)
            .map { meta, haddock_wf_data, ambig_restraints_table, unambig_restraints_table -> [meta, haddock_wf_data, ambig_restraints_table, unambig_restraints_table, [], []] }
    )
    // step14_capri_eval1: 1st CAPRI evaluation
    STEP14_CAPRI_EVAL1(
        STEP13_RIGID_BODY.out.output_haddock_wf_data
            .join(ch_complex_clean)
            .map { meta, haddock_wf_data, reference_pdb -> [meta, haddock_wf_data, reference_pdb, []] }
    )
    // step15_sele_top: Select Top structures
    STEP15_SELE_TOP(
        STEP14_CAPRI_EVAL1.out.output_haddock_wf_data
            .map { meta, haddock_wf_data -> [meta, haddock_wf_data, []] }
    )
    // step16_flex_ref: Flexible Refinement
    STEP16_FLEX_REF(
        STEP15_SELE_TOP.out.output_haddock_wf_data
            .join(STEP10_HADDOCK3_ACTPASS_TO_AMBIG.out.output_tbl_path)
            .join(STEP11_HADDOCK3_RESTRAIN_BODIES.out.output_tbl_path)
            .map { meta, haddock_wf_data, ambig_restraints_table, unambig_restraints_table -> [meta, haddock_wf_data, ambig_restraints_table, unambig_restraints_table, [], []] }
    )
    // step17_capri_eval2: 2nd CAPRI evaluation
    STEP17_CAPRI_EVAL2(
        STEP16_FLEX_REF.out.output_haddock_wf_data
            .join(ch_complex_clean)
            .map { meta, haddock_wf_data, reference_pdb -> [meta, haddock_wf_data, reference_pdb, []] }
    )
    // step18_em_ref: Energy minimization refinement
    STEP18_EM_REF(
        STEP17_CAPRI_EVAL2.out.output_haddock_wf_data
            .join(STEP10_HADDOCK3_ACTPASS_TO_AMBIG.out.output_tbl_path)
            .join(STEP11_HADDOCK3_RESTRAIN_BODIES.out.output_tbl_path)
            .map { meta, haddock_wf_data, ambig_restraints_table, unambig_restraints_table -> [meta, haddock_wf_data, ambig_restraints_table, unambig_restraints_table, [], []] }
    )
    // step19_capri_eval3: 3rd CAPRI evaluation
    STEP19_CAPRI_EVAL3(
        STEP18_EM_REF.out.output_haddock_wf_data
            .join(ch_complex_clean)
            .map { meta, haddock_wf_data, reference_pdb -> [meta, haddock_wf_data, reference_pdb, []] }
    )
    // step20_clust_fcc: Clustering
    STEP20_CLUST_FCC(
        STEP19_CAPRI_EVAL3.out.output_haddock_wf_data
            .map { meta, haddock_wf_data -> [meta, haddock_wf_data, []] }
    )
    // step21_sele_top_clusts: Clustering
    STEP21_SELE_TOP_CLUSTS(
        STEP20_CLUST_FCC.out.output_haddock_wf_data
            .map { meta, haddock_wf_data -> [meta, haddock_wf_data, []] }
    )
    // step22_capri_eval4: Final CAPRI evaluation
    STEP22_CAPRI_EVAL4(
        STEP21_SELE_TOP_CLUSTS.out.output_haddock_wf_data
            .join(ch_complex_clean)
            .map { meta, haddock_wf_data, reference_pdb -> [meta, haddock_wf_data, reference_pdb, []] }
    )
    // step23_contact_map: Contacts analysis
    STEP23_CONTACT_MAP(
        STEP22_CAPRI_EVAL4.out.output_haddock_wf_data
            .map { meta, haddock_wf_data -> [meta, haddock_wf_data, []] }
    )

    publish:
    results = channel.empty().mix(
        STEP0_8_PDB_TIDY.out.output_file_path.map { meta, result -> [sampleMeta(meta), 'step0_prepare_antibody_reduce', result] },
        STEP0_ZIP.out.zip.map { meta, result -> [meta, 'step0_prepare_antibody_reduce', result] },
        STEP1_BIOBB_PDB_MERGE.out.output_file_path.map { meta, result -> [meta, 'step1_biobb_pdb_merge', result] },
        STEP2_4_PDB_TIDY.out.output_file_path.map { meta, result -> [sampleMeta(meta), 'step2_prepare_antibody_clean', result] },
        STEP3_7_PDB_TIDY.out.output_file_path.map { meta, result -> [sampleMeta(meta), 'step3_prepare_antigen_clean', result] },
        STEP4_7_PDB_TIDY.out.output_file_path.map { meta, result -> [sampleMeta(meta), 'step4_prepare_reference_structure', result] },
        STEP4_ZIP.out.zip.map { meta, result -> [meta, 'step4_prepare_reference_structure', result] },
        STEP5_BIOBB_PDB_MERGE.out.output_file_path.map { meta, result -> [meta, 'step5_biobb_pdb_merge', result] },
        STEP6_4_PDB_TIDY.out.output_file_path.map { meta, result -> [sampleMeta(meta), 'step6_prepare_complex_antibody_clean', result] },
        STEP7_4_PDB_TIDY.out.output_file_path.map { meta, result -> [sampleMeta(meta), 'step7_prepare_complex_antigen_clean', result] },
        STEP7_ZIP.out.zip.map { meta, result -> [meta, 'step7_prepare_complex_antigen_clean', result] },
        STEP8_2_PDB_TIDY.out.output_file_path.map { meta, result -> [sampleMeta(meta), 'step8_merge_heavy_light_antigen', result] },
        STEP9_HADDOCK3_PASSIVE_FROM_ACTIVE.out.output_actpass_path.map { meta, result -> [meta, 'step9_haddock3_passive_from_active', result] },
        STEP10_HADDOCK3_ACTPASS_TO_AMBIG.out.output_tbl_path.map { meta, result -> [meta, 'step10_haddock3_actpass_to_ambig', result] },
        STEP11_HADDOCK3_RESTRAIN_BODIES.out.output_tbl_path.map { meta, result -> [meta, 'step11_haddock3_restrain_bodies', result] },
        STEP12_TOPOLOGY.out.output_haddock_wf_data.mix(STEP12_TOPOLOGY.out.mol1_output_top_zip_path, STEP12_TOPOLOGY.out.mol2_output_top_zip_path).map { meta, result -> [meta, 'step12_topology', result] },
        STEP13_RIGID_BODY.out.output_haddock_wf_data.mix(STEP13_RIGID_BODY.out.docking_output_zip_path).map { meta, result -> [meta, 'step13_rigid_body', result] },
        STEP14_CAPRI_EVAL1.out.output_haddock_wf_data.mix(STEP14_CAPRI_EVAL1.out.output_evaluation_zip_path).map { meta, result -> [meta, 'step14_capri_eval1', result] },
        STEP15_SELE_TOP.out.output_haddock_wf_data.mix(STEP15_SELE_TOP.out.output_selection_zip_path).map { meta, result -> [meta, 'step15_sele_top', result] },
        STEP16_FLEX_REF.out.output_haddock_wf_data.mix(STEP16_FLEX_REF.out.refinement_output_zip_path).map { meta, result -> [meta, 'step16_flex_ref', result] },
        STEP17_CAPRI_EVAL2.out.output_haddock_wf_data.mix(STEP17_CAPRI_EVAL2.out.output_evaluation_zip_path).map { meta, result -> [meta, 'step17_capri_eval2', result] },
        STEP18_EM_REF.out.output_haddock_wf_data.mix(STEP18_EM_REF.out.refinement_output_zip_path).map { meta, result -> [meta, 'step18_em_ref', result] },
        STEP19_CAPRI_EVAL3.out.output_haddock_wf_data.mix(STEP19_CAPRI_EVAL3.out.output_evaluation_zip_path).map { meta, result -> [meta, 'step19_capri_eval3', result] },
        STEP20_CLUST_FCC.out.output_haddock_wf_data.mix(STEP20_CLUST_FCC.out.output_cluster_zip_path).map { meta, result -> [meta, 'step20_clust_fcc', result] },
        STEP21_SELE_TOP_CLUSTS.out.output_haddock_wf_data.mix(STEP21_SELE_TOP_CLUSTS.out.output_selection_zip_path).map { meta, result -> [meta, 'step21_sele_top_clusts', result] },
        STEP22_CAPRI_EVAL4.out.output_haddock_wf_data.mix(STEP22_CAPRI_EVAL4.out.output_evaluation_zip_path).map { meta, result -> [meta, 'step22_capri_eval4', result] },
        STEP23_CONTACT_MAP.out.output_haddock_wf_data.mix(STEP23_CONTACT_MAP.out.output_contactmap_zip_path).map { meta, result -> [meta, 'step23_contact_map', result] }
    )
}

output {
    // results/<id>/<step>/<id>_<step>_<role>.<ext>
    results {
        path { meta, step, _result -> "${meta.id}/${step}" }
    }
}

// Sample of an item of the heavy and light chain loops
def sampleMeta(Map meta) {
    meta.findAll { key, _value -> !(key in ['chain', 'residues']) }
}

// [meta, [H, L]] items of the PDBs of both chains, to zip them in the order of workflow.py
def chainsZip(ch_chains) {
    ch_chains
        .map { meta, pdb -> [sampleMeta(meta), [meta.chain, pdb]] }
        .groupTuple(size: 2)
        .map { meta, chain_pdbs -> [meta, chain_pdbs.sort { chain_pdb -> chain_pdb[0] }.collect { chain_pdb -> chain_pdb[1] }] }
}

// Path of a samplesheet column: absolute, or relative to the samplesheet folder
def samplePath(String value) {
    file(file(params.input).parent.resolve(value).toString(), checkIfExists: true)
}
