import pytest
# import glob
from pathlib import Path
from biobb_common.configuration import settings
from biobb_common.tools import file_utils as fu
from biobb_common.tools import test_fixtures as fx
from biobb_amber.leap.leap_gen_top import leap_gen_top
from biobb_amber.leap.leap_solvate import leap_solvate
from biobb_amber.leap.leap_add_ions import leap_add_ions
from biobb_amber.cpptraj.cpptraj_randomize_ions import cpptraj_randomize_ions
from biobb_amber.parmed.parmed_hmassrepartition import parmed_hmassrepartition
from biobb_amber.sander.sander_mdrun import sander_mdrun
from biobb_amber.process.process_minout import process_minout
from biobb_amber.process.process_mdout import process_mdout
from biobb_analysis.ambertools.cpptraj_rms import cpptraj_rms
from biobb_analysis.ambertools.cpptraj_rgyr import cpptraj_rgyr
from biobb_analysis.ambertools.cpptraj_image import cpptraj_image

global_work_dir = None


def step1_leap_gen_top(config, system=None):
    conf = settings.ConfReader(config, system)
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    leap_gen_top(**global_paths["step1_leap_gen_top"], properties=global_prop["step1_leap_gen_top"])

    assert fx.not_empty(global_paths["step1_leap_gen_top"]["output_pdb_path"])
    assert fx.not_empty(global_paths["step1_leap_gen_top"]["output_top_path"])
    assert fx.not_empty(global_paths["step1_leap_gen_top"]["output_crd_path"])

    global global_work_dir
    global_work_dir = conf.get_working_dir_path()


