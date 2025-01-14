#!/usr/bin/env python3

import time
import argparse
from biobb_common.configuration import settings
from biobb_common.tools import file_utils as fu
from biobb_amber.leap.leap_gen_top import leap_gen_top
from biobb_amber.leap.leap_solvate import leap_solvate
from biobb_amber.leap.leap_add_ions import leap_add_ions
from biobb_amber.cpptraj.cpptraj_randomize_ions import cpptraj_randomize_ions
from biobb_amber.parmed.parmed_hmassrepartition import parmed_hmassrepartition
from biobb_amber.sander.sander_mdrun import sander_mdrun
from biobb_amber.process.process_minout import process_minout
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

    global_log.info("step1_leap_gen_top: Generating Topology")
    leap_gen_top(**global_paths["step1_leap_gen_top"], properties=global_prop["step1_leap_gen_top"])

    global_log.info("step2_leap_solvate: Adding Water Box")
    leap_solvate(**global_paths["step2_leap_solvate"], properties=global_prop["step2_leap_solvate"])

    global_log.info("step3_leap_add_ions: Adding additional ionic concentration")
    leap_add_ions(**global_paths["step3_leap_add_ions"], properties=global_prop["step3_leap_add_ions"])

    global_log.info("step4_cpptraj_randomize_ions: Randomizing ions")
    cpptraj_randomize_ions(**global_paths["step4_cpptraj_randomize_ions"], properties=global_prop["step4_cpptraj_randomize_ions"])

    global_log.info("step5_parmed_hmassrepartition: Generating Topology with Hydrogen Mass Partitioning (4fs)")
    parmed_hmassrepartition(**global_paths["step5_parmed_hmassrepartition"], properties=global_prop["step5_parmed_hmassrepartition"])

    global_log.info("step6_sander_mdrun_eq1: Equilibration Step 1: System energetic minimization")
    sander_mdrun(**global_paths["step6_sander_mdrun_eq1"], properties=global_prop["step6_sander_mdrun_eq1"])

    global_log.info("step7_process_minout_eq1: Checking Equilibration Step 1 results")
    process_minout(**global_paths["step7_process_minout_eq1"], properties=global_prop["step7_process_minout_eq1"])

    global_log.info("step8_sander_mdrun_eq2: Equilibration Step 2: NVT equilibration")
    sander_mdrun(**global_paths["step8_sander_mdrun_eq2"], properties=global_prop["step8_sander_mdrun_eq2"])

    global_log.info("step9_process_mdout_eq2: Checking Equilibration Step 2 results")
    process_mdout(**global_paths["step9_process_mdout_eq2"], properties=global_prop["step9_process_mdout_eq2"])

    global_log.info("step10_sander_mdrun_eq3: Equilibration Step 3: System energetic minimization")
    sander_mdrun(**global_paths["step10_sander_mdrun_eq3"], properties=global_prop["step10_sander_mdrun_eq3"])

    global_log.info("step11_process_minout_eq3: Checking Equilibration Step 3 results")
    process_minout(**global_paths["step11_process_minout_eq3"], properties=global_prop["step11_process_minout_eq3"])

    global_log.info("step12_sander_mdrun_eq4: Equilibration Step 4: System energetic minimization")
    sander_mdrun(**global_paths["step12_sander_mdrun_eq4"], properties=global_prop["step12_sander_mdrun_eq4"])

    global_log.info("step13_process_minout_eq4: Checking Equilibration Step 4 results")
    process_minout(**global_paths["step13_process_minout_eq4"], properties=global_prop["step13_process_minout_eq4"])

    global_log.info("step14_sander_mdrun_eq5: Equilibration Step 5: System energetic minimization")
    sander_mdrun(**global_paths["step14_sander_mdrun_eq5"], properties=global_prop["step14_sander_mdrun_eq5"])

    global_log.info("step15_process_minout_eq5: Checking Equilibration Step 5 results")
    process_minout(**global_paths["step15_process_minout_eq5"], properties=global_prop["step15_process_minout_eq5"])

    global_log.info("step16_sander_mdrun_eq6: Equilibration Step 6: NPT equilibration")
    sander_mdrun(**global_paths["step16_sander_mdrun_eq6"], properties=global_prop["step16_sander_mdrun_eq6"])

    global_log.info("step17_process_mdout_eq6: Checking Equilibration Step 6 results")
    process_mdout(**global_paths["step17_process_mdout_eq6"], properties=global_prop["step17_process_mdout_eq6"])

    global_log.info("step18_sander_mdrun_eq7: Equilibration Step 7: NPT equilibration")
    sander_mdrun(**global_paths["step18_sander_mdrun_eq7"], properties=global_prop["step18_sander_mdrun_eq7"])

    global_log.info("step19_process_mdout_eq7: Checking Equilibration Step 7 results")
    process_mdout(**global_paths["step19_process_mdout_eq7"], properties=global_prop["step19_process_mdout_eq7"])

    global_log.info("step20_sander_mdrun_eq8: Equilibration Step 8: NPT equilibration")
    sander_mdrun(**global_paths["step20_sander_mdrun_eq8"], properties=global_prop["step20_sander_mdrun_eq8"])

    global_log.info("step21_process_mdout_eq8: Checking Equilibration Step 8 results")
    process_mdout(**global_paths["step21_process_mdout_eq8"], properties=global_prop["step21_process_mdout_eq8"])

    global_log.info("step22_sander_mdrun_eq9: Equilibration Step 9: NPT equilibration")
    sander_mdrun(**global_paths["step22_sander_mdrun_eq9"], properties=global_prop["step22_sander_mdrun_eq9"])

    global_log.info("step23_process_mdout_eq9: Checking Equilibration Step 9 results")
    process_mdout(**global_paths["step23_process_mdout_eq9"], properties=global_prop["step23_process_mdout_eq9"])

    global_log.info("step24_sander_mdrun_eq10: Equilibration Step 10: NPT equilibration")
    sander_mdrun(**global_paths["step24_sander_mdrun_eq10"], properties=global_prop["step24_sander_mdrun_eq10"])

    global_log.info("step25_process_mdout_eq10: Checking Equilibration Step 10 results")
    process_mdout(**global_paths["step25_process_mdout_eq10"], properties=global_prop["step25_process_mdout_eq10"])

    global_log.info("step26_sander_mdrun_md: Free Molecular Dynamics Simulation")
    sander_mdrun(**global_paths["step26_sander_mdrun_md"], properties=global_prop["step26_sander_mdrun_md"])

    global_log.info("step27_rmsd_first: Generate RMSd (against 1st snp.) plot for the resulting setup trajectory from the free md step")
    cpptraj_rms(**global_paths["step27_rmsd_first"], properties=global_prop["step27_rmsd_first"])

    global_log.info("step28_rmsd_exp: Generate RMSd (against exp.) plot for the resulting setup trajectory from the free md step")
    cpptraj_rms(**global_paths["step28_rmsd_exp"], properties=global_prop["step28_rmsd_exp"])

    global_log.info("step29_cpptraj_rgyr: Generate Radius of Gyration plot for the resulting setup trajectory from the free md step")
    cpptraj_rgyr(**global_paths["step29_cpptraj_rgyr"], properties=global_prop["step29_cpptraj_rgyr"])

    global_log.info("step30_cpptraj_image: Imaging the resulting trajectory")
    cpptraj_image(**global_paths["step30_cpptraj_image"], properties=global_prop["step30_cpptraj_image"])

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
    parser = argparse.ArgumentParser(description="ABC MD Setup pipeline using BioExcel Building Blocks")
    parser.add_argument('--config', required=True)
    parser.add_argument('--system', required=False)
    args = parser.parse_args()
    main(args.config, args.system)
