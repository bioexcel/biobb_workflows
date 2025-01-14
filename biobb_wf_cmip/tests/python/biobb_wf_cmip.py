import pytest
import glob
from pathlib import Path
from biobb_common.configuration import settings
from biobb_common.tools import file_utils as fu
from biobb_common.tools import test_fixtures as fx
from biobb_cmip.cmip.cmip_prepare_pdb import cmip_prepare_pdb
from biobb_cmip.cmip.cmip_titration import cmip_titration
from biobb_structure_utils.utils.cat_pdb import cat_pdb
from biobb_cmip.cmip.cmip_run import cmip_run
from biobb_structure_utils.utils.remove_pdb_water import remove_pdb_water
from biobb_structure_utils.utils.extract_heteroatoms import extract_heteroatoms
from biobb_chemistry.ambertools.reduce_add_hydrogens import reduce_add_hydrogens
from biobb_chemistry.acpype.acpype_params_ac import acpype_params_ac
from biobb_amber.leap.leap_gen_top import leap_gen_top
from biobb_amber.sander.sander_mdrun import sander_mdrun
from biobb_amber.ambpdb.amber_to_pdb import amber_to_pdb
from biobb_cmip.cmip.cmip_prepare_structure import cmip_prepare_structure
from biobb_structure_utils.utils.remove_ligand import remove_ligand
from biobb_cmip.cmip.cmip_ignore_residues import cmip_ignore_residues
from biobb_structure_utils.utils.extract_chain import extract_chain

global_work_dir = None


def step0_cmip_prepare_pdb(config, system=None):
    conf = settings.ConfReader(config, system)
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    cmip_prepare_pdb(**global_paths["step0_cmip_prepare_pdb"], properties=global_prop["step0_cmip_prepare_pdb"])

    assert fx.not_empty(global_paths["step0_cmip_prepare_pdb"]["output_cmip_pdb_path"])
    assert fx.equal(global_paths["step0_cmip_prepare_pdb"]["output_cmip_pdb_path"], f'reference/step0_cmip_prepare_pdb/{Path(global_paths["step0_cmip_prepare_pdb"]["output_cmip_pdb_path"]).name}')

    global global_work_dir
    global_work_dir = conf.get_working_dir_path()


