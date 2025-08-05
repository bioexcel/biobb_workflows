import pytest
import glob
import re
import os
from pathlib import Path
from biobb_common.configuration import settings
from biobb_common.tools import file_utils as fu
from biobb_common.tools import test_fixtures as fx
from biobb_chemistry.ambertools.reduce_remove_hydrogens import reduce_remove_hydrogens
from biobb_structure_utils.utils.extract_molecule import extract_molecule
from biobb_structure_utils.utils.cat_pdb import cat_pdb
from biobb_model.model.fix_side_chain import fix_side_chain
from biobb_model.model.mutate import mutate
from biobb_gromacs.gromacs.pdb2gmx import pdb2gmx
from biobb_gromacs.gromacs.editconf import editconf
from biobb_gromacs.gromacs.solvate import solvate
from biobb_gromacs.gromacs.grompp import grompp
from biobb_gromacs.gromacs.genion import genion
from biobb_gromacs.gromacs.mdrun import mdrun
from biobb_gromacs.gromacs.make_ndx import make_ndx
from biobb_analysis.gromacs.gmx_energy import gmx_energy
from biobb_analysis.gromacs.gmx_rgyr import gmx_rgyr
from biobb_analysis.gromacs.gmx_trjconv_str import gmx_trjconv_str
from biobb_analysis.gromacs.gmx_image import gmx_image
from biobb_analysis.gromacs.gmx_rms import gmx_rms

global_work_dir = None
global_mutations = []


def setup_globals(config, system=None):
    global global_work_dir
    global global_mutations

    conf = settings.ConfReader(config, system)
    global_work_dir = conf.get_working_dir_path()
    global_mutations = conf.properties['global_properties']['mutations']


setup_globals("../../python/workflow.yml")


def step0_reduce_remove_hydrogens(config, system=None):
    conf = settings.ConfReader(config, system)
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    reduce_remove_hydrogens(**global_paths["step0_reduce_remove_hydrogens"], properties=global_prop["step0_reduce_remove_hydrogens"])

    assert fx.not_empty(global_paths["step0_reduce_remove_hydrogens"]["output_path"])
    assert fx.equal(global_paths["step0_reduce_remove_hydrogens"]["output_path"], f'reference/step0_reduce_remove_hydrogens/{Path(global_paths["step0_reduce_remove_hydrogens"]["output_path"]).name}')


