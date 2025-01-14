import pytest
import glob
from pathlib import Path
from biobb_common.configuration import settings
from biobb_common.tools import file_utils as fu
from biobb_common.tools import test_fixtures as fx
from biobb_chemistry.ambertools.reduce_remove_hydrogens import reduce_remove_hydrogens
from biobb_structure_utils.utils.extract_molecule import extract_molecule
from biobb_structure_utils.utils.cat_pdb import cat_pdb
from biobb_amber.pdb4amber.pdb4amber_run import pdb4amber_run
from biobb_amber.leap.leap_gen_top import leap_gen_top
from biobb_amber.sander.sander_mdrun import sander_mdrun
from biobb_amber.process.process_minout import process_minout
from biobb_amber.ambpdb.amber_to_pdb import amber_to_pdb
from biobb_amber.leap.leap_solvate import leap_solvate
from biobb_amber.leap.leap_add_ions import leap_add_ions
from biobb_amber.process.process_mdout import process_mdout
from biobb_analysis.ambertools.cpptraj_rms import cpptraj_rms
from biobb_analysis.ambertools.cpptraj_rgyr import cpptraj_rgyr
from biobb_analysis.ambertools.cpptraj_image import cpptraj_image

global_work_dir = None


def step00_reduce_remove_hydrogens(config, system=None):
    conf = settings.ConfReader(config, system)
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    reduce_remove_hydrogens(**global_paths["step00_reduce_remove_hydrogens"], properties=global_prop["step00_reduce_remove_hydrogens"])

    assert fx.not_empty(global_paths["step00_reduce_remove_hydrogens"]["output_path"])
    assert fx.equal(global_paths["step00_reduce_remove_hydrogens"]["output_path"], f'reference/step00_reduce_remove_hydrogens/{Path(global_paths["step00_reduce_remove_hydrogens"]["output_path"]).name}')

    global global_work_dir
    global_work_dir = conf.get_working_dir_path()