def step1_cmip_titration(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    cmip_titration(**global_paths["step1_cmip_titration"], properties=global_prop["output_pdb_path"])

    assert fx.not_empty(global_paths["step1_cmip_titration"]["output_pdb_path"])
    assert fx.equal(global_paths["step1_cmip_titration"]["output_pdb_path"], f'reference/step1_cmip_titration/{Path(global_paths["step1_cmip_titration"]["output_pdb_path"]).name}')


def step2_cat_pdb(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    cat_pdb(**global_paths["step2_cat_pdb"], properties=global_prop["step2_cat_pdb"])

    assert fx.not_empty(global_paths["step2_cat_pdb"]["output_structure_path"])
    assert fx.equal(global_paths["step2_cat_pdb"]["output_structure_path"], f'reference/step2_cat_pdb/{Path(global_paths["step2_cat_pdb"]["output_structure_path"]).name}')


def step3_cmip_run_pos(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    cmip_run(**global_paths["step3_cmip_run_pos"], properties=global_prop["step3_cmip_run_pos"])

    assert fx.not_empty(global_paths["step3_cmip_run_pos"]["output_cube_path"])
    assert fx.equal(global_paths["step3_cmip_run_pos"]["output_cube_path"], f'reference/step3_cmip_run_pos/{Path(global_paths["step3_cmip_run_pos"]["output_cube_path"]).name}')


def step4_cmip_run_neg(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    cmip_run(**global_paths["step4_cmip_run_neg"], properties=global_prop["step4_cmip_run_neg"])

    assert fx.not_empty(global_paths["step4_cmip_run_neg"]["output_cube_path"])
    assert fx.equal(global_paths["step4_cmip_run_neg"]["output_cube_path"], f'reference/step4_cmip_run_neg/{Path(global_paths["step4_cmip_run_neg"]["output_cube_path"]).name}')


def step5_cmip_run_neu(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    cmip_run(**global_paths["step5_cmip_run_neu"], properties=global_prop["step5_cmip_run_neu"])

    assert fx.not_empty(global_paths["step5_cmip_run_neu"]["output_cube_path"])
    assert fx.equal(global_paths["step5_cmip_run_neu"]["output_cube_path"], f'reference/step5_cmip_run_neu/{Path(global_paths["step5_cmip_run_neu"]["output_cube_path"]).name}')


def step6_remove_pdb_water(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    remove_pdb_water(**global_paths["step6_remove_pdb_water"], properties=global_prop["step6_remove_pdb_water"])

    assert fx.not_empty(global_paths["step6_remove_pdb_water"]["output_pdb_path"])
    assert fx.equal(global_paths["step6_remove_pdb_water"]["output_pdb_path"], f'reference/step6_remove_pdb_water/{Path(global_paths["step6_remove_pdb_water"]["output_pdb_path"]).name}')


def step7_extract_heteroatoms(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    extract_heteroatoms(**global_paths["step7_extract_heteroatoms"], properties=global_prop["step7_extract_heteroatoms"])

    assert fx.not_empty(global_paths["step7_extract_heteroatoms"]["output_heteroatom_path"])
    assert fx.equal(global_paths["step7_extract_heteroatoms"]["output_heteroatom_path"], f'reference/step7_extract_heteroatoms/{Path(global_paths["step7_extract_heteroatoms"]["output_heteroatom_path"]).name}')


def step8_reduce_add_hydrogens(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    reduce_add_hydrogens(**global_paths["step8_reduce_add_hydrogens"], properties=global_prop["step8_reduce_add_hydrogens"])

    assert fx.not_empty(global_paths["step8_reduce_add_hydrogens"]["output_path"])
    assert fx.equal(global_paths["step8_reduce_add_hydrogens"]["output_path"], f'reference/step8_reduce_add_hydrogens/{Path(global_paths["step8_reduce_add_hydrogens"]["output_path"]).name}')


def step9_acpype_params_ac(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    acpype_params_ac(**global_paths["step9_acpype_params_ac"], properties=global_prop["step9_acpype_params_ac"])

    assert fx.not_empty(global_paths["step9_acpype_params_ac"]["output_path_inpcrd"])
    assert fx.equal(global_paths["step9_acpype_params_ac"]["output_path_inpcrd"], f'reference/step9_acpype_params_ac/{Path(global_paths["step9_acpype_params_ac"]["output_path_inpcrd"]).name}')
    assert fx.not_empty(global_paths["step9_acpype_params_ac"]["output_path_frcmod"])
    assert fx.equal(global_paths["step9_acpype_params_ac"]["output_path_frcmod"], f'reference/step9_acpype_params_ac/{Path(global_paths["step9_acpype_params_ac"]["output_path_frcmod"]).name}')
    assert fx.not_empty(global_paths["step9_acpype_params_ac"]["output_path_lib"])
    assert fx.equal(global_paths["step9_acpype_params_ac"]["output_path_lib"], f'reference/step9_acpype_params_ac/{Path(global_paths["step9_acpype_params_ac"]["output_path_lib"]).name}')
    assert fx.not_empty(global_paths["step9_acpype_params_ac"]["output_path_prmtop"])
    assert fx.equal(global_paths["step9_acpype_params_ac"]["output_path_prmtop"], f'reference/step9_acpype_params_ac/{Path(global_paths["step9_acpype_params_ac"]["output_path_prmtop"]).name}')


def step10_leap_gen_top(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    leap_gen_top(**global_paths["step10_leap_gen_top"], properties=global_prop["step10_leap_gen_top"])

    assert fx.not_empty(global_paths["step10_leap_gen_top"]["output_pdb_path"])
    assert fx.equal(global_paths["step10_leap_gen_top"]["output_pdb_path"], f'reference/step10_leap_gen_top/{Path(global_paths["step10_leap_gen_top"]["output_pdb_path"]).name}')
    assert fx.not_empty(global_paths["step10_leap_gen_top"]["output_top_path"])
    assert fx.equal(global_paths["step10_leap_gen_top"]["output_top_path"], f'reference/step10_leap_gen_top/{Path(global_paths["step10_leap_gen_top"]["output_top_path"]).name}')
    assert fx.not_empty(global_paths["step10_leap_gen_top"]["output_crd_path"])
    assert fx.equal(global_paths["step10_leap_gen_top"]["output_crd_path"], f'reference/step10_leap_gen_top/{Path(global_paths["step10_leap_gen_top"]["output_crd_path"]).name}')


def step11_sander_mdrun(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    sander_mdrun(**global_paths["step11_sander_mdrun"], properties=global_prop["step11_sander_mdrun"])

    assert fx.not_empty(global_paths["step11_sander_mdrun"]["output_traj_path"])
    assert fx.equal(global_paths["step11_sander_mdrun"]["output_traj_path"], f'reference/step11_sander_mdrun/{Path(global_paths["step11_sander_mdrun"]["output_traj_path"]).name}')
    assert fx.not_empty(global_paths["step11_sander_mdrun"]["output_rst_path"])
    assert fx.equal(global_paths["step11_sander_mdrun"]["output_rst_path"], f'reference/step11_sander_mdrun/{Path(global_paths["step11_sander_mdrun"]["output_rst_path"]).name}')
    assert fx.not_empty(global_paths["step11_sander_mdrun"]["output_log_path"])
    assert fx.equal(global_paths["step11_sander_mdrun"]["output_log_path"], f'reference/step11_sander_mdrun/{Path(global_paths["step11_sander_mdrun"]["output_log_path"]).name}')


def step12_amber_to_pdb(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    amber_to_pdb(**global_paths["step12_amber_to_pdb"], properties=global_prop["step12_amber_to_pdb"])

    assert fx.not_empty(global_paths["step12_amber_to_pdb"]["output_dat_path"])
    assert fx.equal(global_paths["step12_amber_to_pdb"]["output_dat_path"], f'reference/step12_amber_to_pdb/{Path(global_paths["step12_amber_to_pdb"]["output_dat_path"]).name}')


def step13_cmip_prepare_structure(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    cmip_prepare_structure(**global_paths["step13_cmip_prepare_structure"], properties=global_prop["step13_cmip_prepare_structure"])

    assert fx.not_empty(global_paths["step13_cmip_prepare_structure"]["output_cmip_pdb_path"])
    assert fx.equal(global_paths["step13_cmip_prepare_structure"]["output_cmip_pdb_path"], f'reference/step13_cmip_prepare_structure/{Path(global_paths["step13_cmip_prepare_structure"]["output_cmip_pdb_path"]).name}')


def step14_remove_ligand(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    remove_ligand(**global_paths["step14_remove_ligand"], properties=global_prop["step14_remove_ligand"])

    assert fx.not_empty(global_paths["step14_remove_ligand"]["output_structure_path"])
    assert fx.equal(global_paths["step14_remove_ligand"]["output_structure_path"], f'reference/step14_remove_ligand/{Path(global_paths["step14_remove_ligand"]["output_structure_path"]).name}')


def step15_cmip_ignore_residues(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    cmip_ignore_residues(**global_paths["step15_cmip_ignore_residues"], properties=global_prop["step15_cmip_ignore_residues"])

    assert fx.not_empty(global_paths["step15_cmip_ignore_residues"]["output_cmip_pdb_path"])
    assert fx.equal(global_paths["step15_cmip_ignore_residues"]["output_cmip_pdb_path"], f'reference/step15_cmip_ignore_residues/{Path(global_paths["step15_cmip_ignore_residues"]["output_cmip_pdb_path"]).name}')


def step16_cmip_run_int_en(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    cmip_run(**global_paths["step16_cmip_run_int_en"], properties=global_prop["step16_cmip_run_int_en"])

    assert fx.not_empty(global_paths["step16_cmip_run_int_en"]["output_log_path"])
    assert fx.equal(global_paths["step16_cmip_run_int_en"]["output_log_path"], f'reference/step16_cmip_run_int_en/{Path(global_paths["step16_cmip_run_int_en"]["output_log_path"]).name}')
    assert fx.not_empty(global_paths["step16_cmip_run_int_en"]["output_byat_path"])
    assert fx.equal(global_paths["step16_cmip_run_int_en"]["output_byat_path"], f'reference/step16_cmip_run_int_en/{Path(global_paths["step16_cmip_run_int_en"]["output_byat_path"]).name}')


def step17_cmip_prepare_structure(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    cmip_prepare_structure(**global_paths["step17_cmip_prepare_structure"], properties=global_prop["step17_cmip_prepare_structure"])

    assert fx.not_empty(global_paths["step17_cmip_prepare_structure"]["output_cmip_pdb_path"])
    assert fx.equal(global_paths["step17_cmip_prepare_structure"]["output_cmip_pdb_path"], f'reference/step17_cmip_prepare_structure/{Path(global_paths["step17_cmip_prepare_structure"]["output_cmip_pdb_path"]).name}')


def step18_extract_chain_a(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    extract_chain(**global_paths["step18_extract_chain_a"], properties=global_prop["step18_extract_chain_a"])

    assert fx.not_empty(global_paths["step18_extract_chain_a"]["output_structure_path"])
    assert fx.equal(global_paths["step18_extract_chain_a"]["output_structure_path"], f'reference/step18_extract_chain_a/{Path(global_paths["step18_extract_chain_a"]["output_structure_path"]).name}')


def step19_extract_chain_b(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    extract_chain(**global_paths["step19_extract_chain_b"], properties=global_prop["step19_extract_chain_b"])

    assert fx.not_empty(global_paths["step19_extract_chain_b"]["output_structure_path"])
    assert fx.equal(global_paths["step19_extract_chain_b"]["output_structure_path"], f'reference/step19_extract_chain_b/{Path(global_paths["step19_extract_chain_b"]["output_structure_path"]).name}')


def step20_cmip_run_rbd(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    cmip_run(**global_paths["step20_cmip_run_rbd"], properties=global_prop["step20_cmip_run_rbd"])

    assert fx.not_empty(global_paths["step20_cmip_run_rbd"]["output_json_box_path"])
    assert fx.equal(global_paths["step20_cmip_run_rbd"]["output_json_box_path"], f'reference/step20_cmip_run_rbd/{Path(global_paths["step20_cmip_run_rbd"]["output_json_box_path"]).name}')


def step21_cmip_run_hace2(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    cmip_run(**global_paths["step21_cmip_run_hace2"], properties=global_prop["step21_cmip_run_hace2"])

    assert fx.not_empty(global_paths["step21_cmip_run_hace2"]["output_json_box_path"])
    assert fx.equal(global_paths["step21_cmip_run_hace2"]["output_json_box_path"], f'reference/step21_cmip_run_hace2/{Path(global_paths["step21_cmip_run_hace2"]["output_json_box_path"]).name}')


def step22_cmip_run_rbd_hace2(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    cmip_run(**global_paths["step22_cmip_run_rbd_hace2"], properties=global_prop["step22_cmip_run_rbd_hace2"])

    assert fx.not_empty(global_paths["step22_cmip_run_rbd_hace2"]["output_json_box_path"])
    assert fx.equal(global_paths["step22_cmip_run_rbd_hace2"]["output_json_box_path"], f'reference/step22_cmip_run_rbd_hace2/{Path(global_paths["step22_cmip_run_rbd_hace2"]["output_json_box_path"]).name}')


def step23_cmip_ignore_residues_rbd(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    cmip_run(**global_paths["step23_cmip_ignore_residues_rbd"], properties=global_prop["step23_cmip_ignore_residues_rbd"])

    assert fx.not_empty(global_paths["step23_cmip_ignore_residues_rbd"]["output_cmip_pdb_path"])
    assert fx.equal(global_paths["step23_cmip_ignore_residues_rbd"]["output_cmip_pdb_path"], f'reference/step23_cmip_ignore_residues_rbd/{Path(global_paths["step23_cmip_ignore_residues_rbd"]["output_cmip_pdb_path"]).name}')


def step24_cmip_run_prot_prot(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    cmip_run(**global_paths["step24_cmip_run_prot_prot"], properties=global_prop["step24_cmip_run_prot_prot"])

    assert fx.not_empty(global_paths["step24_cmip_run_prot_prot"]["output_log_path"])
    assert fx.equal(global_paths["step24_cmip_run_prot_prot"]["output_log_path"], f'reference/step24_cmip_run_prot_prot/{Path(global_paths["step24_cmip_run_prot_prot"]["output_log_path"]).name}')
    assert fx.not_empty(global_paths["step24_cmip_run_prot_prot"]["output_json_box_path"])
    assert fx.equal(global_paths["step24_cmip_run_prot_prot"]["output_json_box_path"], f'reference/step24_cmip_run_prot_prot/{Path(global_paths["step24_cmip_run_prot_prot"]["output_json_box_path"]).name}')
    assert fx.not_empty(global_paths["step24_cmip_run_prot_prot"]["output_json_external_box_path"])
    assert fx.equal(global_paths["step24_cmip_run_prot_prot"]["output_json_external_box_path"], f'reference/step24_cmip_run_prot_prot/{Path(global_paths["step24_cmip_run_prot_prot"]["output_json_external_box_path"]).name}')
    assert fx.not_empty(global_paths["step24_cmip_run_prot_prot"]["output_byat_path"])
    assert fx.equal(global_paths["step24_cmip_run_prot_prot"]["output_byat_path"], f'reference/step24_cmip_run_prot_prot/{Path(global_paths["step24_cmip_run_prot_prot"]["output_byat_path"]).name}')


def step25_cmip_ignore_residues_hace2(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    cmip_run(**global_paths["step25_cmip_ignore_residues_hace2"], properties=global_prop["step25_cmip_ignore_residues_hace2"])

    assert fx.not_empty(global_paths["step25_cmip_ignore_residues_hace2"]["output_cmip_pdb_path"])
    assert fx.equal(global_paths["step25_cmip_ignore_residues_hace2"]["output_cmip_pdb_path"], f'reference/step25_cmip_ignore_residues_hace2/{Path(global_paths["step25_cmip_ignore_residues_hace2"]["output_cmip_pdb_path"]).name}')


def step26_cmip_run_complex(config, remove=False, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    cmip_run(**global_paths["step26_cmip_run_complex"], properties=global_prop["step26_cmip_run_complex"])

    assert fx.not_empty(global_paths["step26_cmip_run_complex"]["output_log_path"])
    assert fx.equal(global_paths["step26_cmip_run_complex"]["output_log_path"], f'reference/step26_cmip_run_complex/{Path(global_paths["step26_cmip_run_complex"]["output_log_path"]).name}')
    assert fx.not_empty(global_paths["step26_cmip_run_complex"]["output_json_box_path"])
    assert fx.equal(global_paths["step26_cmip_run_complex"]["output_json_box_path"], f'reference/step26_cmip_run_complex/{Path(global_paths["step26_cmip_run_complex"]["output_json_box_path"]).name}')
    assert fx.not_empty(global_paths["step26_cmip_run_complex"]["output_json_external_box_path"])
    assert fx.equal(global_paths["step26_cmip_run_complex"]["output_json_external_box_path"], f'reference/step26_cmip_run_complex/{Path(global_paths["step26_cmip_run_complex"]["output_json_external_box_path"]).name}')
    assert fx.not_empty(global_paths["step26_cmip_run_complex"]["output_byat_path"])
    assert fx.equal(global_paths["step26_cmip_run_complex"]["output_byat_path"], f'reference/step26_cmip_run_complex/{Path(global_paths["step26_cmip_run_complex"]["output_byat_path"]).name}')

    if remove:
        tmp_files = [conf.get_working_dir_path()]
        tmp_files.extend(glob.glob('sandbox_*'))
        fu.rm_file_list(tmp_files)


@pytest.mark.parametrize("system", [None])
def test_step0_cmip_prepare_pdb(config_path, system):
    step0_cmip_prepare_pdb(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step1_cmip_titration(config_path, system):
    step1_cmip_titration(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step2_cat_pdb(config_path, system):
    step2_cat_pdb(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step3_cmip_run_pos(config_path, system):
    step3_cmip_run_pos(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step4_cmip_run_neg(config_path, system):
    step4_cmip_run_neg(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step5_cmip_run_neu(config_path, system):
    step5_cmip_run_neu(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step6_remove_pdb_water(config_path, system):
    step6_remove_pdb_water(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step7_extract_heteroatoms(config_path, system):
    step7_extract_heteroatoms(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step8_reduce_add_hydrogens(config_path, system):
    step8_reduce_add_hydrogens(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step9_acpype_params_ac(config_path, system):
    step9_acpype_params_ac(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step10_leap_gen_top(config_path, system):
    step10_leap_gen_top(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step11_sander_mdrun(config_path, system):
    step11_sander_mdrun(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step12_amber_to_pdb(config_path, system):
    step12_amber_to_pdb(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step13_cmip_prepare_structure(config_path, system):
    step13_cmip_prepare_structure(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step14_remove_ligand(config_path, system):
    step14_remove_ligand(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step15_cmip_ignore_residues(config_path, system):
    step15_cmip_ignore_residues(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step16_cmip_run_int_en(config_path, system):
    step16_cmip_run_int_en(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step17_cmip_prepare_structure(config_path, system):
    step17_cmip_prepare_structure(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step18_extract_chain_a(config_path, system):
    step18_extract_chain_a(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step19_extract_chain_b(config_path, system):
    step19_extract_chain_b(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step20_cmip_run_rbd(config_path, system):
    step20_cmip_run_rbd(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step21_cmip_run_hace2(config_path, system):
    step21_cmip_run_hace2(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step22_cmip_run_rbd_hace2(config_path, system):
    step22_cmip_run_rbd_hace2(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step23_cmip_ignore_residues_rbd(config_path, system):
    step23_cmip_ignore_residues_rbd(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step24_cmip_run_prot_prot(config_path, system):
    step24_cmip_run_prot_prot(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step25_cmip_ignore_residues_hace2(config_path, system):
    step25_cmip_ignore_residues_hace2(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step26_cmip_run_complex(config_path, remove_flag, system):
    step26_cmip_run_complex(config_path, remove_flag, system)
