#!/usr/bin/env python3

import time
import argparse
from biobb_common.configuration import settings
from biobb_common.tools import file_utils as fu
from biobb_chemistry.ambertools.reduce_remove_hydrogens import reduce_remove_hydrogens
from biobb_structure_utils.utils.extract_molecule import extract_molecule
from biobb_structure_utils.utils.cat_pdb import cat_pdb
from biobb_amber.pdb4amber.pdb4amber_run import pdb4amber_run
from biobb_amber.leap.leap_gen_top import leap_gen_top
from biobb_amber.sander.sander_mdrun import sander_mdrun
from biobb_amber.process.process_minout import process_minout
from biobb_amber.ambpdb.amber_to_pdb import amber_to_pdb
from biobb_amber.leap.leap_solvate import leap_solvate
from biobb_amber.leap.leap_add_ions import leap_add_ions
from biobb_amber.process.process_mdout import process_mdout
from biobb_analysis.ambertools.cpptraj_rms import cpptraj_rms
from biobb_analysis.ambertools.cpptraj_rgyr import cpptraj_rgyr
from biobb_analysis.ambertools.cpptraj_image import cpptraj_image


def main(config, system=None):
    start_time = time.time()
    conf = settings.ConfReader(config, system)
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()
    
    global_log.info("step000_reduce_remove_hydrogens: Removing Hydrogens")
    reduce_remove_hydrogens(**global_paths["step000_reduce_remove_hydrogens"], properties=global_prop["step000_reduce_remove_hydrogens"])

    global_log.info("step00_extract_molecule: Extracting protein")
    extract_molecule(**global_paths["step00_extract_molecule"], properties=global_prop["step00_extract_molecule"])

    global_log.info("step0000_cat_pdb: Concatenating protein with included ions")
    cat_pdb(**global_paths["step0000_cat_pdb"], properties=global_prop["step0000_cat_pdb"])

    global_log.info("step0_cat_pdb: Concatenating protein with parameterized ligands")
    cat_pdb(**global_paths["step0_cat_pdb"], properties=global_prop["step0_cat_pdb"])

    global_log.info("step1_pdb4amber_run: Preparing PDB file for AMBER")
    pdb4amber_run(**global_paths["step1_pdb4amber_run"], properties=global_prop["step1_pdb4amber_run"])

    global_log.info("step2_leap_gen_top: Create protein system topology")
    leap_gen_top(**global_paths["step2_leap_gen_top"], properties=global_prop["step2_leap_gen_top"])

    global_log.info("step3_sander_mdrun_minH: Minimize Hydrogens")
    sander_mdrun(**global_paths["step3_sander_mdrun_minH"], properties=global_prop["step3_sander_mdrun_minH"])

    global_log.info("step4_process_minout_minH: Checking Energy Minimization results")
    process_minout(**global_paths["step4_process_minout_minH"], properties=global_prop["step4_process_minout_minH"])

    global_log.info("step5_sander_mdrun_min: Minimize the system")
    sander_mdrun(**global_paths["step5_sander_mdrun_min"], properties=global_prop["step5_sander_mdrun_min"])

    global_log.info("step6_process_minout_min: Checking Energy Minimization results")
    process_minout(**global_paths["step6_process_minout_min"], properties=global_prop["step6_process_minout_min"])

    global_log.info("step7_amber_to_pdb: Getting minimized structure")
    amber_to_pdb(**global_paths["step7_amber_to_pdb"], properties=global_prop["step7_amber_to_pdb"])

    global_log.info("step8_leap_solvate: Create water box")
    leap_solvate(**global_paths["step8_leap_solvate"], properties=global_prop["step8_leap_solvate"])

    global_log.info("step9_leap_add_ions: Adding ions")
    leap_add_ions(**global_paths["step9_leap_add_ions"], properties=global_prop["step9_leap_add_ions"])

    global_log.info("step10_sander_mdrun_energy: Running Energy Minimization")
    sander_mdrun(**global_paths["step10_sander_mdrun_energy"], properties=global_prop["step10_sander_mdrun_energy"])

    global_log.info("step11_process_minout_energy: Checking Energy Minimization results")
    process_minout(**global_paths["step11_process_minout_energy"], properties=global_prop["step11_process_minout_energy"])

    global_log.info("step12_sander_mdrun_warm: Warming up the system")
    sander_mdrun(**global_paths["step12_sander_mdrun_warm"], properties=global_prop["step12_sander_mdrun_warm"])

    global_log.info("step13_process_mdout_warm: Checking results from the system warming up")
    process_mdout(**global_paths["step13_process_mdout_warm"], properties=global_prop["step13_process_mdout_warm"])

    global_log.info("step14_sander_mdrun_nvt: Equilibrating the system (NVT)")
    sander_mdrun(**global_paths["step14_sander_mdrun_nvt"], properties=global_prop["step14_sander_mdrun_nvt"])

    global_log.info("step15_process_mdout_nvt: Checking NVT Equilibration results")
    process_mdout(**global_paths["step15_process_mdout_nvt"], properties=global_prop["step15_process_mdout_nvt"])

    global_log.info("step16_sander_mdrun_npt: Equilibrating the system (NPT)")
    sander_mdrun(**global_paths["step16_sander_mdrun_npt"], properties=global_prop["step16_sander_mdrun_npt"])

    global_log.info("step17_process_mdout_npt: Checking NPT Equilibration results")
    process_mdout(**global_paths["step17_process_mdout_npt"], properties=global_prop["step17_process_mdout_npt"])

    global_log.info("step18_sander_mdrun_md: Creating portable binary run file to run a free MD simulation")
    sander_mdrun(**global_paths["step18_sander_mdrun_md"], properties=global_prop["step18_sander_mdrun_md"])

    global_log.info("step19_rmsd_first: Generate RMSd (against 1st snp.) plot for the resulting setup trajectory from the free md step")
    cpptraj_rms(**global_paths["step19_rmsd_first"], properties=global_prop["step19_rmsd_first"])

    global_log.info("step20_rmsd_exp: Generate RMSd (against exp.) plot for the resulting setup trajectory from the free md step")
    cpptraj_rms(**global_paths["step20_rmsd_exp"], properties=global_prop["step20_rmsd_exp"])

    global_log.info("step21_cpptraj_rgyr: Generate Radius of Gyration plot for the resulting setup trajectory from the free md step")
    cpptraj_rgyr(**global_paths["step21_cpptraj_rgyr"], properties=global_prop["step21_cpptraj_rgyr"])

    global_log.info("step22_cpptraj_image: Imaging the resulting trajectory")
    cpptraj_image(**global_paths["step22_cpptraj_image"], properties=global_prop["step22_cpptraj_image"])

    
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
    parser = argparse.ArgumentParser(description="AMBER Complex Set Up pipeline using BioExcel Building Blocks")
    parser.add_argument('--config', required=True)
    parser.add_argument('--system', required=False)
    args = parser.parse_args()
    main(args.config, args.system)
