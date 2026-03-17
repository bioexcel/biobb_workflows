import pytest
from pathlib import Path
from biobb_common.configuration import settings
from biobb_common.tools import file_utils as fu
from biobb_common.tools import test_fixtures as fx
from biobb_analysis.gromacs.gmx_image import gmx_image
from biobb_pytorch.mdae.mdfeaturizer import mdfeaturizer
from biobb_pytorch.mdae.build_model import build_model
from biobb_pytorch.mdae.train_model import train_model
from biobb_pytorch.mdae.evaluate_model import evaluate_model
from biobb_gromacs.gromacs.make_ndx import make_ndx
from biobb_analysis.gromacs.gmx_rmsf import gmx_rmsf
from biobb_pytorch.mdae.feat2traj import feat2traj
from biobb_pytorch.mdae.make_plumed import make_plumed

global_work_dir = None


def step1_gmx_image1(config, system=None):
    conf = settings.ConfReader(config, system)
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    gmx_image(**global_paths["step1_gmx_image1"], properties=global_prop["step1_gmx_image1"])

    assert fx.not_empty(global_paths["step1_gmx_image1"]["output_traj_path"])

    global global_work_dir
    global_work_dir = conf.get_working_dir_path()


def step2_mdfeaturizer1(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    mdfeaturizer(**global_paths["step2_mdfeaturizer1"], properties=global_prop["step2_mdfeaturizer1"])

    assert fx.not_empty(global_paths["step2_mdfeaturizer1"]["output_dataset_pt_path"])
    assert fx.not_empty(global_paths["step2_mdfeaturizer1"]["output_stats_pt_path"])


def step3_build_model(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    build_model(**global_paths["step3_build_model"], properties=global_prop["step3_build_model"])

    assert fx.not_empty(global_paths["step3_build_model"]["output_model_pth_path"])


def step4_train_model(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    train_model(**global_paths["step4_train_model"], properties=global_prop["step4_train_model"])

    assert fx.not_empty(global_paths["step4_train_model"]["output_model_pth_path"])
    assert fx.not_empty(global_paths["step4_train_model"]["output_metrics_npz_path"])


def step5_gmx_image2(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    gmx_image(**global_paths["step5_gmx_image2"], properties=global_prop["step5_gmx_image2"])

    assert fx.not_empty(global_paths["step5_gmx_image2"]["output_traj_path"])


def step6_mdfeaturizer2(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    mdfeaturizer(**global_paths["step6_mdfeaturizer2"], properties=global_prop["step6_mdfeaturizer2"])

    assert fx.not_empty(global_paths["step6_mdfeaturizer2"]["output_dataset_pt_path"])
    assert fx.not_empty(global_paths["step6_mdfeaturizer2"]["output_stats_pt_path"])


def step7_evaluate_model(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    evaluate_model(**global_paths["step7_evaluate_model"], properties=global_prop["step7_evaluate_model"])

    assert fx.not_empty(global_paths["step7_evaluate_model"]["output_results_npz_path"])


def step8_make_ndx1(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    make_ndx(**global_paths["step8_make_ndx1"], properties=global_prop["step8_make_ndx1"])

    assert fx.not_empty(global_paths["step8_make_ndx1"]["output_ndx_path"])


def step9_make_ndx2(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    make_ndx(**global_paths["step9_make_ndx2"], properties=global_prop["step9_make_ndx2"])

    assert fx.not_empty(global_paths["step9_make_ndx2"]["output_ndx_path"])


def step10_gmx_rmsf1(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    gmx_rmsf(**global_paths["step10_gmx_rmsf1"], properties=global_prop["step10_gmx_rmsf1"])

    assert fx.not_empty(global_paths["step10_gmx_rmsf1"]["output_xvg_path"])


def step11_gmx_rmsf2(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    gmx_rmsf(**global_paths["step11_gmx_rmsf2"], properties=global_prop["step11_gmx_rmsf2"])

    assert fx.not_empty(global_paths["step11_gmx_rmsf2"]["output_xvg_path"])


def step12_feat2traj(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    feat2traj(**global_paths["step12_feat2traj"], properties=global_prop["step12_feat2traj"])

    assert fx.not_empty(global_paths["step12_feat2traj"]["output_traj_path"])
    assert fx.not_empty(global_paths["step12_feat2traj"]["output_top_path"])


def step13_gmx_rmsf3(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    gmx_rmsf(**global_paths["step13_gmx_rmsf3"], properties=global_prop["step13_gmx_rmsf3"])

    assert fx.not_empty(global_paths["step13_gmx_rmsf3"]["output_xvg_path"])


def step14_make_plumed(config, remove=False, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    make_plumed(**global_paths["step14_make_plumed"], properties=global_prop["step14_make_plumed"])

    assert fx.not_empty(global_paths["step14_make_plumed"]["output_model_ptc_path"])
    assert fx.not_empty(global_paths["step14_make_plumed"]["output_plumed_dat_path"])
    assert fx.not_empty(global_paths["step14_make_plumed"]["output_features_dat_path"])
    assert fx.compare_size(global_paths["step14_make_plumed"]["output_plumed_dat_path"], f'reference/step14_make_plumed/{Path(global_paths["step14_make_plumed"]["output_plumed_dat_path"]).name}', 10)

    if remove:
        tmp_files = [conf.get_working_dir_path()]
        fu.rm_file_list(tmp_files)


@pytest.mark.parametrize("system", [None])
def test_step1_gmx_image1(config_path, system):
    step1_gmx_image1(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step2_mdfeaturizer1(config_path, system):
    step2_mdfeaturizer1(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step3_build_model(config_path, system):
    step3_build_model(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step4_train_model(config_path, system):
    step4_train_model(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step5_gmx_image2(config_path, system):
    step5_gmx_image2(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step6_mdfeaturizer2(config_path, system):
    step6_mdfeaturizer2(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step7_evaluate_model(config_path, system):
    step7_evaluate_model(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step8_make_ndx1(config_path, system):
    step8_make_ndx1(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step9_make_ndx2(config_path, system):
    step9_make_ndx2(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step10_gmx_rmsf1(config_path, system):
    step10_gmx_rmsf1(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step11_gmx_rmsf2(config_path, system):
    step11_gmx_rmsf2(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step12_feat2traj(config_path, system):
    step12_feat2traj(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step13_gmx_rmsf3(config_path, system):
    step13_gmx_rmsf3(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step14_make_plumed(config_path, remove_flag, system):
    step14_make_plumed(config_path, remove_flag, system)
