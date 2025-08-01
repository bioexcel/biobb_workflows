import pytest
# import glob
from pathlib import Path
from biobb_common.configuration import settings
from biobb_common.tools import file_utils as fu
from biobb_common.tools import test_fixtures as fx
from biobb_structure_utils.utils.extract_atoms import extract_atoms
from biobb_flexserv.flexserv.bd_run import bd_run
from biobb_analysis.ambertools.cpptraj_rms import cpptraj_rms
from biobb_flexserv.flexserv.dmd_run import dmd_run
from biobb_flexserv.flexserv.nma_run import nma_run
from biobb_flexserv.pcasuite.pcz_zip import pcz_zip
from biobb_flexserv.pcasuite.pcz_unzip import pcz_unzip
from biobb_flexserv.pcasuite.pcz_info import pcz_info
from biobb_flexserv.pcasuite.pcz_evecs import pcz_evecs
from biobb_flexserv.pcasuite.pcz_animate import pcz_animate
from biobb_analysis.ambertools.cpptraj_convert import cpptraj_convert
from biobb_flexserv.pcasuite.pcz_bfactor import pcz_bfactor
from biobb_flexserv.pcasuite.pcz_hinges import pcz_hinges
from biobb_flexserv.pcasuite.pcz_stiffness import pcz_stiffness
from biobb_flexserv.pcasuite.pcz_collectivity import pcz_collectivity
from biobb_flexserv.pcasuite.pcz_similarity import pcz_similarity

global_work_dir = None


def step0_extract_atoms(config, system=None):
    conf = settings.ConfReader(config, system)
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    extract_atoms(**global_paths["step0_extract_atoms"], properties=global_prop["step0_extract_atoms"])

    assert fx.not_empty(global_paths["step0_extract_atoms"]["output_structure_path"])

    global global_work_dir
    global_work_dir = conf.get_working_dir_path()


