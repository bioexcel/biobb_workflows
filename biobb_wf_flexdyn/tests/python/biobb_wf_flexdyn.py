import pytest
import glob
import os
from pathlib import Path
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
    assert fx.equal(global_paths["step0_extract_model"]["output_structure_path"], f'reference/step0_extract_model/{Path(global_paths["step0_extract_model"]["output_structure_path"]).name}')

    global global_work_dir
    global_work_dir = conf.get_working_dir_path()


def step1_extract_chain(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    extract_chain(**global_paths["step1_extract_chain"], properties=global_prop["step1_extract_chain"])

    assert fx.not_empty(global_paths["step1_extract_chain"]["output_pdb_path"])
    assert fx.equal(global_paths["step1_extract_chain"]["output_pdb_path"], f'reference/step1_extract_chain/{Path(global_paths["step1_extract_chain"]["output_structure_path"]).name}')


def step2_cpptraj_mask(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    cpptraj_mask(**global_paths["step2_cpptraj_mask"], properties=global_prop["step2_cpptraj_mask"])

    assert fx.not_empty(global_paths["step2_cpptraj_mask"]["output_cpptraj_path"])
    assert fx.equal(global_paths["step2_cpptraj_mask"]["output_cpptraj_path"], f'reference/step2_cpptraj_mask/{Path(global_paths["step2_cpptraj_mask"]["output_cpptraj_path"]).name}')


def step3_cpptraj_mask(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    cpptraj_mask(**global_paths["step3_cpptraj_mask"], properties=global_prop["step3_cpptraj_mask"])

    assert fx.not_empty(global_paths["step3_cpptraj_mask"]["output_cpptraj_path"])
    assert fx.equal(global_paths["step3_cpptraj_mask"]["output_cpptraj_path"], f'reference/step3_cpptraj_mask/{Path(global_paths["step3_cpptraj_mask"]["output_cpptraj_path"]).name}')


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
    assert fx.equal(global_paths["step4_concoord_dist"]["output_pdb_path"], f'reference/step4_concoord_dist/{Path(global_paths["step4_concoord_dist"]["output_pdb_path"]).name}')
    assert fx.not_empty(global_paths["step4_concoord_dist"]["output_gro_path"])
    assert fx.equal(global_paths["step4_concoord_dist"]["output_gro_path"], f'reference/step4_concoord_dist/{Path(global_paths["step4_concoord_dist"]["output_gro_path"]).name}')
    assert fx.not_empty(global_paths["step4_concoord_dist"]["output_dat_path"])
    assert fx.equal(global_paths["step4_concoord_dist"]["output_dat_path"], f'reference/step4_concoord_dist/{Path(global_paths["step4_concoord_dist"]["output_dat_path"]).name}')


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
    assert fx.equal(global_paths["step5_concoord_disco"]["output_traj_path"], f'reference/step5_concoord_disco/{Path(global_paths["step5_concoord_disco"]["output_traj_path"]).name}')
    assert fx.not_empty(global_paths["step5_concoord_disco"]["output_rmsd_path"])
    assert fx.equal(global_paths["step5_concoord_disco"]["output_rmsd_path"], f'reference/step5_concoord_disco/{Path(global_paths["step5_concoord_disco"]["output_rmsd_path"]).name}')
    assert fx.not_empty(global_paths["step5_concoord_disco"]["output_bfactor_path"])
    assert fx.equal(global_paths["step5_concoord_disco"]["output_bfactor_path"], f'reference/step5_concoord_disco/{Path(global_paths["step5_concoord_disco"]["output_bfactor_path"]).name}')


def step6_cpptraj_rms(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    cpptraj_rms(**global_paths["step6_cpptraj_rms"], properties=global_prop["step6_cpptraj_rms"])

    assert fx.not_empty(global_paths["step6_cpptraj_rms"]["output_cpptraj_path"])
    assert fx.equal(global_paths["step6_cpptraj_rms"]["output_cpptraj_path"], f'reference/step6_cpptraj_rms/{Path(global_paths["step6_cpptraj_rms"]["output_cpptraj_path"]).name}')


def step7_cpptraj_convert(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    cpptraj_convert(**global_paths["step7_cpptraj_convert"], properties=global_prop["step7_cpptraj_convert"])

    assert fx.not_empty(global_paths["step7_cpptraj_convert"]["output_cpptraj_path"])
    assert fx.equal(global_paths["step7_cpptraj_convert"]["output_cpptraj_path"], f'reference/step7_cpptraj_convert/{Path(global_paths["step7_cpptraj_convert"]["output_cpptraj_path"]).name}')


def step8_prody_anm(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    prody_anm(**global_paths["step8_prody_anm"], properties=global_prop["step8_prody_anm"])

    assert fx.not_empty(global_paths["step8_prody_anm"]["output_pdb_path"])
    assert fx.equal(global_paths["step8_prody_anm"]["output_pdb_path"], f'reference/step8_prody_anm/{Path(global_paths["step8_prody_anm"]["output_pdb_path"]).name}')


def step9_cpptraj_rms(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    cpptraj_rms(**global_paths["step9_cpptraj_rms"], properties=global_prop["step9_cpptraj_rms"])

    assert fx.not_empty(global_paths["step9_cpptraj_rms"]["output_cpptraj_path"])
    assert fx.equal(global_paths["step9_cpptraj_rms"]["output_cpptraj_path"], f'reference/step9_cpptraj_rms/{Path(global_paths["step9_cpptraj_rms"]["output_cpptraj_path"]).name}')


def step10_cpptraj_convert(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    cpptraj_convert(**global_paths["step10_cpptraj_convert"], properties=global_prop["step10_cpptraj_convert"])

    assert fx.not_empty(global_paths["step10_cpptraj_convert"]["output_cpptraj_path"])
    assert fx.equal(global_paths["step10_cpptraj_convert"]["output_cpptraj_path"], f'reference/step10_cpptraj_convert/{Path(global_paths["step10_cpptraj_convert"]["output_cpptraj_path"]).name}')


def step11_bd_run(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    bd_run(**global_paths["step11_bd_run"], properties=global_prop["step11_bd_run"])

    assert fx.not_empty(global_paths["step11_bd_run"]["output_crd_path"])
    assert fx.equal(global_paths["step11_bd_run"]["output_crd_path"], f'reference/step11_bd_run/{Path(global_paths["step11_bd_run"]["output_crd_path"]).name}')
    assert fx.not_empty(global_paths["step11_bd_run"]["output_log_path"])
    assert fx.equal(global_paths["step11_bd_run"]["output_log_path"], f'reference/step11_bd_run/{Path(global_paths["step11_bd_run"]["output_log_path"]).name}')


def step12_cpptraj_rms(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    cpptraj_rms(**global_paths["step12_cpptraj_rms"], properties=global_prop["step12_cpptraj_rms"])

    assert fx.not_empty(global_paths["step12_cpptraj_rms"]["output_cpptraj_path"])
    assert fx.equal(global_paths["step12_cpptraj_rms"]["output_cpptraj_path"], f'reference/step12_cpptraj_rms/{Path(global_paths["step12_cpptraj_rms"]["output_cpptraj_path"]).name}')
    assert fx.not_empty(global_paths["step12_cpptraj_rms"]["output_traj_path"])
    assert fx.equal(global_paths["step12_cpptraj_rms"]["output_traj_path"], f'reference/step12_cpptraj_rms/{Path(global_paths["step12_cpptraj_rms"]["output_traj_path"]).name}')


def step13_dmd_run(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    dmd_run(**global_paths["step13_dmd_run"], properties=global_prop["step13_dmd_run"])

    assert fx.not_empty(global_paths["step13_dmd_run"]["output_crd_path"])
    assert fx.equal(global_paths["step13_dmd_run"]["output_crd_path"], f'reference/step13_dmd_run/{Path(global_paths["step13_dmd_run"]["output_crd_path"]).name}')
    assert fx.not_empty(global_paths["step13_dmd_run"]["output_log_path"])
    assert fx.equal(global_paths["step13_dmd_run"]["output_log_path"], f'reference/step13_dmd_run/{Path(global_paths["step13_dmd_run"]["output_log_path"]).name}')



def step26_cmip_run_complex(config, remove=False, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    cmip_run(**global_paths["step26_cmip_run_complex"], properties=global_prop["step26_cmip_run_complex"])

    assert fx.not_empty(global_paths["step26_cmip_run_complex"]["output_log_path"])
    # assert fx.equal(global_paths["step26_cmip_run_complex"]["output_log_path"], f'reference/step26_cmip_run_complex/{Path(global_paths["step26_cmip_run_complex"]["output_log_path"]).name}')
    assert fx.not_empty(global_paths["step26_cmip_run_complex"]["output_json_box_path"])
    # assert fx.equal(global_paths["step26_cmip_run_complex"]["output_json_box_path"], f'reference/step26_cmip_run_complex/{Path(global_paths["step26_cmip_run_complex"]["output_json_box_path"]).name}')
    assert fx.not_empty(global_paths["step26_cmip_run_complex"]["output_json_external_box_path"])
    # assert fx.equal(global_paths["step26_cmip_run_complex"]["output_json_external_box_path"], f'reference/step26_cmip_run_complex/{Path(global_paths["step26_cmip_run_complex"]["output_json_external_box_path"]).name}')
    assert fx.not_empty(global_paths["step26_cmip_run_complex"]["output_byat_path"])
    # assert fx.equal(global_paths["step26_cmip_run_complex"]["output_byat_path"], f'reference/step26_cmip_run_complex/{Path(global_paths["step26_cmip_run_complex"]["output_byat_path"]).name}')

    if remove:
        tmp_files = [conf.get_working_dir_path(), 'fort.7', 'gridout', 'restart']
        tmp_files.extend(glob.glob('sandbox_*'))
        fu.rm_file_list(tmp_files)


@pytest.mark.parametrize("system", [None])
def test_step0_cmip_prepare_pdb(config_path, system):
    step0_cmip_prepare_pdb(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step1_cmip_titration(config_path, system):
    step1_cmip_titration(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step2_cat_pdb(config_path, system):
    step2_cat_pdb(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step3_cmip_run_pos(config_path, system):
    step3_cmip_run_pos(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step4_cmip_run_neg(config_path, system):
    step4_cmip_run_neg(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step5_cmip_run_neu(config_path, system):
    step5_cmip_run_neu(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step6_remove_pdb_water(config_path, system):
    step6_remove_pdb_water(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step7_extract_heteroatoms(config_path, system):
    step7_extract_heteroatoms(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step8_reduce_add_hydrogens(config_path, system):
    step8_reduce_add_hydrogens(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step9_acpype_params_ac(config_path, system):
    step9_acpype_params_ac(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step10_leap_gen_top(config_path, system):
    step10_leap_gen_top(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step11_sander_mdrun(config_path, system):
    step11_sander_mdrun(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step12_amber_to_pdb(config_path, system):
    step12_amber_to_pdb(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step13_cmip_prepare_structure(config_path, system):
    step13_cmip_prepare_structure(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step14_remove_ligand(config_path, system):
    step14_remove_ligand(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step15_cmip_ignore_residues(config_path, system):
    step15_cmip_ignore_residues(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step16_cmip_run_int_en(config_path, system):
    step16_cmip_run_int_en(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step17_cmip_prepare_structure(config_path, system):
    step17_cmip_prepare_structure(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step18_extract_chain_a(config_path, system):
    step18_extract_chain_a(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step19_extract_chain_b(config_path, system):
    step19_extract_chain_b(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step20_cmip_run_rbd(config_path, system):
    step20_cmip_run_rbd(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step21_cmip_run_hace2(config_path, system):
    step21_cmip_run_hace2(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step22_cmip_run_rbd_hace2(config_path, system):
    step22_cmip_run_rbd_hace2(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step23_cmip_ignore_residues_rbd(config_path, system):
    step23_cmip_ignore_residues_rbd(config_path, system)


# @pytest.mark.parametrize("system", [None])
# def test_step24_cmip_run_prot_prot(config_path, system):
#     step24_cmip_run_prot_prot(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step25_cmip_ignore_residues_hace2(config_path, system):
    step25_cmip_ignore_residues_hace2(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step26_cmip_run_complex(config_path, remove_flag, system):
    step26_cmip_run_complex(config_path, remove_flag, system)
