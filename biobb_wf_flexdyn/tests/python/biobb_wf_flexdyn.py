import pytest
# import glob
import os
import zipfile
from pathlib import Path, PurePath
from biobb_common.configuration import settings
from biobb_common.tools import file_utils as fu
from biobb_common.tools import test_fixtures as fx
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

global_work_dir = None


def step0_extract_model(config, system=None):
    conf = settings.ConfReader(config, system)
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    extract_model(**global_paths["step0_extract_model"], properties=global_prop["step0_extract_model"])

    assert fx.not_empty(global_paths["step0_extract_model"]["output_structure_path"])

    global global_work_dir
    global_work_dir = conf.get_working_dir_path()


def step1_extract_chain(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    extract_chain(**global_paths["step1_extract_chain"], properties=global_prop["step1_extract_chain"])

    assert fx.not_empty(global_paths["step1_extract_chain"]["output_structure_path"])


def step2_cpptraj_mask(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    cpptraj_mask(**global_paths["step2_cpptraj_mask"], properties=global_prop["step2_cpptraj_mask"])

    assert fx.not_empty(global_paths["step2_cpptraj_mask"]["output_cpptraj_path"])


def step3_cpptraj_mask(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    cpptraj_mask(**global_paths["step3_cpptraj_mask"], properties=global_prop["step3_cpptraj_mask"])

    assert fx.not_empty(global_paths["step3_cpptraj_mask"]["output_cpptraj_path"])


def step4_concoord_dist(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    props = global_prop["step4_concoord_dist"]
    props["env_vars_dict"]["CONCOORDLIB"] = os.getenv('CONDA_PREFIX') + '/share/concoord/lib'
    concoord_dist(**global_paths["step4_concoord_dist"], properties=props)

    assert fx.not_empty(global_paths["step4_concoord_dist"]["output_pdb_path"])
    assert fx.not_empty(global_paths["step4_concoord_dist"]["output_gro_path"])
    assert fx.not_empty(global_paths["step4_concoord_dist"]["output_dat_path"])


def step5_concoord_disco(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    props = global_prop["step5_concoord_disco"]
    props["env_vars_dict"]["CONCOORDLIB"] = os.getenv('CONDA_PREFIX') + '/share/concoord/lib'
    concoord_disco(**global_paths["step5_concoord_disco"], properties=props)

    assert fx.not_empty(global_paths["step5_concoord_disco"]["output_traj_path"])
    assert fx.not_empty(global_paths["step5_concoord_disco"]["output_rmsd_path"])
    assert fx.not_empty(global_paths["step5_concoord_disco"]["output_bfactor_path"])


def step6_cpptraj_rms(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    cpptraj_rms(**global_paths["step6_cpptraj_rms"], properties=global_prop["step6_cpptraj_rms"])

    assert fx.not_empty(global_paths["step6_cpptraj_rms"]["output_cpptraj_path"])


def step7_cpptraj_convert(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    cpptraj_convert(**global_paths["step7_cpptraj_convert"], properties=global_prop["step7_cpptraj_convert"])

    assert fx.not_empty(global_paths["step7_cpptraj_convert"]["output_cpptraj_path"])


def step8_prody_anm(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    prody_anm(**global_paths["step8_prody_anm"], properties=global_prop["step8_prody_anm"])

    assert fx.not_empty(global_paths["step8_prody_anm"]["output_pdb_path"])


def step9_cpptraj_rms(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    cpptraj_rms(**global_paths["step9_cpptraj_rms"], properties=global_prop["step9_cpptraj_rms"])

    assert fx.not_empty(global_paths["step9_cpptraj_rms"]["output_cpptraj_path"])


def step10_cpptraj_convert(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    cpptraj_convert(**global_paths["step10_cpptraj_convert"], properties=global_prop["step10_cpptraj_convert"])

    assert fx.not_empty(global_paths["step10_cpptraj_convert"]["output_cpptraj_path"])


def step11_bd_run(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    bd_run(**global_paths["step11_bd_run"], properties=global_prop["step11_bd_run"])

    assert fx.not_empty(global_paths["step11_bd_run"]["output_crd_path"])
    assert fx.not_empty(global_paths["step11_bd_run"]["output_log_path"])


def step12_cpptraj_rms(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    cpptraj_rms(**global_paths["step12_cpptraj_rms"], properties=global_prop["step12_cpptraj_rms"])

    assert fx.not_empty(global_paths["step12_cpptraj_rms"]["output_cpptraj_path"])
    assert fx.not_empty(global_paths["step12_cpptraj_rms"]["output_traj_path"])


def step13_dmd_run(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    dmd_run(**global_paths["step13_dmd_run"], properties=global_prop["step13_dmd_run"])

    assert fx.not_empty(global_paths["step13_dmd_run"]["output_crd_path"])
    assert fx.not_empty(global_paths["step13_dmd_run"]["output_log_path"])


def step14_cpptraj_rms(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    cpptraj_rms(**global_paths["step14_cpptraj_rms"], properties=global_prop["step14_cpptraj_rms"])

    assert fx.not_empty(global_paths["step14_cpptraj_rms"]["output_cpptraj_path"])
    assert fx.not_empty(global_paths["step14_cpptraj_rms"]["output_traj_path"])


def step15_nma_run(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    nma_run(**global_paths["step15_nma_run"], properties=global_prop["step15_nma_run"])

    assert fx.not_empty(global_paths["step15_nma_run"]["output_crd_path"])
    assert fx.not_empty(global_paths["step15_nma_run"]["output_log_path"])


def step16_cpptraj_rms(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    cpptraj_rms(**global_paths["step16_cpptraj_rms"], properties=global_prop["step16_cpptraj_rms"])

    assert fx.not_empty(global_paths["step16_cpptraj_rms"]["output_cpptraj_path"])


def step17_cpptraj_convert(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    cpptraj_convert(**global_paths["step17_cpptraj_convert"], properties=global_prop["step17_cpptraj_convert"])

    assert fx.not_empty(global_paths["step17_cpptraj_convert"]["output_cpptraj_path"])


def step18_nolb_nma(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    nolb_nma(**global_paths["step18_nolb_nma"], properties=global_prop["step18_nolb_nma"])

    assert fx.not_empty(global_paths["step18_nolb_nma"]["output_pdb_path"])


def step19_cpptraj_rms(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    cpptraj_rms(**global_paths["step19_cpptraj_rms"], properties=global_prop["step19_cpptraj_rms"])

    assert fx.not_empty(global_paths["step19_cpptraj_rms"]["output_cpptraj_path"])


def step20_cpptraj_convert(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    cpptraj_convert(**global_paths["step20_cpptraj_convert"], properties=global_prop["step20_cpptraj_convert"])

    assert fx.not_empty(global_paths["step20_cpptraj_convert"]["output_cpptraj_path"])


def step21_imod_imode(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    imod_imode(**global_paths["step21_imod_imode"], properties=global_prop["step21_imod_imode"])

    assert fx.not_empty(global_paths["step21_imod_imode"]["output_dat_path"])


def step22_imod_imc(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    imod_imc(**global_paths["step22_imod_imc"], properties=global_prop["step22_imod_imc"])

    assert fx.not_empty(global_paths["step22_imod_imc"]["output_traj_path"])


def step23_cpptraj_rms(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    cpptraj_rms(**global_paths["step23_cpptraj_rms"], properties=global_prop["step23_cpptraj_rms"])

    assert fx.not_empty(global_paths["step23_cpptraj_rms"]["output_cpptraj_path"])


def step24_cpptraj_convert(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    cpptraj_convert(**global_paths["step24_cpptraj_convert"], properties=global_prop["step24_cpptraj_convert"])

    assert fx.not_empty(global_paths["step24_cpptraj_convert"]["output_cpptraj_path"])


def step25_trjcat(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

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
    trjcat(**paths, properties=global_prop["step25_trjcat"])

    assert fx.not_empty(global_paths["step25_trjcat"]["output_trj_path"])


def step26_make_ndx(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    make_ndx(**global_paths["step26_make_ndx"], properties=global_prop["step26_make_ndx"])

    assert fx.not_empty(global_paths["step26_make_ndx"]["output_ndx_path"])


def step27_gmx_cluster(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    gmx_cluster(**global_paths["step27_gmx_cluster"], properties=global_prop["step27_gmx_cluster"])

    assert fx.not_empty(global_paths["step27_gmx_cluster"]["output_pdb_path"])


def step28_cpptraj_rms(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    cpptraj_rms(**global_paths["step28_cpptraj_rms"], properties=global_prop["step28_cpptraj_rms"])

    assert fx.not_empty(global_paths["step28_cpptraj_rms"]["output_cpptraj_path"])
    assert fx.not_empty(global_paths["step28_cpptraj_rms"]["output_traj_path"])


def step29_pcz_zip(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    pcz_zip(**global_paths["step29_pcz_zip"], properties=global_prop["step29_pcz_zip"])

    assert fx.not_empty(global_paths["step29_pcz_zip"]["output_pcz_path"])


def step30_pcz_zip(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    pcz_zip(**global_paths["step30_pcz_zip"], properties=global_prop["step30_pcz_zip"])

    assert fx.not_empty(global_paths["step30_pcz_zip"]["output_pcz_path"])


def step31_pcz_info(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    pcz_info(**global_paths["step31_pcz_info"], properties=global_prop["step31_pcz_info"])

    assert fx.not_empty(global_paths["step31_pcz_info"]["output_json_path"])


def step32_pcz_evecs(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    pcz_evecs(**global_paths["step32_pcz_evecs"], properties=global_prop["step32_pcz_evecs"])

    assert fx.not_empty(global_paths["step32_pcz_evecs"]["output_json_path"])


def step33_pcz_animate(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    pcz_animate(**global_paths["step33_pcz_animate"], properties=global_prop["step33_pcz_animate"])

    assert fx.not_empty(global_paths["step33_pcz_animate"]["output_crd_path"])


def step34_cpptraj_convert(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    cpptraj_convert(**global_paths["step34_cpptraj_convert"], properties=global_prop["step34_cpptraj_convert"])

    assert fx.not_empty(global_paths["step34_cpptraj_convert"]["output_cpptraj_path"])


def step35_pcz_bfactor(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    pcz_bfactor(**global_paths["step35_pcz_bfactor"], properties=global_prop["step35_pcz_bfactor"])

    assert fx.not_empty(global_paths["step35_pcz_bfactor"]["output_dat_path"])
    assert fx.not_empty(global_paths["step35_pcz_bfactor"]["output_pdb_path"])


def step36_pcz_hinges(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    pcz_hinges(**global_paths["step36_pcz_hinges"], properties=global_prop["step36_pcz_hinges"])

    assert fx.not_empty(global_paths["step36_pcz_hinges"]["output_json_path"])


def step37_pcz_hinges(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    pcz_hinges(**global_paths["step37_pcz_hinges"], properties=global_prop["step37_pcz_hinges"])

    assert fx.not_empty(global_paths["step37_pcz_hinges"]["output_json_path"])


def step38_pcz_hinges(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    pcz_hinges(**global_paths["step38_pcz_hinges"], properties=global_prop["step38_pcz_hinges"])

    assert fx.not_empty(global_paths["step38_pcz_hinges"]["output_json_path"])


def step39_pcz_stiffness(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    pcz_stiffness(**global_paths["step39_pcz_stiffness"], properties=global_prop["step39_pcz_stiffness"])

    assert fx.not_empty(global_paths["step39_pcz_stiffness"]["output_json_path"])


def step40_pcz_collectivity(config, remove=False, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    pcz_collectivity(**global_paths["step40_pcz_collectivity"], properties=global_prop["step40_pcz_collectivity"])

    assert fx.not_empty(global_paths["step40_pcz_collectivity"]["output_json_path"])
    assert fx.compare_size(global_paths["step40_pcz_collectivity"]["output_json_path"], f'reference/step40_pcz_collectivity/{Path(global_paths["step40_pcz_collectivity"]["output_json_path"]).name}', 10)

    if remove:
        tmp_files = [conf.get_working_dir_path(), 'structure_concat_traj.zip', 'distancia.dat', 'eigenvec.dat', 'file.proj', 'hessian.dat', 'masses.dat', 'molecula.out', 'molecula.pdb', 'output.pdb', 'snapshots.pdb']
        fu.rm_file_list(tmp_files)


@pytest.mark.parametrize("system", [None])
def test_step0_extract_model(config_path, system):
    step0_extract_model(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step1_extract_chain(config_path, system):
    step1_extract_chain(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step2_cpptraj_mask(config_path, system):
    step2_cpptraj_mask(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step3_cpptraj_mask(config_path, system):
    step3_cpptraj_mask(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step4_concoord_dist(config_path, system):
    step4_concoord_dist(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step5_concoord_disco(config_path, system):
    step5_concoord_disco(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step6_cpptraj_rms(config_path, system):
    step6_cpptraj_rms(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step7_cpptraj_convert(config_path, system):
    step7_cpptraj_convert(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step8_prody_anm(config_path, system):
    step8_prody_anm(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step9_cpptraj_rms(config_path, system):
    step9_cpptraj_rms(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step10_cpptraj_convert(config_path, system):
    step10_cpptraj_convert(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step11_bd_run(config_path, system):
    step11_bd_run(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step12_cpptraj_rms(config_path, system):
    step12_cpptraj_rms(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step13_dmd_run(config_path, system):
    step13_dmd_run(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step14_cpptraj_rms(config_path, system):
    step14_cpptraj_rms(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step15_nma_run(config_path, system):
    step15_nma_run(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step16_cpptraj_rms(config_path, system):
    step16_cpptraj_rms(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step17_cpptraj_convert(config_path, system):
    step17_cpptraj_convert(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step18_nolb_nma(config_path, system):
    step18_nolb_nma(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step19_cpptraj_rms(config_path, system):
    step19_cpptraj_rms(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step20_cpptraj_convert(config_path, system):
    step20_cpptraj_convert(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step21_imod_imode(config_path, system):
    step21_imod_imode(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step22_imod_imc(config_path, system):
    step22_imod_imc(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step23_cpptraj_rms(config_path, system):
    step23_cpptraj_rms(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step24_cpptraj_convert(config_path, system):
    step24_cpptraj_convert(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step25_trjcat(config_path, system):
    step25_trjcat(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step26_make_ndx(config_path, system):
    step26_make_ndx(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step27_gmx_cluster(config_path, system):
    step27_gmx_cluster(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step28_cpptraj_rms(config_path, system):
    step28_cpptraj_rms(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step29_pcz_zip(config_path, system):
    step29_pcz_zip(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step30_pcz_zip(config_path, system):
    step30_pcz_zip(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step31_pcz_info(config_path, system):
    step31_pcz_info(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step32_pcz_evecs(config_path, system):
    step32_pcz_evecs(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step33_pcz_animate(config_path, system):
    step33_pcz_animate(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step34_cpptraj_convert(config_path, system):
    step34_cpptraj_convert(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step35_pcz_bfactor(config_path, system):
    step35_pcz_bfactor(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step36_pcz_hinges(config_path, system):
    step36_pcz_hinges(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step37_pcz_hinges(config_path, system):
    step37_pcz_hinges(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step38_pcz_hinges(config_path, system):
    step38_pcz_hinges(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step39_pcz_stiffness(config_path, system):
    step39_pcz_stiffness(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step40_pcz_collectivity(config_path, remove_flag, system):
    step40_pcz_collectivity(config_path, remove_flag, system)
