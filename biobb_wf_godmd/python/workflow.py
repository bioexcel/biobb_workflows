#!/usr/bin/env python3

import time
import argparse
from biobb_common.configuration import settings
from biobb_common.tools import file_utils as fu
from biobb_structure_utils.utils.extract_chain import extract_chain
from biobb_structure_utils.utils.remove_molecules import remove_molecules
from biobb_godmd.godmd.godmd_prep import godmd_prep
from biobb_godmd.godmd.godmd_run import godmd_run
from biobb_analysis.ambertools.cpptraj_convert import cpptraj_convert


def main(config, system=None):
    start_time = time.time()
    conf = settings.ConfReader(config, system)
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    global_log.info("step0_extract_chain: Extracting the interesting chains from the origin structure")
    extract_chain(**global_paths["step0_extract_chain"], properties=global_prop["step0_extract_chain"])

    global_log.info("step1_extract_chain: Extracting the interesting chains from the target structure")
    extract_chain(**global_paths["step1_extract_chain"], properties=global_prop["step1_extract_chain"])

    # if no molecule provided, jump this step
    if global_prop["step2_remove_molecules"]["molecules"]:
        global_log.info("step2_remove_molecules: Removing the inhibitor from the closed conformation (origin)")
        remove_molecules(**global_paths["step2_remove_molecules"], properties=global_prop["step2_remove_molecules"])
    else:
        global_paths["step4_godmd_prep"]["input_pdb_orig_path"] = global_paths["step0_extract_chain"]["output_structure_path"]
        global_paths["step5_godmd_run"]["input_pdb_orig_path"] = global_paths["step0_extract_chain"]["output_structure_path"]

    # if no molecule provided, jump this step
    if global_prop["step3_remove_molecules"]["molecules"]:
        global_log.info("step3_remove_molecules: Removing the inhibitor from the closed conformation (target)")
        remove_molecules(**global_paths["step3_remove_molecules"], properties=global_prop["step3_remove_molecules"])
    else:
        global_paths["step4_godmd_prep"]["input_pdb_target_path"] = global_paths["step1_extract_chain"]["output_structure_path"]
        global_paths["step5_godmd_run"]["input_pdb_target_path"] = global_paths["step1_extract_chain"]["output_structure_path"]

    global_log.info("step4_godmd_prep: Computing the mapping")
    godmd_prep(**global_paths["step4_godmd_prep"], properties=global_prop["step4_godmd_prep"])

    global_log.info("step5_godmd_run: Running GOdMD")
    godmd_run(**global_paths["step5_godmd_run"], properties=global_prop["step5_godmd_run"])

    global_log.info("step6_cpptraj_convert: Converting trajectory to DCD ")
    cpptraj_convert(**global_paths["step6_cpptraj_convert"], properties=global_prop["step6_cpptraj_convert"])

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
