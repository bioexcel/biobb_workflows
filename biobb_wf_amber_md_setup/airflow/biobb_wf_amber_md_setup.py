from airflow import DAG
from airflow.providers.standard.operators.bash import BashOperator
from datetime import datetime
from airflow.models.baseoperator import cross_downstream
from airflow_cwl_utils import create_bash_command

WF_NAME = "biobb_wf_amber_md_setup"

with DAG(WF_NAME, start_date=datetime(2026, 1, 1), schedule=None) as dag:

    step00_reduce_remove_hydrogens = BashOperator(
        task_id="step00_reduce_remove_hydrogens",
        bash_command=create_bash_command(WF_NAME, "step00_reduce_remove_hydrogens", "reduce_remove_hydrogens")
    )

    step0_extract_molecule = BashOperator(
        task_id="step0_extract_molecule",
        bash_command=create_bash_command(WF_NAME, "step0_extract_molecule", "extract_molecule")
    )

    step000_cat_pdb = BashOperator(
        task_id="step000_cat_pdb",
        bash_command=create_bash_command(WF_NAME, "step000_cat_pdb", "cat_pdb")
    )

    step1_pdb4amber_run = BashOperator(
        task_id="step1_pdb4amber_run",
        bash_command=create_bash_command(WF_NAME, "step1_pdb4amber_run", "pdb4amber_run")
    )

    step2_leap_gen_top = BashOperator(
        task_id="step2_leap_gen_top",
        bash_command=create_bash_command(WF_NAME, "step2_leap_gen_top", "leap_gen_top")
    )

    step3_sander_mdrun_minH = BashOperator(
        task_id="step3_sander_mdrun_minH",
        bash_command=create_bash_command(WF_NAME, "step3_sander_mdrun_minH", "sander_mdrun")
    )

    step4_process_minout_minH = BashOperator(
        task_id="step4_process_minout_minH",
        bash_command=create_bash_command(WF_NAME, "step4_process_minout_minH", "process_minout")
    )

    step5_sander_mdrun_min = BashOperator(
        task_id="step5_sander_mdrun_min",
        bash_command=create_bash_command(WF_NAME, "step5_sander_mdrun_min", "sander_mdrun")
    )

    step6_process_minout_min = BashOperator(
        task_id="step6_process_minout_min",
        bash_command=create_bash_command(WF_NAME, "step6_process_minout_min", "process_minout")
    )

    step7_amber_to_pdb = BashOperator(
        task_id="step7_amber_to_pdb",
        bash_command=create_bash_command(WF_NAME, "step7_amber_to_pdb", "amber_to_pdb")
    )

    step8_leap_solvate = BashOperator(
        task_id="step8_leap_solvate",
        bash_command=create_bash_command(WF_NAME, "step8_leap_solvate", "leap_solvate")
    )

    step9_leap_add_ions = BashOperator(
        task_id="step9_leap_add_ions",
        bash_command=create_bash_command(WF_NAME, "step9_leap_add_ions", "leap_add_ions")
    )

    step10_sander_mdrun_energy = BashOperator(
        task_id="step10_sander_mdrun_energy",
        bash_command=create_bash_command(WF_NAME, "step10_sander_mdrun_energy", "sander_mdrun")
    )

    step11_process_minout_energy = BashOperator(
        task_id="step11_process_minout_energy",
        bash_command=create_bash_command(WF_NAME, "step11_process_minout_energy", "process_minout")
    )

    step12_sander_mdrun_warm = BashOperator(
        task_id="step12_sander_mdrun_warm",
        bash_command=create_bash_command(WF_NAME, "step12_sander_mdrun_warm", "sander_mdrun")
    )

    step13_process_mdout_warm = BashOperator(
        task_id="step13_process_mdout_warm",
        bash_command=create_bash_command(WF_NAME, "step13_process_mdout_warm", "process_mdout")
    )

    step14_sander_mdrun_nvt = BashOperator(
        task_id="step14_sander_mdrun_nvt",
        bash_command=create_bash_command(WF_NAME, "step14_sander_mdrun_nvt", "sander_mdrun")
    )

    step15_process_mdout_nvt = BashOperator(
        task_id="step15_process_mdout_nvt",
        bash_command=create_bash_command(WF_NAME, "step15_process_mdout_nvt", "process_mdout")
    )

    step16_sander_mdrun_npt = BashOperator(
        task_id="step16_sander_mdrun_npt",
        bash_command=create_bash_command(WF_NAME, "step16_sander_mdrun_npt", "sander_mdrun")
    )

    step17_process_mdout_npt = BashOperator(
        task_id="step17_process_mdout_npt",
        bash_command=create_bash_command(WF_NAME, "step17_process_mdout_npt", "process_mdout")
    )

    step18_sander_mdrun_md = BashOperator(
        task_id="step18_sander_mdrun_md",
        bash_command=create_bash_command(WF_NAME, "step18_sander_mdrun_md", "sander_mdrun")
    )

    step19_rmsd_first = BashOperator(
        task_id="step19_rmsd_first",
        bash_command=create_bash_command(WF_NAME, "step19_rmsd_first", "cpptraj_rms")
    )

    step20_rmsd_exp = BashOperator(
        task_id="step20_rmsd_exp",
        bash_command=create_bash_command(WF_NAME, "step20_rmsd_exp", "cpptraj_rms")
    )

    step21_cpptraj_rgyr = BashOperator(
        task_id="step21_cpptraj_rgyr",
        bash_command=create_bash_command(WF_NAME, "step21_cpptraj_rgyr", "cpptraj_rgyr")
    )

    step22_cpptraj_image = BashOperator(
        task_id="step22_cpptraj_image",
        bash_command=create_bash_command(WF_NAME, "step22_cpptraj_image", "cpptraj_image")
    )

    step00_reduce_remove_hydrogens >> step0_extract_molecule >> step000_cat_pdb >> step1_pdb4amber_run >> step2_leap_gen_top
    step2_leap_gen_top >> step3_sander_mdrun_minH
    step3_sander_mdrun_minH >> step4_process_minout_minH
    [step2_leap_gen_top, step3_sander_mdrun_minH] >> step5_sander_mdrun_min
    step5_sander_mdrun_min >> step6_process_minout_min
    [step2_leap_gen_top, step5_sander_mdrun_min] >> step7_amber_to_pdb >> step8_leap_solvate >> step9_leap_add_ions
    step9_leap_add_ions >> step10_sander_mdrun_energy
    step10_sander_mdrun_energy >> step11_process_minout_energy
    [step10_sander_mdrun_energy, step9_leap_add_ions] >> step12_sander_mdrun_warm
    step12_sander_mdrun_warm >> step13_process_mdout_warm
    [step12_sander_mdrun_warm, step9_leap_add_ions] >> step14_sander_mdrun_nvt
    step14_sander_mdrun_nvt >> step15_process_mdout_nvt
    [step14_sander_mdrun_nvt, step9_leap_add_ions] >> step16_sander_mdrun_npt
    step16_sander_mdrun_npt >> step17_process_mdout_npt
    [step16_sander_mdrun_npt, step9_leap_add_ions] >> step18_sander_mdrun_md
    cross_downstream([step18_sander_mdrun_md, step9_leap_add_ions], [step19_rmsd_first, step21_cpptraj_rgyr, step22_cpptraj_image])
    [step18_sander_mdrun_md, step2_leap_gen_top, step9_leap_add_ions] >> step20_rmsd_exp
