from airflow import DAG
from airflow.providers.standard.operators.bash import BashOperator
from datetime import datetime
from airflow.models.baseoperator import cross_downstream
from airflow_cwl_utils import create_bash_command

WF_NAME = "biobb_wf_amber_abc_setup"

with DAG(WF_NAME, start_date=datetime(2026, 1, 1), schedule=None) as dag:

    step1_leap_gen_top = BashOperator(
        task_id="step1_leap_gen_top",
        bash_command=create_bash_command(WF_NAME, "step1_leap_gen_top", "leap_gen_top")
    )

    step2_leap_solvate = BashOperator(
        task_id="step2_leap_solvate",
        bash_command=create_bash_command(WF_NAME, "step2_leap_solvate", "leap_solvate")
    )

    step3_leap_add_ions = BashOperator(
        task_id="step3_leap_add_ions",
        bash_command=create_bash_command(WF_NAME, "step3_leap_add_ions", "leap_add_ions")
    )

    step4_cpptraj_randomize_ions = BashOperator(
        task_id="step4_cpptraj_randomize_ions",
        bash_command=create_bash_command(WF_NAME, "step4_cpptraj_randomize_ions", "cpptraj_randomize_ions")
    )

    step5_parmed_hmassrepartition = BashOperator(
        task_id="step5_parmed_hmassrepartition",
        bash_command=create_bash_command(WF_NAME, "step5_parmed_hmassrepartition", "parmed_hmassrepartition")
    )

    step6_sander_mdrun_eq1 = BashOperator(
        task_id="step6_sander_mdrun_eq1",
        bash_command=create_bash_command(WF_NAME, "step6_sander_mdrun_eq1", "sander_mdrun")
    )

    step7_process_minout_eq1 = BashOperator(
        task_id="step7_process_minout_eq1",
        bash_command=create_bash_command(WF_NAME, "step7_process_minout_eq1", "process_minout")
    )

    step8_sander_mdrun_eq2 = BashOperator(
        task_id="step8_sander_mdrun_eq2",
        bash_command=create_bash_command(WF_NAME, "step8_sander_mdrun_eq2", "sander_mdrun")
    )

    step9_process_mdout_eq2 = BashOperator(
        task_id="step9_process_mdout_eq2",
        bash_command=create_bash_command(WF_NAME, "step9_process_mdout_eq2", "process_mdout")
    )

    step10_sander_mdrun_eq3 = BashOperator(
        task_id="step10_sander_mdrun_eq3",
        bash_command=create_bash_command(WF_NAME, "step10_sander_mdrun_eq3", "sander_mdrun")
    )

    step11_process_minout_eq3 = BashOperator(
        task_id="step11_process_minout_eq3",
        bash_command=create_bash_command(WF_NAME, "step11_process_minout_eq3", "process_minout")
    )

    step12_sander_mdrun_eq4 = BashOperator(
        task_id="step12_sander_mdrun_eq4",
        bash_command=create_bash_command(WF_NAME, "step12_sander_mdrun_eq4", "sander_mdrun")
    )

    step13_process_minout_eq4 = BashOperator(
        task_id="step13_process_minout_eq4",
        bash_command=create_bash_command(WF_NAME, "step13_process_minout_eq4", "process_minout")
    )

    step14_sander_mdrun_eq5 = BashOperator(
        task_id="step14_sander_mdrun_eq5",
        bash_command=create_bash_command(WF_NAME, "step14_sander_mdrun_eq5", "sander_mdrun")
    )

    step15_process_minout_eq5 = BashOperator(
        task_id="step15_process_minout_eq5",
        bash_command=create_bash_command(WF_NAME, "step15_process_minout_eq5", "process_minout")
    )

    step16_sander_mdrun_eq6 = BashOperator(
        task_id="step16_sander_mdrun_eq6",
        bash_command=create_bash_command(WF_NAME, "step16_sander_mdrun_eq6", "sander_mdrun")
    )

    step17_process_mdout_eq6 = BashOperator(
        task_id="step17_process_mdout_eq6",
        bash_command=create_bash_command(WF_NAME, "step17_process_mdout_eq6", "process_mdout")
    )

    step18_sander_mdrun_eq7 = BashOperator(
        task_id="step18_sander_mdrun_eq7",
        bash_command=create_bash_command(WF_NAME, "step18_sander_mdrun_eq7", "sander_mdrun")
    )

    step19_process_mdout_eq7 = BashOperator(
        task_id="step19_process_mdout_eq7",
        bash_command=create_bash_command(WF_NAME, "step19_process_mdout_eq7", "process_mdout")
    )

    step20_sander_mdrun_eq8 = BashOperator(
        task_id="step20_sander_mdrun_eq8",
        bash_command=create_bash_command(WF_NAME, "step20_sander_mdrun_eq8", "sander_mdrun")
    )

    step21_process_mdout_eq8 = BashOperator(
        task_id="step21_process_mdout_eq8",
        bash_command=create_bash_command(WF_NAME, "step21_process_mdout_eq8", "process_mdout")
    )

    step22_sander_mdrun_eq9 = BashOperator(
        task_id="step22_sander_mdrun_eq9",
        bash_command=create_bash_command(WF_NAME, "step22_sander_mdrun_eq9", "sander_mdrun")
    )

    step23_process_mdout_eq9 = BashOperator(
        task_id="step23_process_mdout_eq9",
        bash_command=create_bash_command(WF_NAME, "step23_process_mdout_eq9", "process_mdout")
    )

    step24_sander_mdrun_eq10 = BashOperator(
        task_id="step24_sander_mdrun_eq10",
        bash_command=create_bash_command(WF_NAME, "step24_sander_mdrun_eq10", "sander_mdrun")
    )

    step25_process_mdout_eq10 = BashOperator(
        task_id="step25_process_mdout_eq10",
        bash_command=create_bash_command(WF_NAME, "step25_process_mdout_eq10", "process_mdout")
    )

    step26_sander_mdrun_md = BashOperator(
        task_id="step26_sander_mdrun_md",
        bash_command=create_bash_command(WF_NAME, "step26_sander_mdrun_md", "sander_mdrun")
    )

    step27_rmsd_first = BashOperator(
        task_id="step27_rmsd_first",
        bash_command=create_bash_command(WF_NAME, "step27_rmsd_first", "cpptraj_rms")
    )

    step28_rmsd_exp = BashOperator(
        task_id="step28_rmsd_exp",
        bash_command=create_bash_command(WF_NAME, "step28_rmsd_exp", "cpptraj_rms")
    )

    step29_cpptraj_rgyr = BashOperator(
        task_id="step29_cpptraj_rgyr",
        bash_command=create_bash_command(WF_NAME, "step29_cpptraj_rgyr", "cpptraj_rgyr")
    )

    step30_cpptraj_image = BashOperator(
        task_id="step30_cpptraj_image",
        bash_command=create_bash_command(WF_NAME, "step30_cpptraj_image", "cpptraj_image")
    )

    step1_leap_gen_top >> step2_leap_solvate >> step3_leap_add_ions
    step3_leap_add_ions >> [step4_cpptraj_randomize_ions, step5_parmed_hmassrepartition]
    [step4_cpptraj_randomize_ions, step5_parmed_hmassrepartition] >> step6_sander_mdrun_eq1
    step6_sander_mdrun_eq1 >> step7_process_minout_eq1
    [step5_parmed_hmassrepartition, step6_sander_mdrun_eq1] >> step8_sander_mdrun_eq2
    step8_sander_mdrun_eq2 >> step9_process_mdout_eq2
    [step5_parmed_hmassrepartition, step8_sander_mdrun_eq2] >> step10_sander_mdrun_eq3
    step10_sander_mdrun_eq3 >> step11_process_minout_eq3
    [step10_sander_mdrun_eq3, step5_parmed_hmassrepartition] >> step12_sander_mdrun_eq4
    step12_sander_mdrun_eq4 >> step13_process_minout_eq4
    [step12_sander_mdrun_eq4, step5_parmed_hmassrepartition] >> step14_sander_mdrun_eq5
    step14_sander_mdrun_eq5 >> step15_process_minout_eq5
    [step14_sander_mdrun_eq5, step5_parmed_hmassrepartition] >> step16_sander_mdrun_eq6
    step16_sander_mdrun_eq6 >> step17_process_mdout_eq6
    [step16_sander_mdrun_eq6, step5_parmed_hmassrepartition] >> step18_sander_mdrun_eq7
    step18_sander_mdrun_eq7 >> step19_process_mdout_eq7
    [step18_sander_mdrun_eq7, step5_parmed_hmassrepartition] >> step20_sander_mdrun_eq8
    step20_sander_mdrun_eq8 >> step21_process_mdout_eq8
    [step20_sander_mdrun_eq8, step5_parmed_hmassrepartition] >> step22_sander_mdrun_eq9
    step22_sander_mdrun_eq9 >> step23_process_mdout_eq9
    [step22_sander_mdrun_eq9, step5_parmed_hmassrepartition] >> step24_sander_mdrun_eq10
    step24_sander_mdrun_eq10 >> step25_process_mdout_eq10
    [step24_sander_mdrun_eq10, step5_parmed_hmassrepartition] >> step26_sander_mdrun_md
    cross_downstream([step26_sander_mdrun_md, step3_leap_add_ions], [step27_rmsd_first, step29_cpptraj_rgyr, step30_cpptraj_image])
    [step1_leap_gen_top, step26_sander_mdrun_md, step3_leap_add_ions] >> step28_rmsd_exp