def step2_leap_solvate(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    leap_solvate(**global_paths["step2_leap_solvate"], properties=global_prop["step2_leap_solvate"])

    assert fx.not_empty(global_paths["step2_leap_solvate"]["output_pdb_path"])
    assert fx.not_empty(global_paths["step2_leap_solvate"]["output_top_path"])
    assert fx.not_empty(global_paths["step2_leap_solvate"]["output_crd_path"])


def step3_leap_add_ions(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    leap_add_ions(**global_paths["step3_leap_add_ions"], properties=global_prop["step3_leap_add_ions"])

    assert fx.not_empty(global_paths["step3_leap_add_ions"]["output_pdb_path"])
    assert fx.not_empty(global_paths["step3_leap_add_ions"]["output_top_path"])
    assert fx.not_empty(global_paths["step3_leap_add_ions"]["output_crd_path"])


def step4_cpptraj_randomize_ions(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    cpptraj_randomize_ions(**global_paths["step4_cpptraj_randomize_ions"], properties=global_prop["step4_cpptraj_randomize_ions"])

    assert fx.not_empty(global_paths["step4_cpptraj_randomize_ions"]["output_pdb_path"])
    assert fx.not_empty(global_paths["step4_cpptraj_randomize_ions"]["output_crd_path"])


def step5_parmed_hmassrepartition(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    parmed_hmassrepartition(**global_paths["step5_parmed_hmassrepartition"], properties=global_prop["step5_parmed_hmassrepartition"])

    assert fx.not_empty(global_paths["step5_parmed_hmassrepartition"]["output_top_path"])


def step6_sander_mdrun_eq1(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    sander_mdrun(**global_paths["step6_sander_mdrun_eq1"], properties=global_prop["step6_sander_mdrun_eq1"])

    assert fx.not_empty(global_paths["step6_sander_mdrun_eq1"]["output_traj_path"])
    assert fx.not_empty(global_paths["step6_sander_mdrun_eq1"]["output_rst_path"])
    assert fx.not_empty(global_paths["step6_sander_mdrun_eq1"]["output_log_path"])
    assert fx.not_empty(global_paths["step6_sander_mdrun_eq1"]["output_mdinfo_path"])


def step7_process_minout_eq1(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    process_minout(**global_paths["step7_process_minout_eq1"], properties=global_prop["step7_process_minout_eq1"])

    assert fx.not_empty(global_paths["step7_process_minout_eq1"]["output_dat_path"])


def step8_sander_mdrun_eq2(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    sander_mdrun(**global_paths["step8_sander_mdrun_eq2"], properties=global_prop["step8_sander_mdrun_eq2"])

    assert fx.not_empty(global_paths["step8_sander_mdrun_eq2"]["output_traj_path"])
    assert fx.not_empty(global_paths["step8_sander_mdrun_eq2"]["output_rst_path"])
    assert fx.not_empty(global_paths["step8_sander_mdrun_eq2"]["output_log_path"])
    assert fx.not_empty(global_paths["step8_sander_mdrun_eq2"]["output_mdinfo_path"])


def step9_process_mdout_eq2(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    process_mdout(**global_paths["step9_process_mdout_eq2"], properties=global_prop["step9_process_mdout_eq2"])

    assert fx.not_empty(global_paths["step9_process_mdout_eq2"]["output_dat_path"])


def step10_sander_mdrun_eq3(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    sander_mdrun(**global_paths["step10_sander_mdrun_eq3"], properties=global_prop["step10_sander_mdrun_eq3"])

    assert fx.not_empty(global_paths["step10_sander_mdrun_eq3"]["output_traj_path"])
    assert fx.not_empty(global_paths["step10_sander_mdrun_eq3"]["output_rst_path"])
    assert fx.not_empty(global_paths["step10_sander_mdrun_eq3"]["output_log_path"])
    assert fx.not_empty(global_paths["step10_sander_mdrun_eq3"]["output_mdinfo_path"])


def step11_process_minout_eq3(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    process_minout(**global_paths["step11_process_minout_eq3"], properties=global_prop["step11_process_minout_eq3"])

    assert fx.not_empty(global_paths["step11_process_minout_eq3"]["output_dat_path"])


def step12_sander_mdrun_eq4(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    sander_mdrun(**global_paths["step12_sander_mdrun_eq4"], properties=global_prop["step12_sander_mdrun_eq4"])

    assert fx.not_empty(global_paths["step12_sander_mdrun_eq4"]["output_traj_path"])
    assert fx.not_empty(global_paths["step12_sander_mdrun_eq4"]["output_rst_path"])
    assert fx.not_empty(global_paths["step12_sander_mdrun_eq4"]["output_log_path"])
    assert fx.not_empty(global_paths["step12_sander_mdrun_eq4"]["output_mdinfo_path"])


def step13_process_minout_eq4(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    process_minout(**global_paths["step13_process_minout_eq4"], properties=global_prop["step13_process_minout_eq4"])

    assert fx.not_empty(global_paths["step13_process_minout_eq4"]["output_dat_path"])


def step14_sander_mdrun_eq5(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    sander_mdrun(**global_paths["step14_sander_mdrun_eq5"], properties=global_prop["step14_sander_mdrun_eq5"])

    assert fx.not_empty(global_paths["step14_sander_mdrun_eq5"]["output_traj_path"])
    assert fx.not_empty(global_paths["step14_sander_mdrun_eq5"]["output_rst_path"])
    assert fx.not_empty(global_paths["step14_sander_mdrun_eq5"]["output_log_path"])
    assert fx.not_empty(global_paths["step14_sander_mdrun_eq5"]["output_mdinfo_path"])


def step15_process_minout_eq5(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    process_minout(**global_paths["step15_process_minout_eq5"], properties=global_prop["step15_process_minout_eq5"])

    assert fx.not_empty(global_paths["step15_process_minout_eq5"]["output_dat_path"])


def step16_sander_mdrun_eq6(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    sander_mdrun(**global_paths["step16_sander_mdrun_eq6"], properties=global_prop["step16_sander_mdrun_eq6"])

    assert fx.not_empty(global_paths["step16_sander_mdrun_eq6"]["output_traj_path"])
    assert fx.not_empty(global_paths["step16_sander_mdrun_eq6"]["output_rst_path"])
    assert fx.not_empty(global_paths["step16_sander_mdrun_eq6"]["output_log_path"])
    assert fx.not_empty(global_paths["step16_sander_mdrun_eq6"]["output_mdinfo_path"])


def step17_process_mdout_eq6(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    process_mdout(**global_paths["step17_process_mdout_eq6"], properties=global_prop["step17_process_mdout_eq6"])

    assert fx.not_empty(global_paths["step17_process_mdout_eq6"]["output_dat_path"])


def step18_sander_mdrun_eq7(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    sander_mdrun(**global_paths["step18_sander_mdrun_eq7"], properties=global_prop["step18_sander_mdrun_eq7"])

    assert fx.not_empty(global_paths["step18_sander_mdrun_eq7"]["output_traj_path"])
    assert fx.not_empty(global_paths["step18_sander_mdrun_eq7"]["output_rst_path"])
    assert fx.not_empty(global_paths["step18_sander_mdrun_eq7"]["output_log_path"])
    assert fx.not_empty(global_paths["step18_sander_mdrun_eq7"]["output_mdinfo_path"])


def step19_process_mdout_eq7(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    process_mdout(**global_paths["step19_process_mdout_eq7"], properties=global_prop["step19_process_mdout_eq7"])

    assert fx.not_empty(global_paths["step19_process_mdout_eq7"]["output_dat_path"])


def step20_sander_mdrun_eq8(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    sander_mdrun(**global_paths["step20_sander_mdrun_eq8"], properties=global_prop["step20_sander_mdrun_eq8"])

    assert fx.not_empty(global_paths["step20_sander_mdrun_eq8"]["output_traj_path"])
    assert fx.not_empty(global_paths["step20_sander_mdrun_eq8"]["output_rst_path"])
    assert fx.not_empty(global_paths["step20_sander_mdrun_eq8"]["output_log_path"])
    assert fx.not_empty(global_paths["step20_sander_mdrun_eq8"]["output_mdinfo_path"])


def step21_process_mdout_eq8(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    process_mdout(**global_paths["step21_process_mdout_eq8"], properties=global_prop["step21_process_mdout_eq8"])

    assert fx.not_empty(global_paths["step21_process_mdout_eq8"]["output_dat_path"])


def step22_sander_mdrun_eq9(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    sander_mdrun(**global_paths["step22_sander_mdrun_eq9"], properties=global_prop["step22_sander_mdrun_eq9"])

    assert fx.not_empty(global_paths["step22_sander_mdrun_eq9"]["output_traj_path"])
    assert fx.not_empty(global_paths["step22_sander_mdrun_eq9"]["output_rst_path"])
    assert fx.not_empty(global_paths["step22_sander_mdrun_eq9"]["output_log_path"])
    assert fx.not_empty(global_paths["step22_sander_mdrun_eq9"]["output_mdinfo_path"])


def step23_process_mdout_eq9(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    process_mdout(**global_paths["step23_process_mdout_eq9"], properties=global_prop["step23_process_mdout_eq9"])

    assert fx.not_empty(global_paths["step23_process_mdout_eq9"]["output_dat_path"])


def step24_sander_mdrun_eq10(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    sander_mdrun(**global_paths["step24_sander_mdrun_eq10"], properties=global_prop["step24_sander_mdrun_eq10"])

    assert fx.not_empty(global_paths["step24_sander_mdrun_eq10"]["output_traj_path"])
    assert fx.not_empty(global_paths["step24_sander_mdrun_eq10"]["output_rst_path"])
    assert fx.not_empty(global_paths["step24_sander_mdrun_eq10"]["output_log_path"])
    assert fx.not_empty(global_paths["step24_sander_mdrun_eq10"]["output_mdinfo_path"])


def step25_process_mdout_eq10(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    process_mdout(**global_paths["step25_process_mdout_eq10"], properties=global_prop["step25_process_mdout_eq10"])

    assert fx.not_empty(global_paths["step25_process_mdout_eq10"]["output_dat_path"])


def step26_sander_mdrun_md(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    sander_mdrun(**global_paths["step26_sander_mdrun_md"], properties=global_prop["step26_sander_mdrun_md"])

    assert fx.not_empty(global_paths["step26_sander_mdrun_md"]["output_traj_path"])
    assert fx.not_empty(global_paths["step26_sander_mdrun_md"]["output_rst_path"])
    assert fx.not_empty(global_paths["step26_sander_mdrun_md"]["output_log_path"])
    assert fx.not_empty(global_paths["step26_sander_mdrun_md"]["output_mdinfo_path"])


def step27_rmsd_first(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    cpptraj_rms(**global_paths["step27_rmsd_first"], properties=global_prop["step27_rmsd_first"])

    assert fx.not_empty(global_paths["step27_rmsd_first"]["output_cpptraj_path"])


def step28_rmsd_exp(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    cpptraj_rms(**global_paths["step28_rmsd_exp"], properties=global_prop["step28_rmsd_exp"])

    assert fx.not_empty(global_paths["step28_rmsd_exp"]["output_cpptraj_path"])


def step29_cpptraj_rgyr(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    cpptraj_rgyr(**global_paths["step29_cpptraj_rgyr"], properties=global_prop["step29_cpptraj_rgyr"])

    assert fx.not_empty(global_paths["step29_cpptraj_rgyr"]["output_cpptraj_path"])


def step30_cpptraj_image(config, remove=False, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    cpptraj_image(**global_paths["step30_cpptraj_image"], properties=global_prop["step30_cpptraj_image"])

    assert fx.not_empty(global_paths["step30_cpptraj_image"]["output_cpptraj_path"])
    assert fx.compare_size(global_paths["step30_cpptraj_image"]["output_cpptraj_path"], f'reference/step30_cpptraj_image/{Path(global_paths["step30_cpptraj_image"]["output_cpptraj_path"]).name}', 10)

    if remove:
        tmp_files = [conf.get_working_dir_path()]
        fu.rm_file_list(tmp_files)


@pytest.mark.parametrize("system", [None])
def test_step1_leap_gen_top(config_path, system):
    step1_leap_gen_top(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step2_leap_solvate(config_path, system):
    step2_leap_solvate(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step3_leap_add_ions(config_path, system):
    step3_leap_add_ions(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step4_cpptraj_randomize_ions(config_path, system):
    step4_cpptraj_randomize_ions(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step5_parmed_hmassrepartition(config_path, system):
    step5_parmed_hmassrepartition(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step6_sander_mdrun_eq1(config_path, system):
    step6_sander_mdrun_eq1(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step7_process_minout_eq1(config_path, system):
    step7_process_minout_eq1(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step8_sander_mdrun_eq2(config_path, system):
    step8_sander_mdrun_eq2(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step9_process_mdout_eq2(config_path, system):
    step9_process_mdout_eq2(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step10_sander_mdrun_eq3(config_path, system):
    step10_sander_mdrun_eq3(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step11_process_minout_eq3(config_path, system):
    step11_process_minout_eq3(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step12_sander_mdrun_eq4(config_path, system):
    step12_sander_mdrun_eq4(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step13_process_minout_eq4(config_path, system):
    step13_process_minout_eq4(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step14_sander_mdrun_eq5(config_path, system):
    step14_sander_mdrun_eq5(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step15_process_minout_eq5(config_path, system):
    step15_process_minout_eq5(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step16_sander_mdrun_eq6(config_path, system):
    step16_sander_mdrun_eq6(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step17_process_mdout_eq6(config_path, system):
    step17_process_mdout_eq6(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step18_sander_mdrun_eq7(config_path, system):
    step18_sander_mdrun_eq7(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step19_process_mdout_eq7(config_path, system):
    step19_process_mdout_eq7(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step20_sander_mdrun_eq8(config_path, system):
    step20_sander_mdrun_eq8(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step21_process_mdout_eq8(config_path, system):
    step21_process_mdout_eq8(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step22_sander_mdrun_eq9(config_path, system):
    step22_sander_mdrun_eq9(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step23_process_mdout_eq9(config_path, system):
    step23_process_mdout_eq9(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step24_sander_mdrun_eq10(config_path, system):
    step24_sander_mdrun_eq10(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step26_sander_mdrun_md(config_path, system):
    step26_sander_mdrun_md(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step27_rmsd_first(config_path, system):
    step27_rmsd_first(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step28_rmsd_exp(config_path, system):
    step28_rmsd_exp(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step29_cpptraj_rgyr(config_path, system):
    step29_cpptraj_rgyr(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step30_cpptraj_image(config_path, remove_flag, system):
    step30_cpptraj_image(config_path, remove_flag, system)
