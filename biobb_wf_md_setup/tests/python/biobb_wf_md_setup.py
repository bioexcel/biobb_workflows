import pytest
import glob
from pathlib import Path
from biobb_common.configuration import settings
from biobb_common.tools import file_utils as fu
from biobb_common.tools import test_fixtures as fx
from biobb_chemistry.ambertools.reduce_remove_hydrogens import reduce_remove_hydrogens
from biobb_structure_utils.utils.extract_molecule import extract_molecule
from biobb_structure_utils.utils.cat_pdb import cat_pdb
from biobb_model.model.fix_side_chain import fix_side_chain
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


def step0_reduce_remove_hydrogens(config, system=None):
    conf = settings.ConfReader(config, system)
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    reduce_remove_hydrogens(**global_paths["step0_reduce_remove_hydrogens"], properties=global_prop["step0_reduce_remove_hydrogens"])

    assert fx.not_empty(global_paths["step0_reduce_remove_hydrogens"]["output_path"])
    assert fx.equal(global_paths["step0_reduce_remove_hydrogens"]["output_path"], f'reference/step0_reduce_remove_hydrogens/{Path(global_paths["step0_reduce_remove_hydrogens"]["output_path"]).name}')

    global global_work_dir
    global_work_dir = conf.get_working_dir_path()


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


