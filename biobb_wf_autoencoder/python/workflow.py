#!/usr/bin/env python3

import time
import argparse
from biobb_common.configuration import settings
from biobb_common.tools import file_utils as fu
from biobb_analysis.gromacs.gmx_image import gmx_image
from biobb_pytorch.mdae.mdfeaturizer import MDFeaturizer
from biobb_pytorch.mdae.build_model import buildModel
from biobb_pytorch.mdae.train_model import trainModel
from biobb_pytorch.mdae.evaluate_model import evaluateModel
from biobb_gromacs.gromacs.make_ndx import make_ndx
from biobb_analysis.gromacs.gmx_rmsf import gmx_rmsf
from biobb_pytorch.mdae.feat2traj import feat2traj
# from biobb_pytorch.mdae.make_plumed import generatePlumed


def main(config, system=None):
    start_time = time.time()
    conf = settings.ConfReader(config, system)
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    global_log.info("step1_gmx_image1: Fit the train trajectory to the apo structure")
    gmx_image(**global_paths["step1_gmx_image1"], properties=global_prop["step1_gmx_image1"])

    global_log.info("step2_mdfeaturizer1: Featurize the train trajectory")
    MDFeaturizer(**global_paths["step2_mdfeaturizer1"], properties=global_prop["step2_mdfeaturizer1"])

    global_log.info("step3_build_model: Build the model")
    buildModel(**global_paths["step3_build_model"], properties=global_prop["step3_build_model"])

    global_log.info("step4_train_model: Train the model")
    trainModel(**global_paths["step4_train_model"], properties=global_prop["step4_train_model"])

    global_log.info("step5_gmx_image2: Fit the test trajectory to the apo structure")
    gmx_image(**global_paths["step5_gmx_image2"], properties=global_prop["step5_gmx_image2"])

    global_log.info("step6_mdfeaturizer2: Featurize the test trajectory")
    MDFeaturizer(**global_paths["step6_mdfeaturizer2"], properties=global_prop["step6_mdfeaturizer2"])

    global_log.info("step7_evaluate_model: Evaluate the model")
    evaluateModel(**global_paths["step7_evaluate_model"], properties=global_prop["step7_evaluate_model"])

    global_log.info("step8_make_ndx1: Train Index NDX file generation")
    make_ndx(**global_paths["step8_make_ndx1"], properties=global_prop["step8_make_ndx1"])

    global_log.info("step9_make_ndx2: Test Index NDX file generation")
    make_ndx(**global_paths["step9_make_ndx2"], properties=global_prop["step9_make_ndx2"])

    global_log.info("step10_gmx_rmsf1: RMSF calculation Apo Trajectory")
    gmx_rmsf(**global_paths["step10_gmx_rmsf1"], properties=global_prop["step10_gmx_rmsf1"])

    global_log.info("step11_gmx_rmsf2: RMSF calculation Holo Trajectory")
    gmx_rmsf(**global_paths["step11_gmx_rmsf2"], properties=global_prop["step11_gmx_rmsf2"])

    global_log.info("step12_feat2traj: Dataset to Trajectory Conversion")
    feat2traj(**global_paths["step12_feat2traj"], properties=global_prop["step12_feat2traj"])

    global_log.info("step13_gmx_rmsf3: Original Holo vs Reconstructed Holo Trajectories")
    gmx_rmsf(**global_paths["step13_gmx_rmsf3"], properties=global_prop["step13_gmx_rmsf3"])

    # global_log.info("step14_generate_plumed: Extract CV & Generate Plumed File")
    # generatePlumed(**global_paths["step14_generate_plumed"], properties=global_prop["step14_generate_plumed"])

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
