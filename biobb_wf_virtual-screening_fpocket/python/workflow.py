#!/usr/bin/env python3

import time
import argparse
from biobb_common.configuration import settings
from biobb_common.tools import file_utils as fu
from biobb_vs.fpocket.fpocket_select import fpocket_select
from biobb_vs.utils.box import box
from biobb_chemistry.babelm.babel_convert import babel_convert
from biobb_structure_utils.utils.str_check_add_hydrogens import str_check_add_hydrogens
from biobb_vs.vina.autodock_vina_run import autodock_vina_run


def main(config, system=None):
    start_time = time.time()
    conf = settings.ConfReader(config, system)
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    global_log.info("step1_fpocket_select: Extract pocket cavity")
    fpocket_select(**global_paths["step1_fpocket_select"], properties=global_prop["step1_fpocket_select"])

    global_log.info("step2_box: Generating cavity box")
    box(**global_paths["step2_box"], properties=global_prop["step2_box"])

    global_log.info("step3_babel_convert_prep_lig: Preparing small molecule (ligand) for docking")
    babel_convert(**global_paths["step3_babel_convert_prep_lig"], properties=global_prop["step3_babel_convert_prep_lig"])

    global_log.info("step4_str_check_add_hydrogens: Preparing target protein for docking")
    str_check_add_hydrogens(**global_paths["step4_str_check_add_hydrogens"], properties=global_prop["step4_str_check_add_hydrogens"])

    global_log.info("step5_autodock_vina_run: Running the docking")
    autodock_vina_run(**global_paths["step5_autodock_vina_run"], properties=global_prop["step5_autodock_vina_run"])

    global_log.info("step6_babel_convert_pose_pdb: Converting ligand pose to PDB format")
    babel_convert(**global_paths["step6_babel_convert_pose_pdb"], properties=global_prop["step6_babel_convert_pose_pdb"])

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
    parser = argparse.ArgumentParser(description="Protein-ligand Docking tutorial using BioExcel Building Blocks")
    parser.add_argument('--config', required=True)
    parser.add_argument('--system', required=False)
    args = parser.parse_args()
    main(args.config, args.system)
