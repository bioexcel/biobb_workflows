#!/usr/bin/env python3

import time
import argparse
from biobb_common.configuration import settings
from biobb_common.tools import file_utils as fu
from biobb_chemistry.babelm.babel_minimize import babel_minimize
from biobb_chemistry.acpype.acpype_params_gmx import acpype_params_gmx

def main(config, system=None):
    start_time = time.time()
    conf = settings.ConfReader(config, system)
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    global_log.info("step2_babel_minimize: Energetically minimize hydrogen atoms")
    babel_minimize(**global_paths["step2_babel_minimize"], properties=global_prop["step2_babel_minimize"])

    global_log.info("step3_acpype_params_gmx: Generating ligand parameters")
    acpype_params_gmx(**global_paths["step3_acpype_params_gmx"], properties=global_prop["step3_acpype_params_gmx"])

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
    parser = argparse.ArgumentParser(description="Automatic Ligand parameterization tutorial using BioExcel Building Blocks")
    parser.add_argument('--config', required=True)
    parser.add_argument('--system', required=False)
    args = parser.parse_args()
    main(args.config, args.system)
