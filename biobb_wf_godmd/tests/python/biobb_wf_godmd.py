import pytest
import glob
from pathlib import Path
from biobb_common.configuration import settings
from biobb_common.tools import file_utils as fu
from biobb_common.tools import test_fixtures as fx
from biobb_structure_utils.utils.extract_chain import extract_chain
from biobb_structure_utils.utils.remove_molecules import remove_molecules
from biobb_godmd.godmd.godmd_prep import godmd_prep
from biobb_godmd.godmd.godmd_run import godmd_run
from biobb_analysis.ambertools.cpptraj_convert import cpptraj_convert

global_work_dir = None


def step0_extract_chain(config, system=None):
    conf = settings.ConfReader(config, system)
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    extract_chain(**global_paths["step0_extract_chain"], properties=global_prop["step0_extract_chain"])

    assert fx.not_empty(global_paths["step0_extract_chain"]["output_structure_path"])
    assert fx.equal(global_paths["step0_extract_chain"]["output_structure_path"], f'reference/step0_extract_chain/{Path(global_paths["step0_extract_chain"]["output_structure_path"]).name}')

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
    assert fx.equal(global_paths["step1_extract_chain"]["output_structure_path"], f'reference/step1_extract_chain/{Path(global_paths["step1_extract_chain"]["output_structure_path"]).name}')


def step2_remove_molecules(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    remove_molecules(**global_paths["step2_remove_molecules"], properties=global_prop["step2_remove_molecules"])

    assert fx.not_empty(global_paths["step2_remove_molecules"]["output_molecules_path"])
    assert fx.equal(global_paths["step2_remove_molecules"]["output_molecules_path"], f'reference/step2_remove_molecules/{Path(global_paths["step2_remove_molecules"]["output_molecules_path"]).name}')


def step4_godmd_prep(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    global_paths["step4_godmd_prep"]["input_pdb_target_path"] = global_paths["step1_extract_chain"]["output_structure_path"]
    godmd_prep(**global_paths["step4_godmd_prep"], properties=global_prop["step4_godmd_prep"])

    assert fx.not_empty(global_paths["step4_godmd_prep"]["output_aln_orig_path"])
    assert fx.equal(global_paths["step4_godmd_prep"]["output_aln_orig_path"], f'reference/step4_godmd_prep/{Path(global_paths["step4_godmd_prep"]["output_aln_orig_path"]).name}')
    assert fx.not_empty(global_paths["step4_godmd_prep"]["output_aln_target_path"])
    assert fx.equal(global_paths["step4_godmd_prep"]["output_aln_target_path"], f'reference/step4_godmd_prep/{Path(global_paths["step4_godmd_prep"]["output_aln_target_path"]).name}')


def step5_godmd_run(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    global_paths["step5_godmd_run"]["input_pdb_target_path"] = global_paths["step1_extract_chain"]["output_structure_path"]
    godmd_run(**global_paths["step5_godmd_run"], properties=global_prop["step5_godmd_run"])

    assert fx.not_empty(global_paths["step5_godmd_run"]["output_log_path"])
    # assert fx.equal(global_paths["step5_godmd_run"]["output_log_path"], f'reference/step5_godmd_run/{Path(global_paths["step5_godmd_run"]["output_log_path"]).name}')
    assert fx.not_empty(global_paths["step5_godmd_run"]["output_ene_path"])
    assert fx.equal(global_paths["step5_godmd_run"]["output_ene_path"], f'reference/step5_godmd_run/{Path(global_paths["step5_godmd_run"]["output_ene_path"]).name}')
    assert fx.not_empty(global_paths["step5_godmd_run"]["output_trj_path"])
    assert fx.equal(global_paths["step5_godmd_run"]["output_trj_path"], f'reference/step5_godmd_run/{Path(global_paths["step5_godmd_run"]["output_trj_path"]).name}')
    assert fx.not_empty(global_paths["step5_godmd_run"]["output_pdb_path"])
    assert fx.equal(global_paths["step5_godmd_run"]["output_pdb_path"], f'reference/step5_godmd_run/{Path(global_paths["step5_godmd_run"]["output_pdb_path"]).name}')


def step6_cpptraj_convert(config, remove=False, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    cpptraj_convert(**global_paths["step6_cpptraj_convert"], properties=global_prop["step6_cpptraj_convert"])

    assert fx.not_empty(global_paths["step6_cpptraj_convert"]["output_cpptraj_path"])
    assert fx.equal(global_paths["step6_cpptraj_convert"]["output_cpptraj_path"], f'reference/step6_cpptraj_convert/{Path(global_paths["step6_cpptraj_convert"]["output_cpptraj_path"]).name}')

    if remove:
        tmp_files = [conf.get_working_dir_path()]
        tmp_files.extend(glob.glob('sandbox_*'))
        fu.rm_file_list(tmp_files)


@pytest.mark.parametrize("system", [None])
def test_step0_extract_chain(config_path, system):
    step0_extract_chain(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step1_extract_chain(config_path, system):
    step1_extract_chain(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step2_remove_molecules(config_path, system):
    step2_remove_molecules(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step4_godmd_prep(config_path, system):
    step4_godmd_prep(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step5_godmd_run(config_path, system):
    step5_godmd_run(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step6_cpptraj_convert(config_path, remove_flag, system):
    step6_cpptraj_convert(config_path, remove_flag, system)
