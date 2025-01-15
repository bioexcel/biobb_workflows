#!/usr/bin/env python3

import time
import argparse
import zipfile
import os
from pathlib import Path, PurePath
from biobb_common.configuration import settings
from biobb_common.tools import file_utils as fu
from biobb_structure_utils.utils.extract_model import extract_model
from biobb_structure_utils.utils.extract_chain import extract_chain
from biobb_analysis.ambertools.cpptraj_mask import cpptraj_mask
from biobb_flexdyn.flexdyn.concoord_dist import concoord_dist
from biobb_flexdyn.flexdyn.concoord_disco import concoord_disco
from biobb_analysis.ambertools.cpptraj_rms import cpptraj_rms
from biobb_analysis.ambertools.cpptraj_convert import cpptraj_convert
from biobb_flexdyn.flexdyn.prody_anm import prody_anm
from biobb_flexserv.flexserv.bd_run import bd_run
from biobb_flexserv.flexserv.dmd_run import dmd_run
from biobb_flexserv.flexserv.nma_run import nma_run
from biobb_flexdyn.flexdyn.nolb_nma import nolb_nma
from biobb_flexdyn.flexdyn.imod_imode import imod_imode
from biobb_flexdyn.flexdyn.imod_imc import imod_imc
from biobb_gromacs.gromacs.make_ndx import make_ndx
from biobb_gromacs.gromacs.trjcat import trjcat
from biobb_analysis.gromacs.gmx_cluster import gmx_cluster
from biobb_flexserv.pcasuite.pcz_zip import pcz_zip
from biobb_flexserv.pcasuite.pcz_info import pcz_info
from biobb_flexserv.pcasuite.pcz_evecs import pcz_evecs
from biobb_flexserv.pcasuite.pcz_animate import pcz_animate
from biobb_flexserv.pcasuite.pcz_bfactor import pcz_bfactor
from biobb_flexserv.pcasuite.pcz_hinges import pcz_hinges
from biobb_flexserv.pcasuite.pcz_stiffness import pcz_stiffness
from biobb_flexserv.pcasuite.pcz_collectivity import pcz_collectivity