def step4_pdb2gmx(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    pdb2gmx(**global_paths["step4_pdb2gmx"], properties=global_prop["step4_pdb2gmx"])

    assert fx.not_empty(global_paths["step4_pdb2gmx"]["output_gro_path"])
    assert fx.equal(global_paths["step4_pdb2gmx"]["output_gro_path"], f'reference/step4_pdb2gmx/{Path(global_paths["step4_pdb2gmx"]["output_gro_path"]).name}')
    assert fx.not_empty(global_paths["step4_pdb2gmx"]["output_top_zip_path"])
    assert fx.equal(global_paths["step4_pdb2gmx"]["output_top_zip_path"], f'reference/step4_pdb2gmx/{Path(global_paths["step4_pdb2gmx"]["output_top_zip_path"]).name}')


def step5_editconf(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    editconf(**global_paths["step5_editconf"], properties=global_prop["step5_editconf"])

    assert fx.not_empty(global_paths["step5_editconf"]["output_gro_path"])
    assert fx.equal(global_paths["step5_editconf"]["output_gro_path"], f'reference/step5_editconf/{Path(global_paths["step5_editconf"]["output_gro_path"]).name}')


def step6_solvate(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    solvate(**global_paths["step6_solvate"], properties=global_prop["step6_solvate"])

    assert fx.not_empty(global_paths["step6_solvate"]["output_gro_path"])
    assert fx.equal(global_paths["step6_solvate"]["output_gro_path"], f'reference/step6_solvate/{Path(global_paths["step6_solvate"]["output_gro_path"]).name}')
    assert fx.not_empty(global_paths["step6_solvate"]["output_top_zip_path"])
    assert fx.equal(global_paths["step6_solvate"]["output_top_zip_path"], f'reference/step6_solvate/{Path(global_paths["step6_solvate"]["output_top_zip_path"]).name}')


def step7_grompp_genion(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    grompp(**global_paths["step7_grompp_genion"], properties=global_prop["step7_grompp_genion"])

    assert fx.not_empty(global_paths["step7_grompp_genion"]["output_tpr_path"])
    assert fx.equal(global_paths["step7_grompp_genion"]["output_tpr_path"], f'reference/step7_grompp_genion/{Path(global_paths["step7_grompp_genion"]["output_tpr_path"]).name}')


def step8_genion(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    genion(**global_paths["step8_genion"], properties=global_prop["step8_genion"])

    assert fx.not_empty(global_paths["step8_genion"]["output_gro_path"])
    assert fx.equal(global_paths["step8_genion"]["output_gro_path"], f'reference/step8_genion/{Path(global_paths["step8_genion"]["output_gro_path"]).name}')
    assert fx.not_empty(global_paths["step8_genion"]["output_top_zip_path"])
    assert fx.equal(global_paths["step8_genion"]["output_top_zip_path"], f'reference/step8_genion/{Path(global_paths["step8_genion"]["output_top_zip_path"]).name}')


def step9_grompp_min(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    grompp(**global_paths["step9_grompp_min"], properties=global_prop["step9_grompp_min"])

    assert fx.not_empty(global_paths["step9_grompp_min"]["output_tpr_path"])
    assert fx.equal(global_paths["step9_grompp_min"]["output_tpr_path"], f'reference/step9_grompp_min/{Path(global_paths["step9_grompp_min"]["output_tpr_path"]).name}')


def step10_mdrun_min(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    mdrun(**global_paths["step10_mdrun_min"], properties=global_prop["step10_mdrun_min"])

    assert fx.not_empty(global_paths["step10_mdrun_min"]["output_trr_path"])
    assert fx.equal(global_paths["step10_mdrun_min"]["output_trr_path"], f'reference/step10_mdrun_min/{Path(global_paths["step10_mdrun_min"]["output_trr_path"]).name}')
    assert fx.not_empty(global_paths["step10_mdrun_min"]["output_gro_path"])
    assert fx.equal(global_paths["step10_mdrun_min"]["output_gro_path"], f'reference/step10_mdrun_min/{Path(global_paths["step10_mdrun_min"]["output_gro_path"]).name}')
    assert fx.not_empty(global_paths["step10_mdrun_min"]["output_edr_path"])
    assert fx.equal(global_paths["step10_mdrun_min"]["output_edr_path"], f'reference/step10_mdrun_min/{Path(global_paths["step10_mdrun_min"]["output_edr_path"]).name}')
    assert fx.not_empty(global_paths["step10_mdrun_min"]["output_log_path"])
    assert fx.equal(global_paths["step10_mdrun_min"]["output_log_path"], f'reference/step10_mdrun_min/{Path(global_paths["step10_mdrun_min"]["output_log_path"]).name}')


def step100_make_ndx(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    make_ndx(**global_paths["step100_make_ndx"], properties=global_prop["step100_make_ndx"])

    assert fx.not_empty(global_paths["step100_make_ndx"]["output_ndx_path"])
    assert fx.equal(global_paths["step100_make_ndx"]["output_ndx_path"], f'reference/step100_make_ndx/{Path(global_paths["step100_make_ndx"]["output_ndx_path"]).name}')


def step11_grompp_nvt(config, system=None):
    conf = settings.ConfReader(config, system)
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    grompp(**global_paths["step11_grompp_nvt"], properties=global_prop["step11_grompp_nvt"])

    assert fx.not_empty(global_paths["step11_grompp_nvt"]["output_tpr_path"])
    assert fx.equal(global_paths["step11_grompp_nvt"]["output_tpr_path"], f'reference/step11_grompp_nvt/{Path(global_paths["step11_grompp_nvt"]["output_tpr_path"]).name}')


def step12_mdrun_nvt(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    mdrun(**global_paths["step12_mdrun_nvt"], properties=global_prop["step12_mdrun_nvt"])

    assert fx.not_empty(global_paths["step12_mdrun_nvt"]["output_trr_path"])
    assert fx.equal(global_paths["step12_mdrun_nvt"]["output_trr_path"], f'reference/step12_mdrun_nvt/{Path(global_paths["step12_mdrun_nvt"]["output_trr_path"]).name}')
    assert fx.not_empty(global_paths["step12_mdrun_nvt"]["output_gro_path"])
    assert fx.equal(global_paths["step12_mdrun_nvt"]["output_gro_path"], f'reference/step12_mdrun_nvt/{Path(global_paths["step12_mdrun_nvt"]["output_gro_path"]).name}')
    assert fx.not_empty(global_paths["step12_mdrun_nvt"]["output_edr_path"])
    assert fx.equal(global_paths["step12_mdrun_nvt"]["output_edr_path"], f'reference/step12_mdrun_nvt/{Path(global_paths["step12_mdrun_nvt"]["output_edr_path"]).name}')
    assert fx.not_empty(global_paths["step12_mdrun_nvt"]["output_log_path"])
    assert fx.equal(global_paths["step12_mdrun_nvt"]["output_log_path"], f'reference/step12_mdrun_nvt/{Path(global_paths["step12_mdrun_nvt"]["output_log_path"]).name}')


def step13_grompp_npt(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    grompp(**global_paths["step13_grompp_npt"], properties=global_prop["step13_grompp_npt"])

    assert fx.not_empty(global_paths["step13_grompp_npt"]["output_tpr_path"])
    assert fx.equal(global_paths["step13_grompp_npt"]["output_tpr_path"], f'reference/step13_grompp_npt/{Path(global_paths["step13_grompp_npt"]["output_tpr_path"]).name}')


def step14_mdrun_npt(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    mdrun(**global_paths["step14_mdrun_npt"], properties=global_prop["step14_mdrun_npt"])

    assert fx.not_empty(global_paths["step14_mdrun_npt"]["output_trr_path"])
    assert fx.equal(global_paths["step14_mdrun_npt"]["output_trr_path"], f'reference/step14_mdrun_npt/{Path(global_paths["step14_mdrun_npt"]["output_trr_path"]).name}')
    assert fx.not_empty(global_paths["step14_mdrun_npt"]["output_gro_path"])
    assert fx.equal(global_paths["step14_mdrun_npt"]["output_gro_path"], f'reference/step14_mdrun_npt/{Path(global_paths["step14_mdrun_npt"]["output_gro_path"]).name}')
    assert fx.not_empty(global_paths["step14_mdrun_npt"]["output_edr_path"])
    assert fx.equal(global_paths["step14_mdrun_npt"]["output_edr_path"], f'reference/step14_mdrun_npt/{Path(global_paths["step14_mdrun_npt"]["output_edr_path"]).name}')
    assert fx.not_empty(global_paths["step14_mdrun_npt"]["output_log_path"])
    assert fx.equal(global_paths["step14_mdrun_npt"]["output_log_path"], f'reference/step14_mdrun_npt/{Path(global_paths["step14_mdrun_npt"]["output_log_path"]).name}')


def step15_grompp_md(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    grompp(**global_paths["step15_grompp_md"], properties=global_prop["step15_grompp_md"])

    assert fx.not_empty(global_paths["step15_grompp_md"]["output_tpr_path"])
    assert fx.equal(global_paths["step15_grompp_md"]["output_tpr_path"], f'reference/step15_grompp_md/{Path(global_paths["step15_grompp_md"]["output_tpr_path"]).name}')


def step16_mdrun_md(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    mdrun(**global_paths["step16_mdrun_md"], properties=global_prop["step16_mdrun_md"])

    assert fx.not_empty(global_paths["step16_mdrun_md"]["output_trr_path"])
    assert fx.equal(global_paths["step16_mdrun_md"]["output_trr_path"], f'reference/step16_mdrun_md/{Path(global_paths["step16_mdrun_md"]["output_trr_path"]).name}')
    assert fx.not_empty(global_paths["step16_mdrun_md"]["output_gro_path"])
    assert fx.equal(global_paths["step16_mdrun_md"]["output_gro_path"], f'reference/step16_mdrun_md/{Path(global_paths["step16_mdrun_md"]["output_gro_path"]).name}')
    assert fx.not_empty(global_paths["step16_mdrun_md"]["output_edr_path"])
    assert fx.equal(global_paths["step16_mdrun_md"]["output_edr_path"], f'reference/step16_mdrun_md/{Path(global_paths["step16_mdrun_md"]["output_edr_path"]).name}')
    assert fx.not_empty(global_paths["step16_mdrun_md"]["output_log_path"])
    assert fx.equal(global_paths["step16_mdrun_md"]["output_log_path"], f'reference/step16_mdrun_md/{Path(global_paths["step16_mdrun_md"]["output_log_path"]).name}')


def step17_gmx_image1(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    gmx_image(**global_paths["step17_gmx_image1"], properties=global_prop["step17_gmx_image1"])

    assert fx.not_empty(global_paths["step17_gmx_image1"]["output_traj_path"])
    assert fx.equal(global_paths["step17_gmx_image1"]["output_traj_path"], f'reference/step17_gmx_image1/{Path(global_paths["step17_gmx_image1"]["output_traj_path"]).name}')


def step18_gmx_image2(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    gmx_image(**global_paths["step18_gmx_image2"], properties=global_prop["step18_gmx_image2"])

    assert fx.not_empty(global_paths["step18_gmx_image2"]["output_traj_path"])
    assert fx.equal(global_paths["step18_gmx_image2"]["output_traj_path"], f'reference/step18_gmx_image2/{Path(global_paths["step18_gmx_image2"]["output_traj_path"]).name}')


def step19_gmx_trjconv_str(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    gmx_trjconv_str(**global_paths["step19_gmx_trjconv_str"], properties=global_prop["step19_gmx_trjconv_str"])

    assert fx.not_empty(global_paths["step19_gmx_trjconv_str"]["output_str_path"])
    assert fx.equal(global_paths["step19_gmx_trjconv_str"]["output_str_path"], f'reference/step19_gmx_trjconv_str/{Path(global_paths["step19_gmx_trjconv_str"]["output_str_path"]).name}')


def step20_gmx_energy(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    gmx_energy(**global_paths["step20_gmx_energy"], properties=global_prop["step20_gmx_energy"])

    assert fx.not_empty(global_paths["step20_gmx_energy"]["output_xvg_path"])
    assert fx.equal(global_paths["step20_gmx_energy"]["output_xvg_path"], f'reference/step20_gmx_energy/{Path(global_paths["step20_gmx_energy"]["output_xvg_path"]).name}')


def step21_gmx_rgyr(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    gmx_rgyr(**global_paths["step21_gmx_rgyr"], properties=global_prop["step21_gmx_rgyr"])

    assert fx.not_empty(global_paths["step21_gmx_rgyr"]["output_xvg_path"])
    assert fx.equal(global_paths["step21_gmx_rgyr"]["output_xvg_path"], f'reference/step21_gmx_rgyr/{Path(global_paths["step21_gmx_rgyr"]["output_xvg_path"]).name}')


def step22_rmsd_first(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    gmx_rms(**global_paths["step22_rmsd_first"], properties=global_prop["step22_rmsd_first"])

    assert fx.not_empty(global_paths["step22_rmsd_first"]["output_xvg_path"])
    assert fx.equal(global_paths["step22_rmsd_first"]["output_xvg_path"], f'reference/step22_rmsd_first/{Path(global_paths["step22_rmsd_first"]["output_xvg_path"]).name}')


def step23_rmsd_exp(config, remove=False, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    gmx_rms(**global_paths["step23_rmsd_exp"], properties=global_prop["step23_rmsd_exp"])

    assert fx.not_empty(global_paths["step23_rmsd_exp"]["output_xvg_path"])
    assert fx.equal(global_paths["step23_rmsd_exp"]["output_xvg_path"], f'reference/step23_rmsd_exp/{Path(global_paths["step23_rmsd_exp"]["output_xvg_path"]).name}')

    if remove:
        tmp_files = [conf.get_working_dir_path(), 'fort.7', 'gridout', 'restart']
        tmp_files.extend(glob.glob('sandbox_*'))
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


@pytest.mark.parametrize("system", [None])
def test_step4_pdb2gmx(config_path, system):
    step4_pdb2gmx(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step5_editconf(config_path, system):
    step5_editconf(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step6_solvate(config_path, system):
    step6_solvate(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step7_grompp_genion(config_path, system):
    step7_grompp_genion(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step8_genion(config_path, system):
    step8_genion(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step9_grompp_min(config_path, system):
    step9_grompp_min(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step10_mdrun_min(config_path, system):
    step10_mdrun_min(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step100_make_ndx(config_path, system):
    step100_make_ndx(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step11_grompp_nvt(config_path, system):
    step11_grompp_nvt(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step12_mdrun_nvt(config_path, system):
    step12_mdrun_nvt(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step13_grompp_npt(config_path, system):
    step13_grompp_npt(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step14_mdrun_npt(config_path, system):
    step14_mdrun_npt(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step15_grompp_md(config_path, system):
    step15_grompp_md(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step16_mdrun_md(config_path, system):
    step16_mdrun_md(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step17_gmx_image1(config_path, system):
    step17_gmx_image1(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step18_gmx_image2(config_path, system):
    step18_gmx_image2(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step19_gmx_trjconv_str(config_path, system):
    step19_gmx_trjconv_str(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step20_gmx_energy(config_path, system):
    step20_gmx_energy(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step21_gmx_rgyr(config_path, system):
    step21_gmx_rgyr(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step22_rmsd_first(config_path, system):
    step22_rmsd_first(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step23_rmsd_exp(config_path, remove_flag, system):
    step23_rmsd_exp(config_path, remove_flag, system)
