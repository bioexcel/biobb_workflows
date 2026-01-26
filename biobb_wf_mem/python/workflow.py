#!/usr/bin/env python3

import time
import argparse
from biobb_common.configuration import settings
from biobb_common.tools import file_utils as fu
from biobb_analysis.gromacs.gmx_image import gmx_image
from biobb_mem.fatslim.fatslim_membranes import fatslim_membranes
from biobb_mem.lipyphilic_biobb.lpp_assign_leaflets import lpp_assign_leaflets
from biobb_mem.lipyphilic_biobb.lpp_zpositions import lpp_zpositions
from biobb_mem.gorder.gorder_aa import gorder_aa
from biobb_mem.fatslim.fatslim_apl import fatslim_apl
from biobb_mem.ambertools.cpptraj_density import cpptraj_density
from biobb_mem.mdanalysis_biobb.mda_hole import mda_hole
from biobb_mem.lipyphilic_biobb.lpp_flip_flop import lpp_flip_flop


def main(config, system=None):
    start_time = time.time()
    conf = settings.ConfReader(config, system)
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    global_log.info("step1_gmx_image1: Fit the trajectory to the membrane")
    gmx_image(**global_paths["step1_gmx_image1"], properties=global_prop["step1_gmx_image1"])

    global_log.info("step2_gmx_image2: Fit again transxy to the protein")
    gmx_image(**global_paths["step2_gmx_image2"], properties=global_prop["step2_gmx_image2"])

    global_log.info("step3_fatslim_membranes: Membrane leaflets identification and GROMACS index file generatation")
    fatslim_membranes(**global_paths["step3_fatslim_membranes"], properties=global_prop["step3_fatslim_membranes"])

    global_log.info("step4_lpp_assign_leaflets: Assign leafleats for every frame")
    lpp_assign_leaflets(**global_paths["step4_lpp_assign_leaflets"], properties=global_prop["step4_lpp_assign_leaflets"])

    global_log.info("step5_lpp_zpositions1: Computing z-positions for the whole membrane")
    lpp_zpositions(**global_paths["step5_lpp_zpositions1"], properties=global_prop["step5_lpp_zpositions1"])

    global_log.info("step6_lpp_zpositions2: Computing z-positions for the selection around the protein")
    lpp_zpositions(**global_paths["step6_lpp_zpositions2"], properties=global_prop["step6_lpp_zpositions2"])

    global_log.info("step7_gorder_aa: Calculating deuterium order parameter of acyl tails in a lipid bilayer")
    gorder_aa(**global_paths["step7_gorder_aa"], properties=global_prop["step7_gorder_aa"])

    global_log.info("step8_fatslim_apl: Removing the area corresponding to protein molecules")
    fatslim_apl(**global_paths["step8_fatslim_apl"], properties=global_prop["step8_fatslim_apl"])

    global_log.info("step9_cpptraj_density: Calculating membrane density")
    cpptraj_density(**global_paths["step9_cpptraj_density"], properties=global_prop["step9_cpptraj_density"])

    global_log.info("step10_mda_hole: Identifying channels and analyze dimensions and properties along them")
    mda_hole(**global_paths["step10_mda_hole"], properties=global_prop["step10_mda_hole"])

    global_log.info("step11_lpp_flip_flop: Detecting the flip-flop of molecules in a lipid bilayer")
    lpp_flip_flop(**global_paths["step11_lpp_flip_flop"], properties=global_prop["step11_lpp_flip_flop"])

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
