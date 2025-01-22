import pytest
import glob
from pathlib import Path
from biobb_common.configuration import settings
from biobb_common.tools import file_utils as fu
from biobb_common.tools import test_fixtures as fx
from biobb_structure_utils.utils.structure_check import structure_check
from biobb_structure_utils.utils.extract_model import extract_model
from biobb_structure_utils.utils.extract_chain import extract_chain
from biobb_model.model.fix_altlocs import fix_altlocs
from biobb_model.model.fix_ssbonds import fix_ssbonds
from biobb_structure_utils.utils.remove_molecules import remove_molecules
from biobb_chemistry.ambertools.reduce_remove_hydrogens import reduce_remove_hydrogens
from biobb_structure_utils.utils.remove_pdb_water import remove_pdb_water
from biobb_model.model.fix_amides import fix_amides
from biobb_model.model.fix_chirality import fix_chirality
from biobb_model.model.fix_side_chain import fix_side_chain
from biobb_model.model.fix_backbone import fix_backbone
from biobb_amber.leap.leap_gen_top import leap_gen_top
from biobb_amber.sander.sander_mdrun import sander_mdrun
from biobb_amber.ambpdb.amber_to_pdb import amber_to_pdb
from biobb_model.model.fix_pdb import fix_pdb

global_work_dir = None


def step0_structure_check_init(config, system=None):
    conf = settings.ConfReader(config, system)
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    structure_check(**global_paths["step0_structure_check_init"], properties=global_prop["step0_structure_check_init"])

    assert fx.not_empty(global_paths["step0_structure_check_init"]["output_summary_path"])

    global global_work_dir
    global_work_dir = conf.get_working_dir_path()