def main(config, system=None):
    start_time = time.time()
    conf = settings.ConfReader(config, system)
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    global_log.info("step0_extract_model: Selecting a model")
    extract_model(**global_paths["step0_extract_model"], properties=global_prop["step0_extract_model"])

    global_log.info("step1_extract_chain: Selecting a monomer")
    extract_chain(**global_paths["step1_extract_chain"], properties=global_prop["step1_extract_chain"])

    global_log.info("step2_cpptraj_mask: Generating the reduced (coarse-grained) structure (backbone)")
    cpptraj_mask(**global_paths["step2_cpptraj_mask"], properties=global_prop["step2_cpptraj_mask"])

    global_log.info("step3_cpptraj_mask: Generating the reduced (coarse-grained) structure (alpha carbons)")
    cpptraj_mask(**global_paths["step3_cpptraj_mask"], properties=global_prop["step3_cpptraj_mask"])

    props = global_prop["step4_concoord_dist"]
    props["env_vars_dict"]["CONCOORDLIB"] = os.getenv('CONDA_PREFIX') + '/share/concoord/lib'

    global_log.info("step4_concoord_dist: CONCOORD dist")
    concoord_dist(**global_paths["step4_concoord_dist"], properties=props)

    props = global_prop["step5_concoord_disco"]
    props["env_vars_dict"]["CONCOORDLIB"] = os.getenv('CONDA_PREFIX') + '/share/concoord/lib'

    global_log.info("step5_concoord_disco: CONCOORD disco")
    concoord_disco(**global_paths["step5_concoord_disco"], properties=props)

    global_log.info("step6_cpptraj_rms: RMSd distribution of the generated ensemble (CONCOORD)")
    cpptraj_rms(**global_paths["step6_cpptraj_rms"], properties=global_prop["step6_cpptraj_rms"])

    global_log.info("step7_cpptraj_convert: Converting the generated ensemble (CONCOORD)")
    cpptraj_convert(**global_paths["step7_cpptraj_convert"], properties=global_prop["step7_cpptraj_convert"])

    global_log.info("step8_prody_anm: PRODY Anisotropic network model")
    prody_anm(**global_paths["step8_prody_anm"], properties=global_prop["step8_prody_anm"])

    global_log.info("step9_cpptraj_rms: RMSd distribution of the generated ensemble (PRODY)")
    cpptraj_rms(**global_paths["step9_cpptraj_rms"], properties=global_prop["step9_cpptraj_rms"])

    global_log.info("step10_cpptraj_convert: Converting the generated ensemble (PRODY)")
    cpptraj_convert(**global_paths["step10_cpptraj_convert"], properties=global_prop["step10_cpptraj_convert"])

    global_log.info("step11_bd_run: Brownian Dynamics (BD)")
    bd_run(**global_paths["step11_bd_run"], properties=global_prop["step11_bd_run"])

    global_log.info("step12_cpptraj_rms: Fitting and converting the generated ensemble (BD)")
    cpptraj_rms(**global_paths["step12_cpptraj_rms"], properties=global_prop["step12_cpptraj_rms"])

    global_log.info("step13_dmd_run: Discrete Molecular Dynamics (DMD)")
    dmd_run(**global_paths["step13_dmd_run"], properties=global_prop["step13_dmd_run"])

    global_log.info("step14_cpptraj_rms: RMSd distribution of the generated ensemble (DMD)")
    cpptraj_rms(**global_paths["step14_cpptraj_rms"], properties=global_prop["step14_cpptraj_rms"])

    global_log.info("step15_nma_run: Normal Mode Analysis (NMA)")
    nma_run(**global_paths["step15_nma_run"], properties=global_prop["step15_nma_run"])

    global_log.info("step16_cpptraj_rms: RMSd distribution of the generated ensemble (NMA)")
    cpptraj_rms(**global_paths["step16_cpptraj_rms"], properties=global_prop["step16_cpptraj_rms"])

    global_log.info("step17_cpptraj_convert: Converting the generated ensemble (NMA)")
    cpptraj_convert(**global_paths["step17_cpptraj_convert"], properties=global_prop["step17_cpptraj_convert"])

    global_log.info("step18_nolb_nma: NOn-Linear rigid Block NMA approach (NOLB)")
    nolb_nma(**global_paths["step18_nolb_nma"], properties=global_prop["step18_nolb_nma"])

    global_log.info("step19_cpptraj_rms: RMSd distribution of the generated ensemble (NOLB)")
    cpptraj_rms(**global_paths["step19_cpptraj_rms"], properties=global_prop["step19_cpptraj_rms"])

    global_log.info("step20_cpptraj_convert: Converting the generated ensemble (NOLB)")
    cpptraj_convert(**global_paths["step20_cpptraj_convert"], properties=global_prop["step20_cpptraj_convert"])

    global_log.info("step21_imod_imode: iMOD imode")
    imod_imode(**global_paths["step21_imod_imode"], properties=global_prop["step21_imod_imode"])

    global_log.info("step22_imod_imc: iMOD imc")
    imod_imc(**global_paths["step22_imod_imc"], properties=global_prop["step22_imod_imc"])

    global_log.info("step23_cpptraj_rms: RMSd distribution of the generated ensemble (iMOD)")
    cpptraj_rms(**global_paths["step23_cpptraj_rms"], properties=global_prop["step23_cpptraj_rms"])

    global_log.info("step24_cpptraj_convert: Converting the generated ensemble (iMOD)")
    cpptraj_convert(**global_paths["step24_cpptraj_convert"], properties=global_prop["step24_cpptraj_convert"])

    global_log.info("Compressing trajectories")
    traj_zip = "structure_concat_traj.zip"
    traj_list = [global_paths["step7_cpptraj_convert"]["output_cpptraj_path"],
                 global_paths["step10_cpptraj_convert"]["output_cpptraj_path"],
                 global_paths["step24_cpptraj_convert"]["output_cpptraj_path"],
                 global_paths["step12_cpptraj_rms"]["output_traj_path"],
                 global_paths["step17_cpptraj_convert"]["output_cpptraj_path"]]
    with zipfile.ZipFile(traj_zip, 'w') as myzip:
        for file in traj_list:
            myzip.write(file, PurePath(file).name, compress_type=zipfile.ZIP_DEFLATED)

    paths = global_paths["step25_trjcat"]
    paths["input_trj_zip_path"] = PurePath(Path().absolute()).joinpath(traj_zip)
    global_log.info("step25_trjcat: Building the meta-trajectory")
    trjcat(**paths, properties=global_prop["step25_trjcat"])

    global_log.info("step26_make_ndx: Clustering the meta-trajectory: make index")
    make_ndx(**global_paths["step26_make_ndx"], properties=global_prop["step26_make_ndx"])

    global_log.info("step27_gmx_cluster: Clustering the meta-trajectory: clustering")
    gmx_cluster(**global_paths["step27_gmx_cluster"], properties=global_prop["step27_gmx_cluster"])

    global_log.info("step28_cpptraj_rms: Fitting and converting the generated ensemble (meta-trajectory)")
    cpptraj_rms(**global_paths["step28_cpptraj_rms"], properties=global_prop["step28_cpptraj_rms"])

    global_log.info("step29_pcz_zip: Computing the Principal Component Analysis (PCA) - ensemble")
    pcz_zip(**global_paths["step29_pcz_zip"], properties=global_prop["step29_pcz_zip"])

    global_log.info("step30_pcz_zip: Computing the Principal Component Analysis (PCA) - ensemble gaussian")
    pcz_zip(**global_paths["step30_pcz_zip"], properties=global_prop["step30_pcz_zip"])

    global_log.info("step31_pcz_info: Analysing the PCA report")
    pcz_info(**global_paths["step31_pcz_info"], properties=global_prop["step31_pcz_info"])

    global_log.info("step32_pcz_evecs: PCA Eigenvectors & Eigenvalues")
    pcz_evecs(**global_paths["step32_pcz_evecs"], properties=global_prop["step32_pcz_evecs"])

    global_log.info("step33_pcz_animate: Animate Principal Components")
    pcz_animate(**global_paths["step33_pcz_animate"], properties=global_prop["step33_pcz_animate"])

    global_log.info("step34_cpptraj_convert: Converting the generated ensemble (PCA)")
    cpptraj_convert(**global_paths["step34_cpptraj_convert"], properties=global_prop["step34_cpptraj_convert"])

    global_log.info("step35_pcz_bfactor: B-Factor x Principal Components")
    pcz_bfactor(**global_paths["step35_pcz_bfactor"], properties=global_prop["step35_pcz_bfactor"])

    global_log.info("step36_pcz_hinges: Hinge Points Prediction - Bfactor_slope")
    pcz_hinges(**global_paths["step36_pcz_hinges"], properties=global_prop["step36_pcz_hinges"])

    global_log.info("step37_pcz_hinges: Hinge Points Prediction - Dynamic_domain")
    pcz_hinges(**global_paths["step37_pcz_hinges"], properties=global_prop["step37_pcz_hinges"])

    global_log.info("step38_pcz_hinges: Hinge Points Prediction - Force_constant")
    pcz_hinges(**global_paths["step38_pcz_hinges"], properties=global_prop["step38_pcz_hinges"])

    global_log.info("step39_pcz_stiffness: Apparent Stiffness")
    pcz_stiffness(**global_paths["step39_pcz_stiffness"], properties=global_prop["step39_pcz_stiffness"])

    global_log.info("step40_pcz_collectivity: Collectivity Index")
    pcz_collectivity(**global_paths["step40_pcz_collectivity"], properties=global_prop["step40_pcz_collectivity"])

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
