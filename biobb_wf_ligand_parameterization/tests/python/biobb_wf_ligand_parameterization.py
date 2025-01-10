import pytest
import glob
from pathlib import Path
from biobb_common.configuration import settings
from biobb_common.tools import file_utils as fu
from biobb_common.tools import test_fixtures as fx
from biobb_chemistry.babelm.babel_minimize import babel_minimize
from biobb_chemistry.acpype.acpype_params_gmx import acpype_params_gmx

global_work_dir = None


def step2_babel_minimize(config, system=None):
    conf = settings.ConfReader(config, system)
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    babel_minimize(**global_paths["step2_babel_minimize"], properties=global_prop["step2_babel_minimize"])

    assert fx.not_empty(global_paths["step2_babel_minimize"]["output_path"])
    assert fx.equal(global_paths["step2_babel_minimize"]["output_path"], f'reference/step2_babel_minimize/{Path(global_paths["step2_babel_minimize"]["output_path"]).name}')

    global global_work_dir
    global_work_dir = conf.get_working_dir_path()


def step3_acpype_params_gmx(config, remove=False, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    acpype_params_gmx(**global_paths["step3_acpype_params_gmx"], properties=global_prop["step3_acpype_params_gmx"])

    assert fx.not_empty(global_paths["step3_acpype_params_gmx"]["output_path_gro"])
    assert fx.equal(global_paths["step3_acpype_params_gmx"]["output_path_gro"], f'reference/step3_acpype_params_gmx/{Path(global_paths["step3_acpype_params_gmx"]["output_path_gro"]).name}')
    assert fx.not_empty(global_paths["step3_acpype_params_gmx"]["output_path_itp"])
    assert fx.equal(global_paths["step3_acpype_params_gmx"]["output_path_itp"], f'reference/step3_acpype_params_gmx/{Path(global_paths["step3_acpype_params_gmx"]["output_path_itp"]).name}')
    assert fx.not_empty(global_paths["step3_acpype_params_gmx"]["output_path_top"])
    assert fx.equal(global_paths["step3_acpype_params_gmx"]["output_path_top"], f'reference/step3_acpype_params_gmx/{Path(global_paths["step3_acpype_params_gmx"]["output_path_top"]).name}')

    if remove:
        tmp_files = [conf.get_working_dir_path()]
        tmp_files.extend(glob.glob('sandbox_*'))
        tmp_files.extend(glob.glob('biobb_GMX_LP*'))
        fu.rm_file_list(tmp_files)


@pytest.mark.parametrize("system", [None])
def test_step2_babel_minimize(config_path, system):
    step2_babel_minimize(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step3_acpype_params_gmx(config_path, remove_flag, system):
    step3_acpype_params_gmx(config_path, remove_flag, system)
