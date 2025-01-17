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
from biobb_gromacs.gromacs.make_ndx import make_ndx
from biobb_gromacs.gromacs.genrestr import genrestr
from biobb_analysis.gromacs.gmx_trjconv_str import gmx_trjconv_str
from biobb_gromacs.gromacs_extra.append_ligand import append_ligand
from biobb_gromacs.gromacs.editconf import editconf
from biobb_gromacs.gromacs.solvate import solvate
from biobb_gromacs.gromacs.grompp import grompp
from biobb_gromacs.gromacs.genion import genion
from biobb_gromacs.gromacs.mdrun import mdrun
from biobb_analysis.gromacs.gmx_energy import gmx_energy
from biobb_analysis.gromacs.gmx_rms import gmx_rms
from biobb_analysis.gromacs.gmx_rgyr import gmx_rgyr
from biobb_analysis.gromacs.gmx_image import gmx_image

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


def step2_extract_molecule(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    extract_molecule(**global_paths["step2_extract_molecule"], properties=global_prop["step2_extract_molecule"])

    assert fx.not_empty(global_paths["step2_extract_molecule"]["output_molecule_path"])
    assert fx.equal(global_paths["step2_extract_molecule"]["output_molecule_path"], f'reference/step2_extract_molecule/{Path(global_paths["step2_extract_molecule"]["output_molecule_path"]).name}')


def step00_cat_pdb(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    cat_pdb(**global_paths["step00_cat_pdb"], properties=global_prop["step00_cat_pdb"])

    assert fx.not_empty(global_paths["step00_cat_pdb"]["output_structure_path"])
    assert fx.equal(global_paths["step00_cat_pdb"]["output_structure_path"], f'reference/step00_cat_pdb/{Path(global_paths["step00_cat_pdb"]["output_structure_path"]).name}')


def step4_fix_side_chain(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    fix_side_chain(**global_paths["step4_fix_side_chain"], properties=global_prop["step4_fix_side_chain"])

    assert fx.not_empty(global_paths["step4_fix_side_chain"]["output_pdb_path"])
    assert fx.equal(global_paths["step4_fix_side_chain"]["output_pdb_path"], f'reference/step4_fix_side_chain/{Path(global_paths["step4_fix_side_chain"]["output_pdb_path"]).name}')


def step5_pdb2gmx(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    pdb2gmx(**global_paths["step5_pdb2gmx"], properties=global_prop["step5_pdb2gmx"])

    assert fx.not_empty(global_paths["step5_pdb2gmx"]["output_gro_path"])
    assert fx.equal(global_paths["step5_pdb2gmx"]["output_gro_path"], f'reference/step5_pdb2gmx/{Path(global_paths["step5_pdb2gmx"]["output_gro_path"]).name}')
    assert fx.not_empty(global_paths["step5_pdb2gmx"]["output_top_zip_path"])
    assert fx.equal(global_paths["step5_pdb2gmx"]["output_top_zip_path"], f'reference/step5_pdb2gmx/{Path(global_paths["step5_pdb2gmx"]["output_top_zip_path"]).name}')


def step9_make_ndx(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    make_ndx(**global_paths["step9_make_ndx"], properties=global_prop["step9_make_ndx"])

    assert fx.not_empty(global_paths["step9_make_ndx"]["output_ndx_path"])
    assert fx.equal(global_paths["step9_make_ndx"]["output_ndx_path"], f'reference/step9_make_ndx/{Path(global_paths["step9_make_ndx"]["output_ndx_path"]).name}')


def step10_genrestr(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    genrestr(**global_paths["step10_genrestr"], properties=global_prop["step10_genrestr"])

    assert fx.not_empty(global_paths["step10_genrestr"]["output_itp_path"])
    assert fx.equal(global_paths["step10_genrestr"]["output_itp_path"], f'reference/step10_genrestr/{Path(global_paths["step10_genrestr"]["output_itp_path"]).name}')


def step11_gmx_trjconv_str_protein(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    gmx_trjconv_str(**global_paths["step11_gmx_trjconv_str_protein"], properties=global_prop["step11_gmx_trjconv_str_protein"])

    assert fx.not_empty(global_paths["step11_gmx_trjconv_str_protein"]["output_str_path"])
    assert fx.equal(global_paths["step11_gmx_trjconv_str_protein"]["output_str_path"], f'reference/step11_gmx_trjconv_str_protein/{Path(global_paths["step11_gmx_trjconv_str_protein"]["output_str_path"]).name}')


def step12_gmx_trjconv_str_ligand(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    gmx_trjconv_str(**global_paths["step12_gmx_trjconv_str_ligand"], properties=global_prop["step12_gmx_trjconv_str_ligand"])

    assert fx.not_empty(global_paths["step12_gmx_trjconv_str_ligand"]["output_str_path"])
    assert fx.equal(global_paths["step12_gmx_trjconv_str_ligand"]["output_str_path"], f'reference/step12_gmx_trjconv_str_ligand/{Path(global_paths["step12_gmx_trjconv_str_ligand"]["output_str_path"]).name}')


def step13_cat_pdb_hydrogens(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    cat_pdb(**global_paths["step13_cat_pdb_hydrogens"], properties=global_prop["step13_cat_pdb_hydrogens"])

    assert fx.not_empty(global_paths["step13_cat_pdb_hydrogens"]["output_structure_path"])
    assert fx.equal(global_paths["step13_cat_pdb_hydrogens"]["output_structure_path"], f'reference/step13_cat_pdb_hydrogens/{Path(global_paths["step13_cat_pdb_hydrogens"]["output_structure_path"]).name}')


def step14_append_ligand(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    append_ligand(**global_paths["step14_append_ligand"], properties=global_prop["step14_append_ligand"])

    assert fx.not_empty(global_paths["step14_append_ligand"]["output_top_zip_path"])
    assert fx.equal(global_paths["step14_append_ligand"]["output_top_zip_path"], f'reference/step14_append_ligand/{Path(global_paths["step14_append_ligand"]["output_top_zip_path"]).name}')


def step15_editconf(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    editconf(**global_paths["step15_editconf"], properties=global_prop["step15_editconf"])

    assert fx.not_empty(global_paths["step15_editconf"]["output_gro_path"])
    assert fx.equal(global_paths["step15_editconf"]["output_gro_path"], f'reference/step15_editconf/{Path(global_paths["step15_editconf"]["output_gro_path"]).name}')


def step16_solvate(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    solvate(**global_paths["step16_solvate"], properties=global_prop["step16_solvate"])

    assert fx.not_empty(global_paths["step16_solvate"]["output_gro_path"])
    assert fx.equal(global_paths["step16_solvate"]["output_gro_path"], f'reference/step16_solvate/{Path(global_paths["step16_solvate"]["output_gro_path"]).name}')
    assert fx.not_empty(global_paths["step16_solvate"]["output_top_zip_path"])
    assert fx.equal(global_paths["step16_solvate"]["output_top_zip_path"], f'reference/step16_solvate/{Path(global_paths["step16_solvate"]["output_top_zip_path"]).name}')


def step17_grompp_genion(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    grompp(**global_paths["step17_grompp_genion"], properties=global_prop["step17_grompp_genion"])

    assert fx.not_empty(global_paths["step17_grompp_genion"]["output_tpr_path"])
    # assert fx.equal(global_paths["step17_grompp_genion"]["output_tpr_path"], f'reference/step17_grompp_genion/{Path(global_paths["step17_grompp_genion"]["output_tpr_path"]).name}')


def step18_genion(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    genion(**global_paths["step18_genion"], properties=global_prop["step18_genion"])

    assert fx.not_empty(global_paths["step18_genion"]["output_gro_path"])
    assert fx.equal(global_paths["step18_genion"]["output_gro_path"], f'reference/step18_genion/{Path(global_paths["step18_genion"]["output_gro_path"]).name}')
    assert fx.not_empty(global_paths["step18_genion"]["output_top_zip_path"])
    assert fx.equal(global_paths["step18_genion"]["output_top_zip_path"], f'reference/step18_genion/{Path(global_paths["step18_genion"]["output_top_zip_path"]).name}')


def step19_grompp_min(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    grompp(**global_paths["step19_grompp_min"], properties=global_prop["step19_grompp_min"])

    assert fx.not_empty(global_paths["step19_grompp_min"]["output_tpr_path"])
    # assert fx.equal(global_paths["step19_grompp_min"]["output_tpr_path"], f'reference/step19_grompp_min/{Path(global_paths["step19_grompp_min"]["output_tpr_path"]).name}')


def step20_mdrun_min(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    mdrun(**global_paths["step20_mdrun_min"], properties=global_prop["step20_mdrun_min"])

    assert fx.not_empty(global_paths["step20_mdrun_min"]["output_trr_path"])
    # assert fx.equal(global_paths["step20_mdrun_min"]["output_trr_path"], f'reference/step20_mdrun_min/{Path(global_paths["step20_mdrun_min"]["output_trr_path"]).name}')
    assert fx.not_empty(global_paths["step20_mdrun_min"]["output_gro_path"])
    # assert fx.equal(global_paths["step20_mdrun_min"]["output_gro_path"], f'reference/step20_mdrun_min/{Path(global_paths["step20_mdrun_min"]["output_gro_path"]).name}')
    assert fx.not_empty(global_paths["step20_mdrun_min"]["output_edr_path"])
    # assert fx.equal(global_paths["step20_mdrun_min"]["output_edr_path"], f'reference/step20_mdrun_min/{Path(global_paths["step20_mdrun_min"]["output_edr_path"]).name}')
    assert fx.not_empty(global_paths["step20_mdrun_min"]["output_log_path"])
    # assert fx.equal(global_paths["step20_mdrun_min"]["output_log_path"], f'reference/step20_mdrun_min/{Path(global_paths["step20_mdrun_min"]["output_log_path"]).name}')


def step21_gmx_energy_min(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    gmx_energy(**global_paths["step21_gmx_energy_min"], properties=global_prop["step21_gmx_energy_min"])

    assert fx.not_empty(global_paths["step21_gmx_energy_min"]["output_xvg_path"])
    # assert fx.equal(global_paths["step21_gmx_energy_min"]["output_xvg_path"], f'reference/step21_gmx_energy_min/{Path(global_paths["step21_gmx_energy_min"]["output_xvg_path"]).name}')


def step22_make_ndx(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    make_ndx(**global_paths["step22_make_ndx"], properties=global_prop["step22_make_ndx"])

    assert fx.not_empty(global_paths["step22_make_ndx"]["output_ndx_path"])
    assert fx.equal(global_paths["step22_make_ndx"]["output_ndx_path"], f'reference/step22_make_ndx/{Path(global_paths["step22_make_ndx"]["output_ndx_path"]).name}')


def step23_grompp_nvt(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    grompp(**global_paths["step23_grompp_nvt"], properties=global_prop["step23_grompp_nvt"])

    assert fx.not_empty(global_paths["step23_grompp_nvt"]["output_tpr_path"])
    # assert fx.equal(global_paths["step23_grompp_nvt"]["output_tpr_path"], f'reference/step23_grompp_nvt/{Path(global_paths["step23_grompp_nvt"]["output_tpr_path"]).name}')


def step24_mdrun_nvt(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    mdrun(**global_paths["step24_mdrun_nvt"], properties=global_prop["step24_mdrun_nvt"])

    assert fx.not_empty(global_paths["step24_mdrun_nvt"]["output_trr_path"])
    # assert fx.equal(global_paths["step24_mdrun_nvt"]["output_trr_path"], f'reference/step24_mdrun_nvt/{Path(global_paths["step24_mdrun_nvt"]["output_trr_path"]).name}')
    assert fx.not_empty(global_paths["step24_mdrun_nvt"]["output_gro_path"])
    # assert fx.equal(global_paths["step24_mdrun_nvt"]["output_gro_path"], f'reference/step24_mdrun_nvt/{Path(global_paths["step24_mdrun_nvt"]["output_gro_path"]).name}')
    assert fx.not_empty(global_paths["step24_mdrun_nvt"]["output_edr_path"])
    # assert fx.equal(global_paths["step24_mdrun_nvt"]["output_edr_path"], f'reference/step24_mdrun_nvt/{Path(global_paths["step24_mdrun_nvt"]["output_edr_path"]).name}')
    assert fx.not_empty(global_paths["step24_mdrun_nvt"]["output_log_path"])
    # assert fx.equal(global_paths["step24_mdrun_nvt"]["output_log_path"], f'reference/step24_mdrun_nvt/{Path(global_paths["step24_mdrun_nvt"]["output_log_path"]).name}')


def step25_gmx_energy_nvt(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    gmx_energy(**global_paths["step25_gmx_energy_nvt"], properties=global_prop["step25_gmx_energy_nvt"])

    assert fx.not_empty(global_paths["step25_gmx_energy_nvt"]["output_xvg_path"])
    # assert fx.equal(global_paths["step25_gmx_energy_nvt"]["output_xvg_path"], f'reference/step25_gmx_energy_nvt/{Path(global_paths["step25_gmx_energy_nvt"]["output_xvg_path"]).name}')


def step26_grompp_npt(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    grompp(**global_paths["step26_grompp_npt"], properties=global_prop["step26_grompp_npt"])

    assert fx.not_empty(global_paths["step26_grompp_npt"]["output_tpr_path"])
    # assert fx.equal(global_paths["step26_grompp_npt"]["output_tpr_path"], f'reference/step26_grompp_npt/{Path(global_paths["step26_grompp_npt"]["output_tpr_path"]).name}')


def step27_mdrun_npt(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    mdrun(**global_paths["step27_mdrun_npt"], properties=global_prop["step27_mdrun_npt"])

    assert fx.not_empty(global_paths["step27_mdrun_npt"]["output_trr_path"])
    # assert fx.equal(global_paths["step27_mdrun_npt"]["output_trr_path"], f'reference/step27_mdrun_npt/{Path(global_paths["step27_mdrun_npt"]["output_trr_path"]).name}')
    assert fx.not_empty(global_paths["step27_mdrun_npt"]["output_gro_path"])
    # assert fx.equal(global_paths["step27_mdrun_npt"]["output_gro_path"], f'reference/step27_mdrun_npt/{Path(global_paths["step27_mdrun_npt"]["output_gro_path"]).name}')
    assert fx.not_empty(global_paths["step27_mdrun_npt"]["output_edr_path"])
    # assert fx.equal(global_paths["step27_mdrun_npt"]["output_edr_path"], f'reference/step27_mdrun_npt/{Path(global_paths["step27_mdrun_npt"]["output_edr_path"]).name}')
    assert fx.not_empty(global_paths["step27_mdrun_npt"]["output_log_path"])
    # assert fx.equal(global_paths["step27_mdrun_npt"]["output_log_path"], f'reference/step27_mdrun_npt/{Path(global_paths["step27_mdrun_npt"]["output_log_path"]).name}')


def step28_gmx_energy_npt(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    gmx_energy(**global_paths["step28_gmx_energy_npt"], properties=global_prop["step28_gmx_energy_npt"])

    assert fx.not_empty(global_paths["step28_gmx_energy_npt"]["output_xvg_path"])
    # assert fx.equal(global_paths["step28_gmx_energy_npt"]["output_xvg_path"], f'reference/step28_gmx_energy_npt/{Path(global_paths["step28_gmx_energy_npt"]["output_xvg_path"]).name}')


def step29_grompp_md(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    grompp(**global_paths["step29_grompp_md"], properties=global_prop["step29_grompp_md"])

    assert fx.not_empty(global_paths["step29_grompp_md"]["output_tpr_path"])
    # assert fx.equal(global_paths["step29_grompp_md"]["output_tpr_path"], f'reference/step29_grompp_md/{Path(global_paths["step29_grompp_md"]["output_tpr_path"]).name}')


def step30_mdrun_md(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    mdrun(**global_paths["step30_mdrun_md"], properties=global_prop["step30_mdrun_md"])

    assert fx.not_empty(global_paths["step30_mdrun_md"]["output_trr_path"])
    # assert fx.equal(global_paths["step30_mdrun_md"]["output_trr_path"], f'reference/step30_mdrun_md/{Path(global_paths["step30_mdrun_md"]["output_trr_path"]).name}')
    assert fx.not_empty(global_paths["step30_mdrun_md"]["output_gro_path"])
    # assert fx.equal(global_paths["step30_mdrun_md"]["output_gro_path"], f'reference/step30_mdrun_md/{Path(global_paths["step30_mdrun_md"]["output_gro_path"]).name}')
    assert fx.not_empty(global_paths["step30_mdrun_md"]["output_edr_path"])
    # assert fx.equal(global_paths["step30_mdrun_md"]["output_edr_path"], f'reference/step30_mdrun_md/{Path(global_paths["step30_mdrun_md"]["output_edr_path"]).name}')
    assert fx.not_empty(global_paths["step30_mdrun_md"]["output_log_path"])
    # assert fx.equal(global_paths["step30_mdrun_md"]["output_log_path"], f'reference/step30_mdrun_md/{Path(global_paths["step30_mdrun_md"]["output_log_path"]).name}')


def step34_gmx_image(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    gmx_image(**global_paths["step34_gmx_image"], properties=global_prop["step34_gmx_image"])

    assert fx.not_empty(global_paths["step34_gmx_image"]["output_traj_path"])
    # assert fx.equal(global_paths["step34_gmx_image"]["output_traj_path"], f'reference/step34_gmx_image/{Path(global_paths["step34_gmx_image"]["output_traj_path"]).name}')


def step34b_gmx_image2(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    gmx_image(**global_paths["step34b_gmx_image2"], properties=global_prop["step34b_gmx_image2"])

    assert fx.not_empty(global_paths["step34b_gmx_image2"]["output_traj_path"])
    # assert fx.equal(global_paths["step34b_gmx_image2"]["output_traj_path"], f'reference/step34b_gmx_image2/{Path(global_paths["step34b_gmx_image2"]["output_traj_path"]).name}')


def step35_gmx_trjconv_str(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    gmx_trjconv_str(**global_paths["step35_gmx_trjconv_str"], properties=global_prop["step35_gmx_trjconv_str"])

    assert fx.not_empty(global_paths["step35_gmx_trjconv_str"]["output_str_path"])
    # assert fx.equal(global_paths["step35_gmx_trjconv_str"]["output_str_path"], f'reference/step35_gmx_trjconv_str/{Path(global_paths["step35_gmx_trjconv_str"]["output_str_path"]).name}')


def step31_rmsd_first(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    gmx_rms(**global_paths["step31_rmsd_first"], properties=global_prop["step31_rmsd_first"])

    assert fx.not_empty(global_paths["step31_rmsd_first"]["output_xvg_path"])
    # assert fx.equal(global_paths["step31_rmsd_first"]["output_xvg_path"], f'reference/step31_rmsd_first/{Path(global_paths["step31_rmsd_first"]["output_xvg_path"]).name}')


def step32_rmsd_exp(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    gmx_rms(**global_paths["step32_rmsd_exp"], properties=global_prop["step32_rmsd_exp"])

    assert fx.not_empty(global_paths["step32_rmsd_exp"]["output_xvg_path"])
    # assert fx.equal(global_paths["step32_rmsd_exp"]["output_xvg_path"], f'reference/step32_rmsd_exp/{Path(global_paths["step32_rmsd_exp"]["output_xvg_path"]).name}')


def step33_gmx_rgyr(config, remove=False, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    gmx_rgyr(**global_paths["step33_gmx_rgyr"], properties=global_prop["step33_gmx_rgyr"])

    assert fx.not_empty(global_paths["step33_gmx_rgyr"]["output_xvg_path"])
    # assert fx.equal(global_paths["step33_gmx_rgyr"]["output_xvg_path"], f'reference/step33_gmx_rgyr/{Path(global_paths["step33_gmx_rgyr"]["output_xvg_path"]).name}')

    if remove:
        tmp_files = [conf.get_working_dir_path()]
        tmp_files.extend(glob.glob('sandbox_*'))
        fu.rm_file_list(tmp_files)


@pytest.mark.parametrize("system", [None])
def test_step0_reduce_remove_hydrogens(config_path, system):
    step0_reduce_remove_hydrogens(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step2_extract_molecule(config_path, system):
    step2_extract_molecule(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step00_cat_pdb(config_path, system):
    step00_cat_pdb(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step4_fix_side_chain(config_path, system):
    step4_fix_side_chain(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step5_pdb2gmx(config_path, system):
    step5_pdb2gmx(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step9_make_ndx(config_path, system):
    step9_make_ndx(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step10_genrestr(config_path, system):
    step10_genrestr(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step11_gmx_trjconv_str_protein(config_path, system):
    step11_gmx_trjconv_str_protein(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step12_gmx_trjconv_str_ligand(config_path, system):
    step12_gmx_trjconv_str_ligand(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step13_cat_pdb_hydrogens(config_path, system):
    step13_cat_pdb_hydrogens(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step14_append_ligand(config_path, system):
    step14_append_ligand(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step15_editconf(config_path, system):
    step15_editconf(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step16_solvate(config_path, system):
    step16_solvate(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step17_grompp_genion(config_path, system):
    step17_grompp_genion(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step18_genion(config_path, system):
    step18_genion(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step19_grompp_min(config_path, system):
    step19_grompp_min(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step20_mdrun_min(config_path, system):
    step20_mdrun_min(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step21_gmx_energy_min(config_path, system):
    step21_gmx_energy_min(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step22_make_ndx(config_path, system):
    step22_make_ndx(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step23_grompp_nvt(config_path, system):
    step23_grompp_nvt(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step24_mdrun_nvt(config_path, system):
    step24_mdrun_nvt(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step25_gmx_energy_nvt(config_path, system):
    step25_gmx_energy_nvt(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step26_grompp_npt(config_path, system):
    step26_grompp_npt(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step27_mdrun_npt(config_path, system):
    step27_mdrun_npt(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step28_gmx_energy_npt(config_path, system):
    step28_gmx_energy_npt(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step29_grompp_md(config_path, system):
    step29_grompp_md(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step30_mdrun_md(config_path, system):
    step30_mdrun_md(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step34_gmx_image(config_path, system):
    step34_gmx_image(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step34b_gmx_image2(config_path, system):
    step34b_gmx_image2(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step35_gmx_trjconv_str(config_path, system):
    step35_gmx_trjconv_str(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step31_rmsd_first(config_path, system):
    step31_rmsd_first(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step32_rmsd_exp(config_path, system):
    step32_rmsd_exp(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step33_gmx_rgyr(config_path, remove_flag, system):
    step33_gmx_rgyr(config_path, remove_flag, system)