def step1_bd_run(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    bd_run(**global_paths["step1_bd_run"], properties=global_prop["step1_bd_run"])

    assert fx.not_empty(global_paths["step1_bd_run"]["output_crd_path"])
    assert fx.not_empty(global_paths["step1_bd_run"]["output_log_path"])


def step2_cpptraj_rms(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    cpptraj_rms(**global_paths["step2_cpptraj_rms"], properties=global_prop["step2_cpptraj_rms"])

    assert fx.not_empty(global_paths["step2_cpptraj_rms"]["output_cpptraj_path"])
    assert fx.not_empty(global_paths["step2_cpptraj_rms"]["output_traj_path"])


def step3_dmd_run(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    dmd_run(**global_paths["step3_dmd_run"], properties=global_prop["step3_dmd_run"])

    assert fx.not_empty(global_paths["step3_dmd_run"]["output_crd_path"])
    assert fx.not_empty(global_paths["step3_dmd_run"]["output_log_path"])


def step4_cpptraj_rms(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    cpptraj_rms(**global_paths["step4_cpptraj_rms"], properties=global_prop["step4_cpptraj_rms"])

    assert fx.not_empty(global_paths["step4_cpptraj_rms"]["output_cpptraj_path"])
    assert fx.not_empty(global_paths["step4_cpptraj_rms"]["output_traj_path"])


def step5_nma_run(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    nma_run(**global_paths["step5_nma_run"], properties=global_prop["step5_nma_run"])

    assert fx.not_empty(global_paths["step5_nma_run"]["output_crd_path"])
    assert fx.not_empty(global_paths["step5_nma_run"]["output_log_path"])


def step6_cpptraj_rms(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    cpptraj_rms(**global_paths["step6_cpptraj_rms"], properties=global_prop["step6_cpptraj_rms"])

    assert fx.not_empty(global_paths["step6_cpptraj_rms"]["output_cpptraj_path"])
    assert fx.not_empty(global_paths["step6_cpptraj_rms"]["output_traj_path"])


def step7_pcz_zip(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    pcz_zip(**global_paths["step7_pcz_zip"], properties=global_prop["step7_pcz_zip"])

    assert fx.not_empty(global_paths["step7_pcz_zip"]["output_pcz_path"])


def step8_pcz_zip(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    pcz_zip(**global_paths["step8_pcz_zip"], properties=global_prop["step8_pcz_zip"])

    assert fx.not_empty(global_paths["step8_pcz_zip"]["output_pcz_path"])


def step9_pcz_zip(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    pcz_zip(**global_paths["step9_pcz_zip"], properties=global_prop["step9_pcz_zip"])

    assert fx.not_empty(global_paths["step9_pcz_zip"]["output_pcz_path"])


def step10_pcz_unzip(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    pcz_unzip(**global_paths["step10_pcz_unzip"], properties=global_prop["step10_pcz_unzip"])

    assert fx.not_empty(global_paths["step10_pcz_unzip"]["output_crd_path"])


def step11_pcz_unzip(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    pcz_unzip(**global_paths["step11_pcz_unzip"], properties=global_prop["step11_pcz_unzip"])

    assert fx.not_empty(global_paths["step11_pcz_unzip"]["output_crd_path"])


def step12_pcz_unzip(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    pcz_unzip(**global_paths["step12_pcz_unzip"], properties=global_prop["step12_pcz_unzip"])

    assert fx.not_empty(global_paths["step12_pcz_unzip"]["output_crd_path"])


def step13_cpptraj_rms(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    cpptraj_rms(**global_paths["step13_cpptraj_rms"], properties=global_prop["step13_cpptraj_rms"])

    assert fx.not_empty(global_paths["step13_cpptraj_rms"]["output_cpptraj_path"])
    assert fx.not_empty(global_paths["step13_cpptraj_rms"]["output_traj_path"])


def step14_cpptraj_rms(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    cpptraj_rms(**global_paths["step14_cpptraj_rms"], properties=global_prop["step14_cpptraj_rms"])

    assert fx.not_empty(global_paths["step14_cpptraj_rms"]["output_cpptraj_path"])
    assert fx.not_empty(global_paths["step14_cpptraj_rms"]["output_traj_path"])


def step15_cpptraj_rms(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    cpptraj_rms(**global_paths["step15_cpptraj_rms"], properties=global_prop["step15_cpptraj_rms"])

    assert fx.not_empty(global_paths["step15_cpptraj_rms"]["output_cpptraj_path"])
    assert fx.not_empty(global_paths["step15_cpptraj_rms"]["output_traj_path"])


def step16_pcz_info(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    pcz_info(**global_paths["step16_pcz_info"], properties=global_prop["step16_pcz_info"])

    assert fx.not_empty(global_paths["step16_pcz_info"]["output_json_path"])


def step17_pcz_evecs(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    pcz_evecs(**global_paths["step17_pcz_evecs"], properties=global_prop["step17_pcz_evecs"])

    assert fx.not_empty(global_paths["step17_pcz_evecs"]["output_json_path"])


def step18_pcz_animate(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    pcz_animate(**global_paths["step18_pcz_animate"], properties=global_prop["step18_pcz_animate"])

    assert fx.not_empty(global_paths["step18_pcz_animate"]["output_crd_path"])


def step19_cpptraj_convert(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    cpptraj_convert(**global_paths["step19_cpptraj_convert"], properties=global_prop["step19_cpptraj_convert"])

    assert fx.not_empty(global_paths["step19_cpptraj_convert"]["output_cpptraj_path"])


def step20_pcz_bfactor(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    pcz_bfactor(**global_paths["step20_pcz_bfactor"], properties=global_prop["step20_pcz_bfactor"])

    assert fx.not_empty(global_paths["step20_pcz_bfactor"]["output_dat_path"])
    assert fx.not_empty(global_paths["step20_pcz_bfactor"]["output_pdb_path"])


def step21_pcz_hinges(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    pcz_hinges(**global_paths["step21_pcz_hinges"], properties=global_prop["step21_pcz_hinges"])

    assert fx.not_empty(global_paths["step21_pcz_hinges"]["output_json_path"])


def step22_pcz_hinges(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    pcz_hinges(**global_paths["step22_pcz_hinges"], properties=global_prop["step22_pcz_hinges"])

    assert fx.not_empty(global_paths["step22_pcz_hinges"]["output_json_path"])


def step23_pcz_hinges(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    pcz_hinges(**global_paths["step23_pcz_hinges"], properties=global_prop["step23_pcz_hinges"])

    assert fx.not_empty(global_paths["step23_pcz_hinges"]["output_json_path"])


def step24_pcz_stiffness(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    pcz_stiffness(**global_paths["step24_pcz_stiffness"], properties=global_prop["step24_pcz_stiffness"])

    assert fx.not_empty(global_paths["step24_pcz_stiffness"]["output_json_path"])


def step25_pcz_collectivity(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    pcz_collectivity(**global_paths["step25_pcz_collectivity"], properties=global_prop["step25_pcz_collectivity"])

    assert fx.not_empty(global_paths["step25_pcz_collectivity"]["output_json_path"])


def step26_pcz_similarity(config, remove=False, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    pcz_similarity(**global_paths["step26_pcz_similarity"], properties=global_prop["step26_pcz_similarity"])

    assert fx.not_empty(global_paths["step26_pcz_similarity"]["output_json_path"])


def step27_pcz_similarity(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    pcz_similarity(**global_paths["step27_pcz_similarity"], properties=global_prop["step27_pcz_similarity"])

    assert fx.not_empty(global_paths["step27_pcz_similarity"]["output_json_path"])


def step28_pcz_similarity(config, remove=False, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    pcz_similarity(**global_paths["step28_pcz_similarity"], properties=global_prop["step28_pcz_similarity"])

    assert fx.not_empty(global_paths["step28_pcz_similarity"]["output_json_path"])
    # assert fx.equal(global_paths["step28_pcz_similarity"]["output_json_path"], f'reference/step28_pcz_similarity/{Path(global_paths["step28_pcz_similarity"]["output_json_path"]).name}')
    assert fx.compare_size(global_paths["step28_pcz_similarity"]["output_json_path"], f'reference/step28_pcz_similarity/{Path(global_paths["step28_pcz_similarity"]["output_json_path"]).name}', 10)

    if remove:
        tmp_files = [conf.get_working_dir_path(), 'distancia.dat', 'eigenvec.dat', 'file.proj', 'hessian.dat', 'masses.dat', 'molecula.out', 'molecula.pdb', 'output.pdb', 'snapshots.pdb']
        fu.rm_file_list(tmp_files)


@pytest.mark.parametrize("system", [None])
def test_step0_extract_atoms(config_path, system):
    step0_extract_atoms(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step1_bd_run(config_path, system):
    step1_bd_run(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step2_cpptraj_rms(config_path, system):
    step2_cpptraj_rms(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step3_dmd_run(config_path, system):
    step3_dmd_run(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step4_cpptraj_rms(config_path, system):
    step4_cpptraj_rms(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step5_nma_run(config_path, system):
    step5_nma_run(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step6_cpptraj_rms(config_path, system):
    step6_cpptraj_rms(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step7_pcz_zip(config_path, system):
    step7_pcz_zip(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step8_pcz_zip(config_path, system):
    step8_pcz_zip(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step9_pcz_zip(config_path, system):
    step9_pcz_zip(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step10_pcz_unzip(config_path, system):
    step10_pcz_unzip(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step11_pcz_unzip(config_path, system):
    step11_pcz_unzip(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step12_pcz_unzip(config_path, system):
    step12_pcz_unzip(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step13_cpptraj_rms(config_path, system):
    step13_cpptraj_rms(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step14_cpptraj_rms(config_path, system):
    step14_cpptraj_rms(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step15_cpptraj_rms(config_path, system):
    step15_cpptraj_rms(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step16_pcz_info(config_path, system):
    step16_pcz_info(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step17_pcz_evecs(config_path, system):
    step17_pcz_evecs(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step18_pcz_animate(config_path, system):
    step18_pcz_animate(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step19_cpptraj_convert(config_path, system):
    step19_cpptraj_convert(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step20_pcz_bfactor(config_path, system):
    step20_pcz_bfactor(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step21_pcz_hinges(config_path, system):
    step21_pcz_hinges(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step22_pcz_hinges(config_path, system):
    step22_pcz_hinges(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step23_pcz_hinges(config_path, system):
    step23_pcz_hinges(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step24_pcz_stiffness(config_path, system):
    step24_pcz_stiffness(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step25_pcz_collectivity(config_path, system):
    step25_pcz_collectivity(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step26_pcz_similarity(config_path, system):
    step26_pcz_similarity(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step27_pcz_similarity(config_path, system):
    step27_pcz_similarity(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step28_pcz_similarity(config_path, remove_flag, system):
    step28_pcz_similarity(config_path, remove_flag, system)
