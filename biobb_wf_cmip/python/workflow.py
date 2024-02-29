#!/usr/bin/env python3

import time
import argparse
from biobb_common.configuration import settings
from biobb_common.tools import file_utils as fu
from biobb_cmip.cmip.cmip_prepare_pdb import cmip_prepare_pdb
from biobb_cmip.cmip.cmip_titration import cmip_titration
from biobb_structure_utils.utils.cat_pdb import cat_pdb
from biobb_cmip.cmip.cmip_run import cmip_run
from biobb_structure_utils.utils.remove_pdb_water import remove_pdb_water
from biobb_structure_utils.utils.extract_heteroatoms import extract_heteroatoms
from biobb_chemistry.ambertools.reduce_add_hydrogens import reduce_add_hydrogens
from biobb_chemistry.acpype.acpype_params_ac import acpype_params_ac
from biobb_amber.leap.leap_gen_top import leap_gen_top
from biobb_amber.sander.sander_mdrun import sander_mdrun
from biobb_amber.ambpdb.amber_to_pdb import amber_to_pdb
from biobb_cmip.cmip.cmip_prepare_structure import cmip_prepare_structure
from biobb_structure_utils.utils.remove_ligand import remove_ligand
from biobb_cmip.cmip.cmip_ignore_residues import cmip_ignore_residues
from biobb_structure_utils.utils.extract_chain import extract_chain