def step0_extract_molecule(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    extract_molecule(**global_paths["step0_extract_molecule"], properties=global_prop["step0_extract_molecule"])

    assert fx.not_empty(global_paths["step0_extract_molecule"]["output_molecule_path"])
    assert fx.equal(global_paths["step0_extract_molecule"]["output_molecule_path"], f'reference/step0_extract_molecule/{Path(global_paths["step0_extract_molecule"]["output_molecule_path"]).name}')


def step000_cat_pdb(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    cat_pdb(**global_paths["step000_cat_pdb"], properties=global_prop["step000_cat_pdb"])

    assert fx.not_empty(global_paths["step000_cat_pdb"]["output_structure_path"])
    assert fx.equal(global_paths["step000_cat_pdb"]["output_structure_path"], f'reference/step000_cat_pdb/{Path(global_paths["step000_cat_pdb"]["output_structure_path"]).name}')


def step1_pdb4amber_run(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    pdb4amber_run(**global_paths["step1_pdb4amber_run"], properties=global_prop["step1_pdb4amber_run"])

    assert fx.not_empty(global_paths["step1_pdb4amber_run"]["output_pdb_path"])
    assert fx.equal(global_paths["step1_pdb4amber_run"]["output_pdb_path"], f'reference/step1_pdb4amber_run/{Path(global_paths["step1_pdb4amber_run"]["output_pdb_path"]).name}')


def step2_leap_gen_top(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    leap_gen_top(**global_paths["step2_leap_gen_top"], properties=global_prop["step2_leap_gen_top"])

    assert fx.not_empty(global_paths["step2_leap_gen_top"]["output_pdb_path"])
    assert fx.equal(global_paths["step2_leap_gen_top"]["output_pdb_path"], f'reference/step2_leap_gen_top/{Path(global_paths["step2_leap_gen_top"]["output_pdb_path"]).name}')
    assert fx.not_empty(global_paths["step2_leap_gen_top"]["output_top_path"])
    assert fx.equal(global_paths["step2_leap_gen_top"]["output_top_path"], f'reference/step2_leap_gen_top/{Path(global_paths["step2_leap_gen_top"]["output_top_path"]).name}')
    assert fx.not_empty(global_paths["step2_leap_gen_top"]["output_crd_path"])
    assert fx.equal(global_paths["step2_leap_gen_top"]["output_crd_path"], f'reference/step2_leap_gen_top/{Path(global_paths["step2_leap_gen_top"]["output_crd_path"]).name}')


def step3_sander_mdrun_minH(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    sander_mdrun(**global_paths["step3_sander_mdrun_minH"], properties=global_prop["step3_sander_mdrun_minH"])

    assert fx.not_empty(global_paths["step3_sander_mdrun_minH"]["output_traj_path"])
    assert fx.equal(global_paths["step3_sander_mdrun_minH"]["output_traj_path"], f'reference/step3_sander_mdrun_minH/{Path(global_paths["step3_sander_mdrun_minH"]["output_traj_path"]).name}')
    assert fx.not_empty(global_paths["step3_sander_mdrun_minH"]["output_rst_path"])
    assert fx.equal(global_paths["step3_sander_mdrun_minH"]["output_rst_path"], f'reference/step3_sander_mdrun_minH/{Path(global_paths["step3_sander_mdrun_minH"]["output_rst_path"]).name}')
    assert fx.not_empty(global_paths["step3_sander_mdrun_minH"]["output_log_path"])
    assert fx.equal(global_paths["step3_sander_mdrun_minH"]["output_log_path"], f'reference/step3_sander_mdrun_minH/{Path(global_paths["step3_sander_mdrun_minH"]["output_log_path"]).name}')


def step4_process_minout_minH(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    process_minout(**global_paths["step4_process_minout_minH"], properties=global_prop["step4_process_minout_minH"])

    assert fx.not_empty(global_paths["step4_process_minout_minH"]["output_dat_path"])
    assert fx.equal(global_paths["step4_process_minout_minH"]["output_dat_path"], f'reference/step4_process_minout_minH/{Path(global_paths["step4_process_minout_minH"]["output_dat_path"]).name}')


def step5_sander_mdrun_min(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    sander_mdrun(**global_paths["step5_sander_mdrun_min"], properties=global_prop["step5_sander_mdrun_min"])

    assert fx.not_empty(global_paths["step5_sander_mdrun_min"]["output_traj_path"])
    assert fx.equal(global_paths["step5_sander_mdrun_min"]["output_traj_path"], f'reference/step5_sander_mdrun_min/{Path(global_paths["step5_sander_mdrun_min"]["output_traj_path"]).name}')
    assert fx.not_empty(global_paths["step5_sander_mdrun_min"]["output_rst_path"])
    assert fx.equal(global_paths["step5_sander_mdrun_min"]["output_rst_path"], f'reference/step5_sander_mdrun_min/{Path(global_paths["step5_sander_mdrun_min"]["output_rst_path"]).name}')
    assert fx.not_empty(global_paths["step5_sander_mdrun_min"]["output_log_path"])
    assert fx.equal(global_paths["step5_sander_mdrun_min"]["output_log_path"], f'reference/step5_sander_mdrun_min/{Path(global_paths["step5_sander_mdrun_min"]["output_log_path"]).name}')


def step6_process_minout_min(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    process_minout(**global_paths["step6_process_minout_min"], properties=global_prop["step6_process_minout_min"])

    assert fx.not_empty(global_paths["step6_process_minout_min"]["output_dat_path"])
    assert fx.equal(global_paths["step6_process_minout_min"]["output_dat_path"], f'reference/step6_process_minout_min/{Path(global_paths["step6_process_minout_min"]["output_dat_path"]).name}')


def step7_amber_to_pdb(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    amber_to_pdb(**global_paths["step7_amber_to_pdb"], properties=global_prop["step7_amber_to_pdb"])

    assert fx.not_empty(global_paths["step7_amber_to_pdb"]["output_dat_path"])
    assert fx.equal(global_paths["step7_amber_to_pdb"]["output_dat_path"], f'reference/step7_amber_to_pdb/{Path(global_paths["step7_amber_to_pdb"]["output_dat_path"]).name}')


def step8_leap_solvate(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    leap_solvate(**global_paths["step8_leap_solvate"], properties=global_prop["step8_leap_solvate"])

    assert fx.not_empty(global_paths["step8_leap_solvate"]["output_pdb_path"])
    assert fx.equal(global_paths["step8_leap_solvate"]["output_pdb_path"], f'reference/step8_leap_solvate/{Path(global_paths["step8_leap_solvate"]["output_pdb_path"]).name}')
    assert fx.not_empty(global_paths["step8_leap_solvate"]["output_top_path"])
    assert fx.equal(global_paths["step8_leap_solvate"]["output_top_path"], f'reference/step8_leap_solvate/{Path(global_paths["step8_leap_solvate"]["output_top_path"]).name}')
    assert fx.not_empty(global_paths["step8_leap_solvate"]["output_crd_path"])
    assert fx.equal(global_paths["step8_leap_solvate"]["output_crd_path"], f'reference/step8_leap_solvate/{Path(global_paths["step8_leap_solvate"]["output_crd_path"]).name}')


def step9_leap_add_ions(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    leap_add_ions(**global_paths["step9_leap_add_ions"], properties=global_prop["step9_leap_add_ions"])

    assert fx.not_empty(global_paths["step9_leap_add_ions"]["output_pdb_path"])
    assert fx.equal(global_paths["step9_leap_add_ions"]["output_pdb_path"], f'reference/step9_leap_add_ions/{Path(global_paths["step9_leap_add_ions"]["output_pdb_path"]).name}')
    assert fx.not_empty(global_paths["step9_leap_add_ions"]["output_top_path"])
    assert fx.equal(global_paths["step9_leap_add_ions"]["output_top_path"], f'reference/step9_leap_add_ions/{Path(global_paths["step9_leap_add_ions"]["output_top_path"]).name}')
    assert fx.not_empty(global_paths["step9_leap_add_ions"]["output_crd_path"])
    assert fx.equal(global_paths["step9_leap_add_ions"]["output_crd_path"], f'reference/step9_leap_add_ions/{Path(global_paths["step9_leap_add_ions"]["output_crd_path"]).name}')


def step10_sander_mdrun_energy(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    sander_mdrun(**global_paths["step10_sander_mdrun_energy"], properties=global_prop["step10_sander_mdrun_energy"])

    assert fx.not_empty(global_paths["step10_sander_mdrun_energy"]["output_traj_path"])
    assert fx.equal(global_paths["step10_sander_mdrun_energy"]["output_traj_path"], f'reference/step10_sander_mdrun_energy/{Path(global_paths["step10_sander_mdrun_energy"]["output_traj_path"]).name}')
    assert fx.not_empty(global_paths["step10_sander_mdrun_energy"]["output_rst_path"])
    assert fx.equal(global_paths["step10_sander_mdrun_energy"]["output_rst_path"], f'reference/step10_sander_mdrun_energy/{Path(global_paths["step10_sander_mdrun_energy"]["output_rst_path"]).name}')
    assert fx.not_empty(global_paths["step10_sander_mdrun_energy"]["output_log_path"])
    assert fx.equal(global_paths["step10_sander_mdrun_energy"]["output_log_path"], f'reference/step10_sander_mdrun_energy/{Path(global_paths["step10_sander_mdrun_energy"]["output_log_path"]).name}')


def step11_process_minout_energy(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    process_minout(**global_paths["step11_process_minout_energy"], properties=global_prop["step11_process_minout_energy"])

    assert fx.not_empty(global_paths["step11_process_minout_energy"]["output_dat_path"])
    assert fx.equal(global_paths["step11_process_minout_energy"]["output_dat_path"], f'reference/step11_process_minout_energy/{Path(global_paths["step11_process_minout_energy"]["output_dat_path"]).name}')


def step12_sander_mdrun_warm(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    sander_mdrun(**global_paths["step12_sander_mdrun_warm"], properties=global_prop["step12_sander_mdrun_warm"])

    assert fx.not_empty(global_paths["step12_sander_mdrun_warm"]["output_traj_path"])
    assert fx.equal(global_paths["step12_sander_mdrun_warm"]["output_traj_path"], f'reference/step12_sander_mdrun_warm/{Path(global_paths["step12_sander_mdrun_warm"]["output_traj_path"]).name}')
    assert fx.not_empty(global_paths["step12_sander_mdrun_warm"]["output_rst_path"])
    assert fx.equal(global_paths["step12_sander_mdrun_warm"]["output_rst_path"], f'reference/step12_sander_mdrun_warm/{Path(global_paths["step12_sander_mdrun_warm"]["output_rst_path"]).name}')
    assert fx.not_empty(global_paths["step12_sander_mdrun_warm"]["output_log_path"])
    assert fx.equal(global_paths["step12_sander_mdrun_warm"]["output_log_path"], f'reference/step12_sander_mdrun_warm/{Path(global_paths["step12_sander_mdrun_warm"]["output_log_path"]).name}')


def step13_process_mdout_warm(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    process_mdout(**global_paths["step13_process_mdout_warm"], properties=global_prop["step13_process_mdout_warm"])

    assert fx.not_empty(global_paths["step13_process_mdout_warm"]["output_dat_path"])
    assert fx.equal(global_paths["step13_process_mdout_warm"]["output_dat_path"], f'reference/step13_process_mdout_warm/{Path(global_paths["step13_process_mdout_warm"]["output_dat_path"]).name}')


def step14_sander_mdrun_nvt(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    sander_mdrun(**global_paths["step14_sander_mdrun_nvt"], properties=global_prop["step14_sander_mdrun_nvt"])

    assert fx.not_empty(global_paths["step14_sander_mdrun_nvt"]["output_traj_path"])
    assert fx.equal(global_paths["step14_sander_mdrun_nvt"]["output_traj_path"], f'reference/step14_sander_mdrun_nvt/{Path(global_paths["step14_sander_mdrun_nvt"]["output_traj_path"]).name}')
    assert fx.not_empty(global_paths["step14_sander_mdrun_nvt"]["output_rst_path"])
    assert fx.equal(global_paths["step14_sander_mdrun_nvt"]["output_rst_path"], f'reference/step14_sander_mdrun_nvt/{Path(global_paths["step14_sander_mdrun_nvt"]["output_rst_path"]).name}')
    assert fx.not_empty(global_paths["step14_sander_mdrun_nvt"]["output_log_path"])
    assert fx.equal(global_paths["step14_sander_mdrun_nvt"]["output_log_path"], f'reference/step14_sander_mdrun_nvt/{Path(global_paths["step14_sander_mdrun_nvt"]["output_log_path"]).name}')


def step15_process_mdout_nvt(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    process_mdout(**global_paths["step15_process_mdout_nvt"], properties=global_prop["step15_process_mdout_nvt"])

    assert fx.not_empty(global_paths["step15_process_mdout_nvt"]["output_dat_path"])
    assert fx.equal(global_paths["step15_process_mdout_nvt"]["output_dat_path"], f'reference/step15_process_mdout_nvt/{Path(global_paths["step15_process_mdout_nvt"]["output_dat_path"]).name}')


def step16_sander_mdrun_npt(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    sander_mdrun(**global_paths["step16_sander_mdrun_npt"], properties=global_prop["step16_sander_mdrun_npt"])

    assert fx.not_empty(global_paths["step16_sander_mdrun_npt"]["output_traj_path"])
    assert fx.equal(global_paths["step16_sander_mdrun_npt"]["output_traj_path"], f'reference/step16_sander_mdrun_npt/{Path(global_paths["step16_sander_mdrun_npt"]["output_traj_path"]).name}')
    assert fx.not_empty(global_paths["step16_sander_mdrun_npt"]["output_rst_path"])
    assert fx.equal(global_paths["step16_sander_mdrun_npt"]["output_rst_path"], f'reference/step16_sander_mdrun_npt/{Path(global_paths["step16_sander_mdrun_npt"]["output_rst_path"]).name}')
    assert fx.not_empty(global_paths["step16_sander_mdrun_npt"]["output_log_path"])
    assert fx.equal(global_paths["step16_sander_mdrun_npt"]["output_log_path"], f'reference/step16_sander_mdrun_npt/{Path(global_paths["step16_sander_mdrun_npt"]["output_log_path"]).name}')


def step17_process_mdout_npt(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    process_mdout(**global_paths["step17_process_mdout_npt"], properties=global_prop["step17_process_mdout_npt"])

    assert fx.not_empty(global_paths["step17_process_mdout_npt"]["output_dat_path"])
    assert fx.equal(global_paths["step17_process_mdout_npt"]["output_dat_path"], f'reference/step17_process_mdout_npt/{Path(global_paths["step17_process_mdout_npt"]["output_dat_path"]).name}')


def step18_sander_mdrun_md(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    sander_mdrun(**global_paths["step18_sander_mdrun_md"], properties=global_prop["step18_sander_mdrun_md"])

    assert fx.not_empty(global_paths["step18_sander_mdrun_md"]["output_traj_path"])
    assert fx.equal(global_paths["step18_sander_mdrun_md"]["output_traj_path"], f'reference/step18_sander_mdrun_md/{Path(global_paths["step18_sander_mdrun_md"]["output_traj_path"]).name}')
    assert fx.not_empty(global_paths["step18_sander_mdrun_md"]["output_rst_path"])
    assert fx.equal(global_paths["step18_sander_mdrun_md"]["output_rst_path"], f'reference/step18_sander_mdrun_md/{Path(global_paths["step18_sander_mdrun_md"]["output_rst_path"]).name}')
    assert fx.not_empty(global_paths["step18_sander_mdrun_md"]["output_log_path"])
    assert fx.equal(global_paths["step18_sander_mdrun_md"]["output_log_path"], f'reference/step18_sander_mdrun_md/{Path(global_paths["step18_sander_mdrun_md"]["output_log_path"]).name}')


def step19_rmsd_first(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    cpptraj_rms(**global_paths["step19_rmsd_first"], properties=global_prop["step19_rmsd_first"])

    assert fx.not_empty(global_paths["step19_rmsd_first"]["output_cpptraj_path"])
    assert fx.equal(global_paths["step19_rmsd_first"]["output_cpptraj_path"], f'reference/step19_rmsd_first/{Path(global_paths["step19_rmsd_first"]["output_cpptraj_path"]).name}')


def step20_rmsd_exp(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    cpptraj_rms(**global_paths["step20_rmsd_exp"], properties=global_prop["step20_rmsd_exp"])

    assert fx.not_empty(global_paths["step20_rmsd_exp"]["output_cpptraj_path"])
    assert fx.equal(global_paths["step20_rmsd_exp"]["output_cpptraj_path"], f'reference/step20_rmsd_exp/{Path(global_paths["step20_rmsd_exp"]["output_cpptraj_path"]).name}')


def step21_cpptraj_rgyr(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    cpptraj_rgyr(**global_paths["step21_cpptraj_rgyr"], properties=global_prop["step21_cpptraj_rgyr"])

    assert fx.not_empty(global_paths["step21_cpptraj_rgyr"]["output_cpptraj_path"])
    assert fx.equal(global_paths["step21_cpptraj_rgyr"]["output_cpptraj_path"], f'reference/step21_cpptraj_rgyr/{Path(global_paths["step21_cpptraj_rgyr"]["output_cpptraj_path"]).name}')


def step22_cpptraj_image(config, remove=False, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    cpptraj_image(**global_paths["step22_cpptraj_image"], properties=global_prop["step22_cpptraj_image"])

    assert fx.not_empty(global_paths["step22_cpptraj_image"]["output_cpptraj_path"])
    assert fx.equal(global_paths["step22_cpptraj_image"]["output_cpptraj_path"], f'reference/step22_cpptraj_image/{Path(global_paths["step22_cpptraj_image"]["output_cpptraj_path"]).name}')

    if remove:
        tmp_files = [conf.get_working_dir_path()]
        tmp_files.extend(glob.glob('sandbox_*'))
        fu.rm_file_list(tmp_files)


@pytest.mark.parametrize("system", [None])
def test_step00_reduce_remove_hydrogens(config_path, system):
    step00_reduce_remove_hydrogens(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step0_extract_molecule(config_path, system):
    step0_extract_molecule(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step000_cat_pdb(config_path, system):
    step000_cat_pdb(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step1_pdb4amber_run(config_path, system):
    step1_pdb4amber_run(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step2_leap_gen_top(config_path, system):
    step2_leap_gen_top(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step3_sander_mdrun_minH(config_path, system):
    step3_sander_mdrun_minH(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step4_process_minout_minH(config_path, system):
    step4_process_minout_minH(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step5_sander_mdrun_min(config_path, system):
    step5_sander_mdrun_min(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step6_process_minout_min(config_path, system):
    step6_process_minout_min(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step7_amber_to_pdb(config_path, system):
    step7_amber_to_pdb(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step8_leap_solvate(config_path, system):
    step8_leap_solvate(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step9_leap_add_ions(config_path, system):
    step9_leap_add_ions(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step10_sander_mdrun_energy(config_path, system):
    step10_sander_mdrun_energy(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step11_process_minout_energy(config_path, system):
    step11_process_minout_energy(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step12_sander_mdrun_warm(config_path, system):
    step12_sander_mdrun_warm(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step13_process_mdout_warm(config_path, system):
    step13_process_mdout_warm(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step14_sander_mdrun_nvt(config_path, system):
    step14_sander_mdrun_nvt(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step15_process_mdout_nvt(config_path, system):
    step15_process_mdout_nvt(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step16_sander_mdrun_npt(config_path, system):
    step16_sander_mdrun_npt(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step17_process_mdout_npt(config_path, system):
    step17_process_mdout_npt(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step18_sander_mdrun_md(config_path, system):
    step18_sander_mdrun_md(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step19_rmsd_first(config_path, system):
    step19_rmsd_first(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step20_rmsd_exp(config_path, system):
    step20_rmsd_exp(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step21_cpptraj_rgyr(config_path, system):
    step21_cpptraj_rgyr(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step22_cpptraj_image(config_path, remove_flag, system):
    step22_cpptraj_image(config_path, remove_flag, system)
