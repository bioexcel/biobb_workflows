#!/usr/bin/env python3

import time
import argparse
from biobb_common.configuration import settings
from biobb_common.tools import file_utils as fu
from biobb_structure_utils.utils.extract_atoms import extract_atoms
from biobb_flexserv.flexserv.bd_run import bd_run
from biobb_analysis.ambertools.cpptraj_rms import cpptraj_rms
from biobb_flexserv.flexserv.dmd_run import dmd_run
from biobb_flexserv.flexserv.nma_run import nma_run
from biobb_flexserv.pcasuite.pcz_zip import pcz_zip
from biobb_flexserv.pcasuite.pcz_unzip import pcz_unzip
from biobb_flexserv.pcasuite.pcz_info import pcz_info
from biobb_flexserv.pcasuite.pcz_evecs import pcz_evecs
from biobb_flexserv.pcasuite.pcz_animate import pcz_animate
from biobb_analysis.ambertools.cpptraj_convert import cpptraj_convert
from biobb_flexserv.pcasuite.pcz_bfactor import pcz_bfactor
from biobb_flexserv.pcasuite.pcz_hinges import pcz_hinges
from biobb_flexserv.pcasuite.pcz_stiffness import pcz_stiffness
from biobb_flexserv.pcasuite.pcz_collectivity import pcz_collectivity
from biobb_flexserv.pcasuite.pcz_similarity import pcz_similarity


