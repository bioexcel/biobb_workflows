import pytest
import glob
from pathlib import Path
from biobb_common.configuration import settings
from biobb_common.tools import file_utils as fu
from biobb_common.tools import test_fixtures as fx
from biobb_vs.fpocket.fpocket_select import fpocket_select
from biobb_vs.utils.box import box
from biobb_chemistry.babelm.babel_convert import babel_convert
from biobb_structure_utils.utils.str_check_add_hydrogens import str_check_add_hydrogens
from biobb_vs.vina.autodock_vina_run import autodock_vina_run

global_work_dir = None


def step1_fpocket_select(config, system=None):
    conf = settings.ConfReader(config, system)
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    fpocket_select(**global_paths["step1_fpocket_select"], properties=global_prop["step1_fpocket_select"])

    assert fx.not_empty(global_paths["step1_fpocket_select"]["output_pocket_pdb"])
    assert fx.not_empty(global_paths["step1_fpocket_select"]["output_pocket_pqr"])

    global global_work_dir
    global_work_dir = conf.get_working_dir_path()


def step2_box(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    box(**global_paths["step2_box"], properties=global_prop["step2_box"])

    assert fx.not_empty(global_paths["step2_box"]["output_pdb_path"])


def step3_babel_convert_prep_lig(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    babel_convert(**global_paths["step3_babel_convert_prep_lig"], properties=global_prop["step3_babel_convert_prep_lig"])

    assert fx.not_empty(global_paths["step3_babel_convert_prep_lig"]["output_path"])


def step4_str_check_add_hydrogens(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    str_check_add_hydrogens(**global_paths["step4_str_check_add_hydrogens"], properties=global_prop["step4_str_check_add_hydrogens"])

    assert fx.not_empty(global_paths["step4_str_check_add_hydrogens"]["output_structure_path"])


def step5_autodock_vina_run(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    autodock_vina_run(**global_paths["step5_autodock_vina_run"], properties=global_prop["step5_autodock_vina_run"])

    assert fx.not_empty(global_paths["step5_autodock_vina_run"]["output_pdbqt_path"])
    assert fx.not_empty(global_paths["step5_autodock_vina_run"]["output_log_path"])


def step6_babel_convert_pose_pdb(config, remove=False, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    babel_convert(**global_paths["step6_babel_convert_pose_pdb"], properties=global_prop["step6_babel_convert_pose_pdb"])

    assert fx.not_empty(global_paths["step6_babel_convert_pose_pdb"]["output_path"])
    assert fx.compare_size(global_paths["step6_babel_convert_pose_pdb"]["output_path"], f'reference/step6_babel_convert_pose_pdb/{Path(global_paths["step6_babel_convert_pose_pdb"]["output_path"]).name}', .9)

    if remove:
        tmp_files = [conf.get_working_dir_path()]
        tmp_files.extend(glob.glob('sandbox_*'))
        fu.rm_file_list(tmp_files)


@pytest.mark.parametrize("system", [None])
def test_step1_fpocket_select(config_path, system):
    step1_fpocket_select(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step2_box(config_path, system):
    step2_box(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step3_babel_convert_prep_lig(config_path, system):
    step3_babel_convert_prep_lig(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step4_str_check_add_hydrogens(config_path, system):
    step4_str_check_add_hydrogens(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step5_autodock_vina_run(config_path, system):
    step5_autodock_vina_run(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step6_babel_convert_pose_pdb(config_path, remove_flag, system):
    step6_babel_convert_pose_pdb(config_path, remove_flag, system)