def step1_extract_molecule(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    extract_molecule(**global_paths["step1_extract_molecule"], properties=global_prop["step1_extract_molecule"])

    assert fx.not_empty(global_paths["step1_extract_molecule"]["output_molecule_path"])
    assert fx.equal(global_paths["step1_extract_molecule"]["output_molecule_path"], f'reference/step1_extract_molecule/{Path(global_paths["step1_extract_molecule"]["output_molecule_path"]).name}')


def step00_cat_pdb(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    cat_pdb(**global_paths["step00_cat_pdb"], properties=global_prop["step00_cat_pdb"])

    assert fx.not_empty(global_paths["step00_cat_pdb"]["output_structure_path"])
    assert fx.equal(global_paths["step00_cat_pdb"]["output_structure_path"], f'reference/step00_cat_pdb/{Path(global_paths["step00_cat_pdb"]["output_structure_path"]).name}')


def step2_fix_side_chain(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    fix_side_chain(**global_paths["step2_fix_side_chain"], properties=global_prop["step2_fix_side_chain"])

    assert fx.not_empty(global_paths["step2_fix_side_chain"]["output_pdb_path"])
    assert fx.equal(global_paths["step2_fix_side_chain"]["output_pdb_path"], f'reference/step2_fix_side_chain/{Path(global_paths["step2_fix_side_chain"]["output_pdb_path"]).name}')


def step3_mutate(config, mutation, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    prop = conf.get_prop_dic(prefix=mutation, global_log=global_log)
    global_paths = conf.get_paths_dic()
    paths = conf.get_paths_dic(prefix=mutation)

    prop['step3_mutate']['mutation_list'] = mutation
    paths['step3_mutate']['input_pdb_path'] = global_paths['step2_fix_side_chain']['output_pdb_path']
    mutate(**paths["step3_mutate"], properties=prop["step3_mutate"])

    assert fx.not_empty(paths["step3_mutate"]["output_pdb_path"])


def step4_pdb2gmx(config, mutation, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    prop = conf.get_prop_dic(prefix=mutation, global_log=global_log)
    paths = conf.get_paths_dic(prefix=mutation)

    pdb2gmx(**paths["step4_pdb2gmx"], properties=prop["step4_pdb2gmx"])

    assert fx.not_empty(paths["step4_pdb2gmx"]["output_gro_path"])
    assert fx.not_empty(paths["step4_pdb2gmx"]["output_top_zip_path"])


def step5_editconf(config, mutation, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    prop = conf.get_prop_dic(prefix=mutation, global_log=global_log)
    paths = conf.get_paths_dic(prefix=mutation)

    editconf(**paths["step5_editconf"], properties=prop["step5_editconf"])

    assert fx.not_empty(paths["step5_editconf"]["output_gro_path"])


def step6_solvate(config, mutation, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    prop = conf.get_prop_dic(prefix=mutation, global_log=global_log)
    paths = conf.get_paths_dic(prefix=mutation)

    solvate(**paths["step6_solvate"], properties=prop["step6_solvate"])

    assert fx.not_empty(paths["step6_solvate"]["output_gro_path"])
    assert fx.not_empty(paths["step6_solvate"]["output_top_zip_path"])


def step7_grompp_genion(config, mutation, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    prop = conf.get_prop_dic(prefix=mutation, global_log=global_log)
    paths = conf.get_paths_dic(prefix=mutation)

    grompp(**paths["step7_grompp_genion"], properties=prop["step7_grompp_genion"])

    assert fx.not_empty(paths["step7_grompp_genion"]["output_tpr_path"])


def step8_genion(config, mutation, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    prop = conf.get_prop_dic(prefix=mutation, global_log=global_log)
    paths = conf.get_paths_dic(prefix=mutation)

    genion(**paths["step8_genion"], properties=prop["step8_genion"])

    assert fx.not_empty(paths["step8_genion"]["output_gro_path"])
    assert fx.not_empty(paths["step8_genion"]["output_top_zip_path"])


def step9_grompp_min(config, mutation, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    prop = conf.get_prop_dic(prefix=mutation, global_log=global_log)
    paths = conf.get_paths_dic(prefix=mutation)

    grompp(**paths["step9_grompp_min"], properties=prop["step9_grompp_min"])

    assert fx.not_empty(paths["step9_grompp_min"]["output_tpr_path"])


def step10_mdrun_min(config, mutation, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    prop = conf.get_prop_dic(prefix=mutation, global_log=global_log)
    paths = conf.get_paths_dic(prefix=mutation)

    mdrun(**paths["step10_mdrun_min"], properties=prop["step10_mdrun_min"])

    assert fx.not_empty(paths["step10_mdrun_min"]["output_trr_path"])
    assert fx.not_empty(paths["step10_mdrun_min"]["output_gro_path"])
    assert fx.not_empty(paths["step10_mdrun_min"]["output_edr_path"])
    assert fx.not_empty(paths["step10_mdrun_min"]["output_log_path"])


def step100_make_ndx(config, mutation, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    prop = conf.get_prop_dic(prefix=mutation, global_log=global_log)
    paths = conf.get_paths_dic(prefix=mutation)

    make_ndx(**paths["step100_make_ndx"], properties=prop["step100_make_ndx"])

    assert fx.not_empty(paths["step100_make_ndx"]["output_ndx_path"])


def step11_grompp_nvt(config, mutation, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    prop = conf.get_prop_dic(prefix=mutation, global_log=global_log)
    paths = conf.get_paths_dic(prefix=mutation)

    grompp(**paths["step11_grompp_nvt"], properties=prop["step11_grompp_nvt"])

    assert fx.not_empty(paths["step11_grompp_nvt"]["output_tpr_path"])


def step12_mdrun_nvt(config, mutation, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    prop = conf.get_prop_dic(prefix=mutation, global_log=global_log)
    paths = conf.get_paths_dic(prefix=mutation)

    mdrun(**paths["step12_mdrun_nvt"], properties=prop["step12_mdrun_nvt"])

    assert fx.not_empty(paths["step12_mdrun_nvt"]["output_trr_path"])
    assert fx.not_empty(paths["step12_mdrun_nvt"]["output_gro_path"])
    assert fx.not_empty(paths["step12_mdrun_nvt"]["output_edr_path"])
    assert fx.not_empty(paths["step12_mdrun_nvt"]["output_log_path"])
    assert fx.not_empty(paths["step12_mdrun_nvt"]["output_cpt_path"])


def step13_grompp_npt(config, mutation, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    prop = conf.get_prop_dic(prefix=mutation, global_log=global_log)
    paths = conf.get_paths_dic(prefix=mutation)

    grompp(**paths["step13_grompp_npt"], properties=prop["step13_grompp_npt"])

    assert fx.not_empty(paths["step13_grompp_npt"]["output_tpr_path"])


def step14_mdrun_npt(config, mutation, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    prop = conf.get_prop_dic(prefix=mutation, global_log=global_log)
    paths = conf.get_paths_dic(prefix=mutation)

    mdrun(**paths["step14_mdrun_npt"], properties=prop["step14_mdrun_npt"])

    assert fx.not_empty(paths["step14_mdrun_npt"]["output_trr_path"])
    assert fx.not_empty(paths["step14_mdrun_npt"]["output_gro_path"])
    assert fx.not_empty(paths["step14_mdrun_npt"]["output_edr_path"])
    assert fx.not_empty(paths["step14_mdrun_npt"]["output_log_path"])
    assert fx.not_empty(paths["step14_mdrun_npt"]["output_cpt_path"])


def step15_grompp_md(config, mutation, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    prop = conf.get_prop_dic(prefix=mutation, global_log=global_log)
    paths = conf.get_paths_dic(prefix=mutation)

    grompp(**paths["step15_grompp_md"], properties=prop["step15_grompp_md"])

    assert fx.not_empty(paths["step15_grompp_md"]["output_tpr_path"])


def step16_mdrun_md(config, mutation, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    prop = conf.get_prop_dic(prefix=mutation, global_log=global_log)
    paths = conf.get_paths_dic(prefix=mutation)

    mdrun(**paths["step16_mdrun_md"], properties=prop["step16_mdrun_md"])

    assert fx.not_empty(paths["step16_mdrun_md"]["output_trr_path"])
    assert fx.not_empty(paths["step16_mdrun_md"]["output_gro_path"])
    assert fx.not_empty(paths["step16_mdrun_md"]["output_edr_path"])
    assert fx.not_empty(paths["step16_mdrun_md"]["output_log_path"])
    assert fx.not_empty(paths["step16_mdrun_md"]["output_cpt_path"])


def step17_gmx_image1(config, mutation, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    prop = conf.get_prop_dic(prefix=mutation, global_log=global_log)
    paths = conf.get_paths_dic(prefix=mutation)

    gmx_image(**paths["step17_gmx_image1"], properties=prop["step17_gmx_image1"])

    assert fx.not_empty(paths["step17_gmx_image1"]["output_traj_path"])


def step18_gmx_image2(config, mutation, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    prop = conf.get_prop_dic(prefix=mutation, global_log=global_log)
    paths = conf.get_paths_dic(prefix=mutation)

    gmx_image(**paths["step18_gmx_image2"], properties=prop["step18_gmx_image2"])

    assert fx.not_empty(paths["step18_gmx_image2"]["output_traj_path"])


def step19_gmx_trjconv_str(config, mutation, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    prop = conf.get_prop_dic(prefix=mutation, global_log=global_log)
    paths = conf.get_paths_dic(prefix=mutation)

    gmx_trjconv_str(**paths["step19_gmx_trjconv_str"], properties=prop["step19_gmx_trjconv_str"])

    assert fx.not_empty(paths["step19_gmx_trjconv_str"]["output_str_path"])


def step20_gmx_energy(config, mutation, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    prop = conf.get_prop_dic(prefix=mutation, global_log=global_log)
    paths = conf.get_paths_dic(prefix=mutation)

    gmx_energy(**paths["step20_gmx_energy"], properties=prop["step20_gmx_energy"])

    assert fx.not_empty(paths["step20_gmx_energy"]["output_xvg_path"])


def step21_gmx_rgyr(config, mutation, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    prop = conf.get_prop_dic(prefix=mutation, global_log=global_log)
    paths = conf.get_paths_dic(prefix=mutation)

    gmx_rgyr(**paths["step21_gmx_rgyr"], properties=prop["step21_gmx_rgyr"])

    assert fx.not_empty(paths["step21_gmx_rgyr"]["output_xvg_path"])


def step22_rmsd_first(config, mutation, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    prop = conf.get_prop_dic(prefix=mutation, global_log=global_log)
    paths = conf.get_paths_dic(prefix=mutation)

    gmx_rms(**paths["step22_rmsd_first"], properties=prop["step22_rmsd_first"])

    assert fx.not_empty(paths["step22_rmsd_first"]["output_xvg_path"])


def step23_rmsd_exp(config, mutation, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    prop = conf.get_prop_dic(prefix=mutation, global_log=global_log)
    paths = conf.get_paths_dic(prefix=mutation)

    gmx_rms(**paths["step23_rmsd_exp"], properties=prop["step23_rmsd_exp"])

    assert fx.not_empty(paths["step23_rmsd_exp"]["output_xvg_path"])
    assert fx.compare_size(paths["step23_rmsd_exp"]["output_xvg_path"], f'reference/{mutation}/step23_rmsd_exp/{Path(paths["step23_rmsd_exp"]["output_xvg_path"]).name}', 90)


def final_step(config, remove=False, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir

    if remove:
        tmp_files = [conf.get_working_dir_path()]
        tmp_files.extend(glob.glob('*.stdin'))
        pattern = re.compile(r'[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}')
        uuid_dirs = [d for d in glob.glob('*') if os.path.isdir(d) and pattern.match(d)]
        tmp_files.extend(uuid_dirs)
        fu.rm_file_list(tmp_files)


@pytest.mark.parametrize("system", [None])
def test_step0_reduce_remove_hydrogens(config_path, system):
    step0_reduce_remove_hydrogens(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step1_extract_molecule(config_path, system):
    step1_extract_molecule(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step00_cat_pdb(config_path, system):
    step00_cat_pdb(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step2_fix_side_chain(config_path, system):
    step2_fix_side_chain(config_path, system)


@pytest.mark.parametrize("iteration", range(len(global_mutations)))
@pytest.mark.parametrize("system", [None])
def test_step3_mutate(config_path, iteration, system):
    current_mutation = global_mutations[iteration]
    step3_mutate(config_path, current_mutation, system)


@pytest.mark.parametrize("iteration", range(len(global_mutations)))
@pytest.mark.parametrize("system", [None])
def test_step4_pdb2gmx(config_path, iteration, system):
    current_mutation = global_mutations[iteration]
    step4_pdb2gmx(config_path, current_mutation, system)


@pytest.mark.parametrize("iteration", range(len(global_mutations)))
@pytest.mark.parametrize("system", [None])
def test_step5_editconf(config_path, iteration, system):
    current_mutation = global_mutations[iteration]
    step5_editconf(config_path, current_mutation, system)


@pytest.mark.parametrize("iteration", range(len(global_mutations)))
@pytest.mark.parametrize("system", [None])
def test_step6_solvate(config_path, iteration, system):
    current_mutation = global_mutations[iteration]
    step6_solvate(config_path, current_mutation, system)


@pytest.mark.parametrize("iteration", range(len(global_mutations)))
@pytest.mark.parametrize("system", [None])
def test_step7_grompp_genion(config_path, iteration, system):
    current_mutation = global_mutations[iteration]
    step7_grompp_genion(config_path, current_mutation, system)


@pytest.mark.parametrize("iteration", range(len(global_mutations)))
@pytest.mark.parametrize("system", [None])
def test_step8_genion(config_path, iteration, system):
    current_mutation = global_mutations[iteration]
    step8_genion(config_path, current_mutation, system)


@pytest.mark.parametrize("iteration", range(len(global_mutations)))
@pytest.mark.parametrize("system", [None])
def test_step9_grompp_min(config_path, iteration, system):
    current_mutation = global_mutations[iteration]
    step9_grompp_min(config_path, current_mutation, system)


@pytest.mark.parametrize("iteration", range(len(global_mutations)))
@pytest.mark.parametrize("system", [None])
def test_step10_mdrun_min(config_path, iteration, system):
    current_mutation = global_mutations[iteration]
    step10_mdrun_min(config_path, current_mutation, system)


@pytest.mark.parametrize("iteration", range(len(global_mutations)))
@pytest.mark.parametrize("system", [None])
def test_step100_make_ndx(config_path, iteration, system):
    current_mutation = global_mutations[iteration]
    step100_make_ndx(config_path, current_mutation, system)


@pytest.mark.parametrize("iteration", range(len(global_mutations)))
@pytest.mark.parametrize("system", [None])
def test_step11_grompp_nvt(config_path, iteration, system):
    current_mutation = global_mutations[iteration]
    step11_grompp_nvt(config_path, current_mutation, system)


@pytest.mark.parametrize("iteration", range(len(global_mutations)))
@pytest.mark.parametrize("system", [None])
def test_step12_mdrun_nvt(config_path, iteration, system):
    current_mutation = global_mutations[iteration]
    step12_mdrun_nvt(config_path, current_mutation, system)


@pytest.mark.parametrize("iteration", range(len(global_mutations)))
@pytest.mark.parametrize("system", [None])
def test_step13_grompp_npt(config_path, iteration, system):
    current_mutation = global_mutations[iteration]
    step13_grompp_npt(config_path, current_mutation, system)


@pytest.mark.parametrize("iteration", range(len(global_mutations)))
@pytest.mark.parametrize("system", [None])
def test_step14_mdrun_npt(config_path, iteration, system):
    current_mutation = global_mutations[iteration]
    step14_mdrun_npt(config_path, current_mutation, system)


@pytest.mark.parametrize("iteration", range(len(global_mutations)))
@pytest.mark.parametrize("system", [None])
def test_step15_grompp_md(config_path, iteration, system):
    current_mutation = global_mutations[iteration]
    step15_grompp_md(config_path, current_mutation, system)


@pytest.mark.parametrize("iteration", range(len(global_mutations)))
@pytest.mark.parametrize("system", [None])
def test_step16_mdrun_md(config_path, iteration, system):
    current_mutation = global_mutations[iteration]
    step16_mdrun_md(config_path, current_mutation, system)


@pytest.mark.parametrize("iteration", range(len(global_mutations)))
@pytest.mark.parametrize("system", [None])
def test_step17_gmx_image1(config_path, iteration, system):
    current_mutation = global_mutations[iteration]
    step17_gmx_image1(config_path, current_mutation, system)


@pytest.mark.parametrize("iteration", range(len(global_mutations)))
@pytest.mark.parametrize("system", [None])
def test_step18_gmx_image2(config_path, iteration, system):
    current_mutation = global_mutations[iteration]
    step18_gmx_image2(config_path, current_mutation, system)


@pytest.mark.parametrize("iteration", range(len(global_mutations)))
@pytest.mark.parametrize("system", [None])
def test_step19_gmx_trjconv_str(config_path, iteration, system):
    current_mutation = global_mutations[iteration]
    step19_gmx_trjconv_str(config_path, current_mutation, system)


@pytest.mark.parametrize("iteration", range(len(global_mutations)))
@pytest.mark.parametrize("system", [None])
def test_step20_gmx_energy(config_path, iteration, system):
    current_mutation = global_mutations[iteration]
    step20_gmx_energy(config_path, current_mutation, system)


# @pytest.mark.parametrize("iteration", range(len(global_mutations)))
# @pytest.mark.parametrize("system", [None])
# def test_step21_gmx_rgyr(config_path, iteration, system):
#     current_mutation = global_mutations[iteration]
#     step21_gmx_rgyr(config_path, current_mutation, system)


@pytest.mark.parametrize("iteration", range(len(global_mutations)))
@pytest.mark.parametrize("system", [None])
def test_step22_rmsd_first(config_path, iteration, system):
    current_mutation = global_mutations[iteration]
    step22_rmsd_first(config_path, current_mutation, system)


@pytest.mark.parametrize("iteration", range(len(global_mutations)))
@pytest.mark.parametrize("system", [None])
def test_step23_rmsd_exp(config_path, iteration, system):
    current_mutation = global_mutations[iteration]
    step23_rmsd_exp(config_path, current_mutation, system)


@pytest.mark.parametrize("system", [None])
def test_final_step(config_path, remove_flag, system):
    final_step(config_path, remove_flag, system)