def step1_extract_model(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    extract_model(**global_paths["step1_extract_model"], properties=global_prop["step1_extract_model"])

    assert fx.not_empty(global_paths["step1_extract_model"]["output_structure_path"])


def step2_extract_chain(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    extract_chain(**global_paths["step2_extract_chain"], properties=global_prop["step2_extract_chain"])

    assert fx.not_empty(global_paths["step2_extract_chain"]["output_structure_path"])


def step3_fix_altlocs(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    fix_altlocs(**global_paths["step3_fix_altlocs"], properties=global_prop["step3_fix_altlocs"])

    assert fx.not_empty(global_paths["step3_fix_altlocs"]["output_pdb_path"])


def step4_fix_ssbonds(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    fix_ssbonds(**global_paths["step4_fix_ssbonds"], properties=global_prop["step4_fix_ssbonds"])

    assert fx.not_empty(global_paths["step4_fix_ssbonds"]["output_pdb_path"])


def step5_remove_molecules_ions(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    remove_molecules(**global_paths["step5_remove_molecules_ions"], properties=global_prop["step5_remove_molecules_ions"])

    assert fx.not_empty(global_paths["step5_remove_molecules_ions"]["output_molecules_path"])


def step6_remove_molecules_ligands(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    remove_molecules(**global_paths["step6_remove_molecules_ligands"], properties=global_prop["step6_remove_molecules_ligands"])

    assert fx.not_empty(global_paths["step6_remove_molecules_ligands"]["output_molecules_path"])


def step7_reduce_remove_hydrogens(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    reduce_remove_hydrogens(**global_paths["step7_reduce_remove_hydrogens"], properties=global_prop["step7_reduce_remove_hydrogens"])

    assert fx.not_empty(global_paths["step7_reduce_remove_hydrogens"]["output_path"])


def step8_remove_pdb_water(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    remove_pdb_water(**global_paths["step8_remove_pdb_water"], properties=global_prop["step8_remove_pdb_water"])

    assert fx.not_empty(global_paths["step8_remove_pdb_water"]["output_pdb_path"])


def step9_fix_amides(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    fix_amides(**global_paths["step9_fix_amides"], properties=global_prop["step9_fix_amides"])

    assert fx.not_empty(global_paths["step9_fix_amides"]["output_pdb_path"])


def step10_fix_chirality(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    fix_chirality(**global_paths["step10_fix_chirality"], properties=global_prop["step10_fix_chirality"])

    assert fx.not_empty(global_paths["step10_fix_chirality"]["output_pdb_path"])


def step11_fix_side_chain(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    fix_side_chain(**global_paths["step11_fix_side_chain"], properties=global_prop["step11_fix_side_chain"])

    assert fx.not_empty(global_paths["step11_fix_side_chain"]["output_pdb_path"])


def step12_fix_backbone(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    fix_backbone(**global_paths["step12_fix_backbone"], properties=global_prop["step12_fix_backbone"])

    assert fx.not_empty(global_paths["step12_fix_backbone"]["output_pdb_path"])


def step13_leap_gen_top(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    leap_gen_top(**global_paths["step13_leap_gen_top"], properties=global_prop["step13_leap_gen_top"])

    assert fx.not_empty(global_paths["step13_leap_gen_top"]["output_pdb_path"])
    assert fx.not_empty(global_paths["step13_leap_gen_top"]["output_top_path"])
    assert fx.not_empty(global_paths["step13_leap_gen_top"]["output_crd_path"])


def step14_sander_mdrun(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    sander_mdrun(**global_paths["step14_sander_mdrun"], properties=global_prop["step14_sander_mdrun"])

    assert fx.not_empty(global_paths["step14_sander_mdrun"]["output_traj_path"])
    assert fx.not_empty(global_paths["step14_sander_mdrun"]["output_rst_path"])
    assert fx.not_empty(global_paths["step14_sander_mdrun"]["output_log_path"])


def step15_amber_to_pdb(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    amber_to_pdb(**global_paths["step15_amber_to_pdb"], properties=global_prop["step15_amber_to_pdb"])

    assert fx.not_empty(global_paths["step15_amber_to_pdb"]["output_pdb_path"])


def step16_fix_pdb(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    fix_pdb(**global_paths["step16_fix_pdb"], properties=global_prop["step16_fix_pdb"])

    assert fx.not_empty(global_paths["step16_fix_pdb"]["output_pdb_path"])


def step17_structure_check(config, remove=False, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    structure_check(**global_paths["step17_structure_check"], properties=global_prop["step17_structure_check"])

    assert fx.not_empty(global_paths["step17_structure_check"]["output_summary_path"])
    assert fx.compare_size(global_paths["step17_structure_check"]["output_summary_path"], f'reference/step17_structure_check/{Path(global_paths["step17_structure_check"]["output_summary_path"]).name}', .9)

    if remove:
        tmp_files = [conf.get_working_dir_path()]
        tmp_files.extend(glob.glob('log.*'))
        tmp_files.extend(glob.glob('sandbox_*'))
        fu.rm_file_list(tmp_files)


@pytest.mark.parametrize("system", [None])
def test_step0_structure_check_init(config_path, system):
    step0_structure_check_init(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step1_extract_model(config_path, system):
    step1_extract_model(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step2_extract_chain(config_path, system):
    step2_extract_chain(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step3_fix_altlocs(config_path, system):
    step3_fix_altlocs(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step4_fix_ssbonds(config_path, system):
    step4_fix_ssbonds(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step5_remove_molecules_ions(config_path, system):
    step5_remove_molecules_ions(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step6_remove_molecules_ligands(config_path, system):
    step6_remove_molecules_ligands(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step7_reduce_remove_hydrogens(config_path, system):
    step7_reduce_remove_hydrogens(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step8_remove_pdb_water(config_path, system):
    step8_remove_pdb_water(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step9_fix_amides(config_path, system):
    step9_fix_amides(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step10_fix_chirality(config_path, system):
    step10_fix_chirality(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step11_fix_side_chain(config_path, system):
    step11_fix_side_chain(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step12_fix_backbone(config_path, system):
    step12_fix_backbone(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step13_leap_gen_top(config_path, system):
    step13_leap_gen_top(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step14_sander_mdrun(config_path, system):
    step14_sander_mdrun(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step15_amber_to_pdb(config_path, system):
    step15_amber_to_pdb(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step16_fix_pdb(config_path, system):
    step16_fix_pdb(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step17_structure_check(config_path, remove_flag, system):
    step17_structure_check(config_path, remove_flag, system)