def main(config, system=None):
    start_time = time.time()
    conf = settings.ConfReader(config, system)
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    global_log.info("step0_cmip_prepare_pdb: CMIP PDB Preparation")
    cmip_prepare_pdb(**global_paths["step0_cmip_prepare_pdb"], properties=global_prop["step0_cmip_prepare_pdb"])

    global_log.info("step1_cmip_titration: Computing structural water molecules & ions positions")
    cmip_titration(**global_paths["step1_cmip_titration"], properties=global_prop["step1_cmip_titration"])

    global_log.info("step2_cat_pdb: Adding structural water molecules & ions")
    cat_pdb(**global_paths["step2_cat_pdb"], properties=global_prop["step2_cat_pdb"])

    global_log.info("step3_cmip_run_pos: Molecular Interaction Potentials (MIPs), Positive MIP")
    cmip_run(**global_paths["step3_cmip_run_pos"], properties=global_prop["step3_cmip_run_pos"])

    global_log.info("step4_cmip_run_neg: Molecular Interaction Potentials (MIPs), Negative MIP")
    cmip_run(**global_paths["step4_cmip_run_neg"], properties=global_prop["step4_cmip_run_neg"])

    global_log.info("step5_cmip_run_neu: Molecular Interaction Potentials (MIPs), Neutral MIP")
    cmip_run(**global_paths["step5_cmip_run_neu"], properties=global_prop["step5_cmip_run_neu"])

    global_log.info("step6_remove_pdb_water: Removing Water Molecules")
    remove_pdb_water(**global_paths["step6_remove_pdb_water"], properties=global_prop["step6_remove_pdb_water"])

    global_log.info("step7_extract_heteroatoms: Create ligand system topology, extracting ligand")
    extract_heteroatoms(**global_paths["step7_extract_heteroatoms"], properties=global_prop["step7_extract_heteroatoms"])

    global_log.info("step8_reduce_add_hydrogens: Create ligand system topology, add hydrogen atoms to the ligand")
    reduce_add_hydrogens(**global_paths["step8_reduce_add_hydrogens"], properties=global_prop["step8_reduce_add_hydrogens"])

    global_log.info("step9_acpype_params_ac: Create ligand system topology, generation of topologies")
    acpype_params_ac(**global_paths["step9_acpype_params_ac"], properties=global_prop["step9_acpype_params_ac"])

    global_log.info("step10_leap_gen_top: Generating system topology")
    leap_gen_top(**global_paths["step10_leap_gen_top"], properties=global_prop["step10_leap_gen_top"])

    global_log.info("step11_sander_mdrun: Minimizing the energy of the system")
    sander_mdrun(**global_paths["step11_sander_mdrun"], properties=global_prop["step11_sander_mdrun"])

    global_log.info("step12_amber_to_pdb: Extracting a PDB file from the minimized system")
    amber_to_pdb(**global_paths["step12_amber_to_pdb"], properties=global_prop["step12_amber_to_pdb"])

    global_log.info("step13_cmip_prepare_structure: CMIP PDB structure Preparation, Protein-Ligand Complex PDB file")
    cmip_prepare_structure(**global_paths["step13_cmip_prepare_structure"], properties=global_prop["step13_cmip_prepare_structure"])

    global_log.info("step14_remove_ligand: CMIP PDB structure Preparation, Protein isolated PDB file")
    remove_ligand(**global_paths["step14_remove_ligand"], properties=global_prop["step14_remove_ligand"])

    global_log.info("step15_cmip_ignore_residues: CMIP PDB structure Preparation, Protein-Ligand Complex with protein structure in dielectric mode")
    cmip_ignore_residues(**global_paths["step15_cmip_ignore_residues"], properties=global_prop["step15_cmip_ignore_residues"])

    global_log.info("step16_cmip_run_int_en: Computing the Protein-Ligand interaction energies")
    cmip_run(**global_paths["step16_cmip_run_int_en"], properties=global_prop["step16_cmip_run_int_en"])

    global_log.info("step17_cmip_prepare_structure: CMIP PDB Preparation")
    cmip_prepare_structure(**global_paths["step17_cmip_prepare_structure"], properties=global_prop["step17_cmip_prepare_structure"])

    global_log.info("step18_extract_chain_a: Extracting chains, chain A")
    extract_chain(**global_paths["step18_extract_chain_a"], properties=global_prop["step18_extract_chain_a"])

    global_log.info("step19_extract_chain_b: Extracting chains, chain B")
    extract_chain(**global_paths["step19_extract_chain_b"], properties=global_prop["step19_extract_chain_b"])

    global_log.info("step20_cmip_run_rbd: CMIP Boxes, box for the RBD")
    cmip_run(**global_paths["step20_cmip_run_rbd"], properties=global_prop["step20_cmip_run_rbd"])

    global_log.info("step21_cmip_run_hace2: CMIP Boxes, box for the hACE2")
    cmip_run(**global_paths["step21_cmip_run_hace2"], properties=global_prop["step21_cmip_run_hace2"])

    global_log.info("step22_cmip_run_rbd_hace2: CMIP Boxes, box for the RBD-hACE2")
    cmip_run(**global_paths["step22_cmip_run_rbd_hace2"], properties=global_prop["step22_cmip_run_rbd_hace2"])

    global_log.info("step23_cmip_ignore_residues_rbd: RDB Interaction Potential Energies, CMIP PDB structure Preparation")
    cmip_ignore_residues(**global_paths["step23_cmip_ignore_residues_rbd"], properties=global_prop["step23_cmip_ignore_residues_rbd"])

    global_log.info("step24_cmip_run_prot_prot: Computing the Protein-Protein interaction energies")
    cmip_run(**global_paths["step24_cmip_run_prot_prot"], properties=global_prop["step24_cmip_run_prot_prot"])

    global_log.info("step25_cmip_ignore_residues_hace2: hACE2 Interaction Potential Energies, CMIP PDB structure Preparation")
    cmip_ignore_residues(**global_paths["step25_cmip_ignore_residues_hace2"], properties=global_prop["step25_cmip_ignore_residues_hace2"])

    global_log.info("step26_cmip_run_complex: Computing the complex interaction energies")
    cmip_run(**global_paths["step26_cmip_run_complex"], properties=global_prop["step26_cmip_run_complex"])

    elapsed_time = time.time() - start_time
    global_log.info('')
    global_log.info('')
    global_log.info('Execution successful: ')
    global_log.info('  Workflow_path: %s' % conf.get_working_dir_path())
    global_log.info('  Config File: %s' % config)
    if system:
        global_log.info('  System: %s' % system)
    global_log.info('')
    global_log.info('Elapsed time: %.1f minutes' % (elapsed_time/60))
    global_log.info('')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description="Based on the official Gromacs tutorial")
    parser.add_argument('--config', required=True)
    parser.add_argument('--system', required=False)
    args = parser.parse_args()
    main(args.config, args.system)