def main(config, system=None):
    start_time = time.time()
    conf = settings.ConfReader(config, system)
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    global_log.info("step0_extract_atoms: Generate Coarse Grain Structure")
    extract_atoms(**global_paths["step0_extract_atoms"], properties=global_prop["step0_extract_atoms"])

    global_log.info("step1_bd_run: Brownian Dynamics")
    bd_run(**global_paths["step1_bd_run"], properties=global_prop["step1_bd_run"])

    global_log.info("step2_cpptraj_rms: Fitting and converting BD trajectory to DCD")
    cpptraj_rms(**global_paths["step2_cpptraj_rms"], properties=global_prop["step2_cpptraj_rms"])

    global_log.info("step3_dmd_run: Discrete Molecular Dynamics")
    dmd_run(**global_paths["step3_dmd_run"], properties=global_prop["step3_dmd_run"])

    global_log.info("step4_cpptraj_rms: Fitting and converting DMD trajectory to DCD")
    cpptraj_rms(**global_paths["step4_cpptraj_rms"], properties=global_prop["step4_cpptraj_rms"])

    global_log.info("step5_nma_run: Normal Mode Analysis")
    nma_run(**global_paths["step5_nma_run"], properties=global_prop["step5_nma_run"])

    global_log.info("step6_cpptraj_rms: Fitting and converting NMA trajectory to DCD (visualization)")
    cpptraj_rms(**global_paths["step6_cpptraj_rms"], properties=global_prop["step6_cpptraj_rms"])

    global_log.info("step7_pcz_zip: PCAsuite, Compressing trajectory (BD)")
    pcz_zip(**global_paths["step7_pcz_zip"], properties=global_prop["step7_pcz_zip"])

    global_log.info("step8_pcz_zip: PCAsuite, Compressing trajectory (DMD)")
    pcz_zip(**global_paths["step8_pcz_zip"], properties=global_prop["step8_pcz_zip"])

    global_log.info("step9_pcz_zip: PCAsuite, Compressing trajectory (NMA)")
    pcz_zip(**global_paths["step9_pcz_zip"], properties=global_prop["step9_pcz_zip"])

    global_log.info("step10_pcz_unzip: PCAsuite, Uncompressing trajectory (BD)")
    pcz_unzip(**global_paths["step10_pcz_unzip"], properties=global_prop["step10_pcz_unzip"])

    global_log.info("step11_pcz_unzip: PCAsuite, Uncompressing trajectory (DMD)")
    pcz_unzip(**global_paths["step11_pcz_unzip"], properties=global_prop["step11_pcz_unzip"])

    global_log.info("step12_pcz_unzip: PCAsuite, Uncompressing trajectory (NMA)")
    pcz_unzip(**global_paths["step12_pcz_unzip"], properties=global_prop["step12_pcz_unzip"])

    global_log.info("step13_cpptraj_rms: Fitting and converting uncompressed BD trajectory to DCD (visualization)")
    cpptraj_rms(**global_paths["step13_cpptraj_rms"], properties=global_prop["step13_cpptraj_rms"])

    global_log.info("step14_cpptraj_rms: Fitting and converting uncompressed DMD trajectory to DCD (visualization)")
    cpptraj_rms(**global_paths["step14_cpptraj_rms"], properties=global_prop["step14_cpptraj_rms"])

    global_log.info("step15_cpptraj_rms: Fitting and converting uncompressed NMA trajectory to DCD (visualization)")
    cpptraj_rms(**global_paths["step15_cpptraj_rms"], properties=global_prop["step15_cpptraj_rms"])

    global_log.info("step16_pcz_info: PCAsuite, Principal Components Analysis Report")
    pcz_info(**global_paths["step16_pcz_info"], properties=global_prop["step16_pcz_info"])

    global_log.info("step17_pcz_evecs: PCAsuite, Eigen Vectors")
    pcz_evecs(**global_paths["step17_pcz_evecs"], properties=global_prop["step17_pcz_evecs"])

    global_log.info("step18_pcz_animate: PCAsuite, Animate Principal Components")
    pcz_animate(**global_paths["step18_pcz_animate"], properties=global_prop["step18_pcz_animate"])

    global_log.info("step19_cpptraj_convert: Fitting and converting animated PC NMA trajectory to DCD (visualization)")
    cpptraj_convert(**global_paths["step19_cpptraj_convert"], properties=global_prop["step19_cpptraj_convert"])

    global_log.info("step20_pcz_bfactor: PCAsuite, Bfactor x Principal Components")
    pcz_bfactor(**global_paths["step20_pcz_bfactor"], properties=global_prop["step20_pcz_bfactor"])

    global_log.info("step21_pcz_hinges: PCAsuite, Hinge points prediction (Bfactor slope)")
    pcz_hinges(**global_paths["step21_pcz_hinges"], properties=global_prop["step21_pcz_hinges"])

    global_log.info("step22_pcz_hinges: PCAsuite, Hinge points prediction (Dynamic domain)")
    pcz_hinges(**global_paths["step22_pcz_hinges"], properties=global_prop["step22_pcz_hinges"])

    global_log.info("step23_pcz_hinges: PCAsuite, Hinge points prediction (Force constant)")
    pcz_hinges(**global_paths["step23_pcz_hinges"], properties=global_prop["step23_pcz_hinges"])

    global_log.info("step24_pcz_stiffness: PCAsuite, Apparent Stiffness")
    pcz_stiffness(**global_paths["step24_pcz_stiffness"], properties=global_prop["step24_pcz_stiffness"])

    global_log.info("step25_pcz_collectivity: PCAsuite, Collectivity Index")
    pcz_collectivity(**global_paths["step25_pcz_collectivity"], properties=global_prop["step25_pcz_collectivity"])

    global_log.info("step26_pcz_similarity: PCAsuite, PCZ similarity (BD vs MD)")
    pcz_similarity(**global_paths["step26_pcz_similarity"], properties=global_prop["step26_pcz_similarity"])

    global_log.info("step27_pcz_similarity: PCAsuite, PCZ similarity (DMD vs MD)")
    pcz_similarity(**global_paths["step27_pcz_similarity"], properties=global_prop["step27_pcz_similarity"])

    global_log.info("step28_pcz_similarity: PCAsuite, PCZ similarity (NMA vs MD)")
    pcz_similarity(**global_paths["step28_pcz_similarity"], properties=global_prop["step28_pcz_similarity"])

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
