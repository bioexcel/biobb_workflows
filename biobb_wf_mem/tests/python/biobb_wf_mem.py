import pytest
from biobb_common.configuration import settings
from biobb_common.tools import file_utils as fu
from biobb_common.tools import test_fixtures as fx
from biobb_analysis.gromacs.gmx_image import gmx_image
from biobb_mem.fatslim.fatslim_membranes import fatslim_membranes
from biobb_mem.lipyphilic_biobb.lpp_assign_leaflets import lpp_assign_leaflets
from biobb_mem.lipyphilic_biobb.lpp_zpositions import lpp_zpositions
from biobb_mem.gorder.gorder_aa import gorder_aa
from biobb_mem.fatslim.fatslim_apl import fatslim_apl
from biobb_mem.ambertools.cpptraj_density import cpptraj_density
from biobb_mem.mdanalysis_biobb.mda_hole import mda_hole
# from biobb_mem.lipyphilic_biobb.lpp_flip_flop import lpp_flip_flop

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


def step2_gmx_image2(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    gmx_image(**global_paths["step2_gmx_image2"], properties=global_prop["step2_gmx_image2"])

    assert fx.not_empty(global_paths["step2_gmx_image2"]["output_traj_path"])


def step3_fatslim_membranes(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    fatslim_membranes(**global_paths["step3_fatslim_membranes"], properties=global_prop["step3_fatslim_membranes"])

    assert fx.not_empty(global_paths["step3_fatslim_membranes"]["output_ndx_path"])


def step4_lpp_assign_leaflets(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    lpp_assign_leaflets(**global_paths["step4_lpp_assign_leaflets"], properties=global_prop["step4_lpp_assign_leaflets"])

    assert fx.not_empty(global_paths["step4_lpp_assign_leaflets"]["output_leaflets_path"])


def step5_lpp_zpositions1(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    lpp_zpositions(**global_paths["step5_lpp_zpositions1"], properties=global_prop["step5_lpp_zpositions1"])

    assert fx.not_empty(global_paths["step5_lpp_zpositions1"]["output_positions_path"])


def step6_lpp_zpositions2(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    lpp_zpositions(**global_paths["step6_lpp_zpositions2"], properties=global_prop["step6_lpp_zpositions2"])

    assert fx.not_empty(global_paths["step6_lpp_zpositions2"]["output_positions_path"])


def step7_gorder_aa(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    gorder_aa(**global_paths["step7_gorder_aa"], properties=global_prop["step7_gorder_aa"])

    assert fx.not_empty(global_paths["step7_gorder_aa"]["output_order_path"])


def step8_fatslim_apl(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    fatslim_apl(**global_paths["step8_fatslim_apl"], properties=global_prop["step8_fatslim_apl"])

    assert fx.not_empty(global_paths["step8_fatslim_apl"]["output_csv_path"])


def step9_cpptraj_density(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    cpptraj_density(**global_paths["step9_cpptraj_density"], properties=global_prop["step9_cpptraj_density"])

    assert fx.not_empty(global_paths["step9_cpptraj_density"]["output_cpptraj_path"])


def step10_mda_hole(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    mda_hole(**global_paths["step10_mda_hole"], properties=global_prop["step10_mda_hole"])

    assert fx.not_empty(global_paths["step10_mda_hole"]["output_csv_path"])


# def step11_lpp_flip_flop(config, remove=False, system=None):
#     conf = settings.ConfReader(config, system)
#     conf.working_dir_path = global_work_dir
#     global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
#     global_prop = conf.get_prop_dic(global_log=global_log)
#     global_paths = conf.get_paths_dic()

#     lpp_flip_flop(**global_paths["step11_lpp_flip_flop"], properties=global_prop["step11_lpp_flip_flop"])

#     assert fx.not_empty(global_paths["step11_lpp_flip_flop"]["output_flipflop_path"])

#     global global_work_dir
#     global_work_dir = conf.get_working_dir_path()

#     assert fx.compare_size(global_paths["step11_lpp_flip_flop"]["output_flipflop_path"], f'reference/step11_lpp_flip_flop/{Path(global_paths["step11_lpp_flip_flop"]["output_flipflop_path"]).name}', 10)

#     if remove:
#         tmp_files = [conf.get_working_dir_path()]
#         fu.rm_file_list(tmp_files)


@pytest.mark.parametrize("system", [None])
def test_step1_gmx_image1(config_path, system):
    step1_gmx_image1(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step2_gmx_image2(config_path, system):
    step2_gmx_image2(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step3_fatslim_membranes(config_path, system):
    step3_fatslim_membranes(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step4_lpp_assign_leaflets(config_path, system):
    step4_lpp_assign_leaflets(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step5_lpp_zpositions1(config_path, system):
    step5_lpp_zpositions1(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step6_lpp_zpositions2(config_path, system):
    step6_lpp_zpositions2(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step7_gorder_aa(config_path, system):
    step7_gorder_aa(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step8_fatslim_apl(config_path, system):
    step8_fatslim_apl(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step9_cpptraj_density(config_path, system):
    step9_cpptraj_density(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step10_mda_hole(config_path, system):
    step10_mda_hole(config_path, system)


# @pytest.mark.parametrize("system", [None])
# def test_step11_lpp_flip_flop(config_path, remove_flag, system):
#     step11_lpp_flip_flop(config_path, remove_flag, system)
