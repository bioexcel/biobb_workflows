import pytest
import glob
import os
import zipfile
from biobb_common.configuration import settings
from biobb_common.tools import file_utils as fu
from biobb_common.tools import test_fixtures as fx
from biobb_pmx.pmxbiobb.pmxmutate import pmxmutate
from biobb_pmx.pmxbiobb.pmxgentop import pmxgentop
from biobb_gromacs.gromacs.pdb2gmx import pdb2gmx
from biobb_gromacs.gromacs.make_ndx import make_ndx
from biobb_gromacs.gromacs.grompp import grompp
from biobb_gromacs.gromacs.mdrun import mdrun
from biobb_analysis.gromacs.gmx_trjconv_str_ens import gmx_trjconv_str_ens

global_work_dir = None
global_mutations = []
global_state_pdb_list = []


def setup_globals(config, system=None):
    global global_work_dir, global_mutations, global_state_pdb_list

    conf = settings.ConfReader(config, system)
    print(conf)
    global_work_dir = conf.get_working_dir_path()
    global_mutations = conf.properties['global_properties']['mutations']
    global_state_pdb_list = [f"frame{i}.pdb" for i in range(25)]
    print(global_mutations)
    print(global_state_pdb_list)


setup_globals("../../python/workflow.yml")


def step0_trjconv(config, ensemble, mutation, system=None):
    conf = settings.ConfReader(config, system)
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    ensemble_prop = conf.get_prop_dic(prefix=ensemble, global_log=global_log)
    ensemble_paths = conf.get_paths_dic(prefix=ensemble)

    ensemble_paths['step0_trjconv']['input_traj_path'] = conf.properties['global_properties']['input_trajs'][ensemble]['input_traj_path']
    ensemble_paths['step0_trjconv']['input_top_path'] = conf.properties['global_properties']['input_trajs'][ensemble]['input_tpr_path']
    gmx_trjconv_str_ens(**ensemble_paths["step0_trjconv"], properties=ensemble_prop["step0_trjconv"])

    assert fx.not_empty(ensemble_paths["step0_trjconv"]["output_str_ens_path"])

    with zipfile.ZipFile(ensemble_paths["step0_trjconv"]["output_str_ens_path"], 'r') as zip_f:
        zip_f.extractall()


def step1_pmx_mutate(config, pdb_path, ensemble, mutation, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    pdb_name = os.path.splitext(pdb_path)[0]
    prop = conf.get_prop_dic(prefix=os.path.join(ensemble, pdb_name), global_log=global_log)
    paths = conf.get_paths_dic(prefix=os.path.join(ensemble, pdb_name))

    paths['step1_pmx_mutate']['input_structure_path'] = f'./{pdb_path}'
    prop['step1_pmx_mutate']['mutation_list'] = mutation
    prop['step1_pmx_mutate']['gmx_lib'] = os.getenv('CONDA_PREFIX') + '/lib/python3.10/site-packages/pmx/data/mutff'
    pmxmutate(**paths["step1_pmx_mutate"], properties=prop["step1_pmx_mutate"])

    assert fx.not_empty(paths["step1_pmx_mutate"]["output_structure_path"])


def step2_gmx_pdb2gmx(config, pdb_path, ensemble, mutation, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    pdb_name = os.path.splitext(pdb_path)[0]
    prop = conf.get_prop_dic(prefix=os.path.join(ensemble, pdb_name), global_log=global_log)
    paths = conf.get_paths_dic(prefix=os.path.join(ensemble, pdb_name))

    prop['step2_gmx_pdb2gmx']['gmx_lib'] = os.getenv('CONDA_PREFIX') + '/lib/python3.10/site-packages/pmx/data/mutff'
    pdb2gmx(**paths["step2_gmx_pdb2gmx"], properties=prop["step2_gmx_pdb2gmx"])

    assert fx.not_empty(paths["step2_gmx_pdb2gmx"]["output_gro_path"])
    assert fx.not_empty(paths["step2_gmx_pdb2gmx"]["output_top_zip_path"])


def step3_pmx_gentop(config, pdb_path, ensemble, mutation, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    pdb_name = os.path.splitext(pdb_path)[0]
    prop = conf.get_prop_dic(prefix=os.path.join(ensemble, pdb_name), global_log=global_log)
    paths = conf.get_paths_dic(prefix=os.path.join(ensemble, pdb_name))

    prop['step3_pmx_gentop']['gmx_lib'] = os.getenv('CONDA_PREFIX') + '/lib/python3.10/site-packages/pmx/data/mutff'
    pmxgentop(**paths["step3_pmx_gentop"], properties=prop["step3_pmx_gentop"])

    assert fx.not_empty(paths["step3_pmx_gentop"]["output_log_path"])
    assert fx.not_empty(paths["step3_pmx_gentop"]["output_top_zip_path"])


def step4_gmx_makendx(config, pdb_path, ensemble, mutation, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    pdb_name = os.path.splitext(pdb_path)[0]
    prop = conf.get_prop_dic(prefix=os.path.join(ensemble, pdb_name), global_log=global_log)
    paths = conf.get_paths_dic(prefix=os.path.join(ensemble, pdb_name))

    make_ndx(**paths["step4_gmx_makendx"], properties=prop["step4_gmx_makendx"])

    assert fx.not_empty(paths["step4_gmx_makendx"]["output_ndx_path"])


def step5_gmx_grompp(config, pdb_path, ensemble, mutation, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    pdb_name = os.path.splitext(pdb_path)[0]
    prop = conf.get_prop_dic(prefix=os.path.join(ensemble, pdb_name), global_log=global_log)
    paths = conf.get_paths_dic(prefix=os.path.join(ensemble, pdb_name))

    prop['step5_gmx_grompp']['gmx_lib'] = os.getenv('CONDA_PREFIX') + '/lib/python3.10/site-packages/pmx/data/mutff'
    grompp(**paths["step5_gmx_grompp"], properties=prop["step5_gmx_grompp"])

    assert fx.not_empty(paths["step5_gmx_grompp"]["output_tpr_path"])


def step6_gmx_mdrun(config, pdb_path, ensemble, mutation, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    pdb_name = os.path.splitext(pdb_path)[0]
    prop = conf.get_prop_dic(prefix=os.path.join(ensemble, pdb_name), global_log=global_log)
    paths = conf.get_paths_dic(prefix=os.path.join(ensemble, pdb_name))

    mdrun(**paths["step6_gmx_mdrun"], properties=prop["step6_gmx_mdrun"])

    assert fx.not_empty(paths["step6_gmx_mdrun"]["output_trr_path"])
    assert fx.not_empty(paths["step6_gmx_mdrun"]["output_gro_path"])
    assert fx.not_empty(paths["step6_gmx_mdrun"]["output_edr_path"])
    assert fx.not_empty(paths["step6_gmx_mdrun"]["output_log_path"])


def step7_gmx_grompp(config, pdb_path, ensemble, mutation, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    pdb_name = os.path.splitext(pdb_path)[0]
    prop = conf.get_prop_dic(prefix=os.path.join(ensemble, pdb_name), global_log=global_log)
    paths = conf.get_paths_dic(prefix=os.path.join(ensemble, pdb_name))

    prop['step7_gmx_grompp']['gmx_lib'] = os.getenv('CONDA_PREFIX') + '/lib/python3.10/site-packages/pmx/data/mutff'
    grompp(**paths["step7_gmx_grompp"], properties=prop["step7_gmx_grompp"])

    assert fx.not_empty(paths["step7_gmx_grompp"]["output_tpr_path"])


def step8_gmx_mdrun(config, pdb_path, ensemble, mutation, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    pdb_name = os.path.splitext(pdb_path)[0]
    prop = conf.get_prop_dic(prefix=os.path.join(ensemble, pdb_name), global_log=global_log)
    paths = conf.get_paths_dic(prefix=os.path.join(ensemble, pdb_name))

    mdrun(**paths["step8_gmx_mdrun"], properties=prop["step8_gmx_mdrun"])

    assert fx.not_empty(paths["step8_gmx_mdrun"]["output_trr_path"])
    assert fx.not_empty(paths["step8_gmx_mdrun"]["output_gro_path"])
    assert fx.not_empty(paths["step8_gmx_mdrun"]["output_edr_path"])
    assert fx.not_empty(paths["step8_gmx_mdrun"]["output_log_path"])


def step9_gmx_grompp(config, pdb_path, ensemble, mutation, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    pdb_name = os.path.splitext(pdb_path)[0]
    prop = conf.get_prop_dic(prefix=os.path.join(ensemble, pdb_name), global_log=global_log)
    paths = conf.get_paths_dic(prefix=os.path.join(ensemble, pdb_name))

    prop['step9_gmx_grompp']['gmx_lib'] = os.getenv('CONDA_PREFIX') + '/lib/python3.10/site-packages/pmx/data/mutff'
    grompp(**paths["step9_gmx_grompp"], properties=prop["step9_gmx_grompp"])

    assert fx.not_empty(paths["step9_gmx_grompp"]["output_tpr_path"])


def step10_gmx_mdrun(config, pdb_path, ensemble, mutation, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    pdb_name = os.path.splitext(pdb_path)[0]
    prop = conf.get_prop_dic(prefix=os.path.join(ensemble, pdb_name), global_log=global_log)
    paths = conf.get_paths_dic(prefix=os.path.join(ensemble, pdb_name))

    mdrun(**paths["step10_gmx_mdrun"], properties=prop["step10_gmx_mdrun"])

    assert fx.not_empty(paths["step10_gmx_mdrun"]["output_trr_path"])
    assert fx.not_empty(paths["step10_gmx_mdrun"]["output_gro_path"])
    assert fx.not_empty(paths["step10_gmx_mdrun"]["output_edr_path"])
    assert fx.not_empty(paths["step10_gmx_mdrun"]["output_log_path"])


def final_step(config, remove=False, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir

    if remove:
        tmp_files = [conf.get_working_dir_path()]
        tmp_files.extend(glob.glob('frame*.pdb'))
        fu.rm_file_list(tmp_files)


@pytest.mark.parametrize("ensemble, mutation", list(global_mutations.items()))
@pytest.mark.parametrize("system", [None])
def test_step0_trjconv(config_path, ensemble, mutation, system):
    step0_trjconv(config_path, ensemble, mutation, system)


@pytest.mark.parametrize("ensemble, mutation", list(global_mutations.items())[1:2])
@pytest.mark.parametrize("iteration", range(len(global_state_pdb_list)))
@pytest.mark.parametrize("system", [None])
def test_step1_pmx_mutate(config_path, iteration, ensemble, mutation, system):
    if (ensemble == "stateA"):
        pdb_path = global_state_pdb_list[iteration]
        step1_pmx_mutate(config_path, pdb_path, ensemble, mutation, system)


@pytest.mark.parametrize("ensemble, mutation", list(global_mutations.items())[1:2])
@pytest.mark.parametrize("iteration", range(len(global_state_pdb_list)))
@pytest.mark.parametrize("system", [None])
def test_step2_gmx_pdb2gmx(config_path, iteration, ensemble, mutation, system):
    if (ensemble == "stateA"):
        pdb_path = global_state_pdb_list[iteration]
        step2_gmx_pdb2gmx(config_path, pdb_path, ensemble, mutation, system)


@pytest.mark.parametrize("ensemble, mutation", list(global_mutations.items())[1:2])
@pytest.mark.parametrize("iteration", range(len(global_state_pdb_list)))
@pytest.mark.parametrize("system", [None])
def test_step3_pmx_gentop(config_path, iteration, ensemble, mutation, system):
    if (ensemble == "stateA"):
        pdb_path = global_state_pdb_list[iteration]
        step3_pmx_gentop(config_path, pdb_path, ensemble, mutation, system)


@pytest.mark.parametrize("ensemble, mutation", list(global_mutations.items())[1:2])
@pytest.mark.parametrize("iteration", range(len(global_state_pdb_list)))
@pytest.mark.parametrize("system", [None])
def test_step4_gmx_makendx(config_path, iteration, ensemble, mutation, system):
    if (ensemble == "stateA"):
        pdb_path = global_state_pdb_list[iteration]
        step4_gmx_makendx(config_path, pdb_path, ensemble, mutation, system)


@pytest.mark.parametrize("ensemble, mutation", list(global_mutations.items())[1:2])
@pytest.mark.parametrize("iteration", range(len(global_state_pdb_list)))
@pytest.mark.parametrize("system", [None])
def test_step5_gmx_grompp(config_path, iteration, ensemble, mutation, system):
    if (ensemble == "stateA"):
        pdb_path = global_state_pdb_list[iteration]
        step5_gmx_grompp(config_path, pdb_path, ensemble, mutation, system)


@pytest.mark.parametrize("ensemble, mutation", list(global_mutations.items())[1:2])
@pytest.mark.parametrize("iteration", range(len(global_state_pdb_list)))
@pytest.mark.parametrize("system", [None])
def test_step6_gmx_mdrun(config_path, iteration, ensemble, mutation, system):
    if (ensemble == "stateA"):
        pdb_path = global_state_pdb_list[iteration]
        step6_gmx_mdrun(config_path, pdb_path, ensemble, mutation, system)


@pytest.mark.parametrize("ensemble, mutation", list(global_mutations.items())[1:2])
@pytest.mark.parametrize("iteration", range(len(global_state_pdb_list)))
@pytest.mark.parametrize("system", [None])
def test_step7_gmx_grompp(config_path, iteration, ensemble, mutation, system):
    if (ensemble == "stateA"):
        pdb_path = global_state_pdb_list[iteration]
        step7_gmx_grompp(config_path, pdb_path, ensemble, mutation, system)


@pytest.mark.parametrize("ensemble, mutation", list(global_mutations.items())[1:2])
@pytest.mark.parametrize("iteration", range(len(global_state_pdb_list)))
@pytest.mark.parametrize("system", [None])
def test_step8_gmx_mdrun(config_path, iteration, ensemble, mutation, system):
    if (ensemble == "stateA"):
        pdb_path = global_state_pdb_list[iteration]
        step8_gmx_mdrun(config_path, pdb_path, ensemble, mutation, system)


@pytest.mark.parametrize("ensemble, mutation", list(global_mutations.items())[1:2])
@pytest.mark.parametrize("iteration", range(len(global_state_pdb_list)))
@pytest.mark.parametrize("system", [None])
def test_step9_gmx_grompp(config_path, iteration, ensemble, mutation, system):
    if (ensemble == "stateA"):
        pdb_path = global_state_pdb_list[iteration]
        step9_gmx_grompp(config_path, pdb_path, ensemble, mutation, system)


@pytest.mark.parametrize("ensemble, mutation", list(global_mutations.items())[1:2])
@pytest.mark.parametrize("iteration", range(len(global_state_pdb_list)))
@pytest.mark.parametrize("system", [None])
def test_step10_gmx_mdrun(config_path, iteration, ensemble, mutation, system):
    if (ensemble == "stateA"):
        pdb_path = global_state_pdb_list[iteration]
        step10_gmx_mdrun(config_path, pdb_path, ensemble, mutation, system)


@pytest.mark.parametrize("system", [None])
def test_final_step(config_path, remove_flag, system):
    final_step(config_path, remove_flag, system)
