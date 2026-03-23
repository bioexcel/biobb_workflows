from airflow import DAG
from airflow.providers.standard.operators.bash import BashOperator
from datetime import datetime
from airflow_cwl_utils import create_bash_command

WF_NAME = "biobb_wf_mem"

with DAG(WF_NAME, start_date=datetime(2026, 1, 1), schedule=None) as dag:

    step1_gmx_image1 = BashOperator(
        task_id="step1_gmx_image1",
        bash_command=create_bash_command(WF_NAME, "step1_gmx_image1", "gmx_image")
    )

    step2_gmx_image2 = BashOperator(
        task_id="step2_gmx_image2",
        bash_command=create_bash_command(WF_NAME, "step2_gmx_image2", "gmx_image")
    )

    step3_fatslim_membranes = BashOperator(
        task_id="step3_fatslim_membranes",
        bash_command=create_bash_command(WF_NAME, "step3_fatslim_membranes", "fatslim_membranes")
    )

    step4_lpp_assign_leaflets = BashOperator(
        task_id="step4_lpp_assign_leaflets",
        bash_command=create_bash_command(WF_NAME, "step4_lpp_assign_leaflets", "lpp_assign_leaflets")
    )

    step5_lpp_zpositions1 = BashOperator(
        task_id="step5_lpp_zpositions1",
        bash_command=create_bash_command(WF_NAME, "step5_lpp_zpositions1", "lpp_zpositions")
    )

    step6_lpp_zpositions2 = BashOperator(
        task_id="step6_lpp_zpositions2",
        bash_command=create_bash_command(WF_NAME, "step6_lpp_zpositions2", "lpp_zpositions")
    )

    step7_gorder_aa = BashOperator(
        task_id="step7_gorder_aa",
        bash_command=create_bash_command(WF_NAME, "step7_gorder_aa", "gorder_aa")
    )

    step8_fatslim_apl = BashOperator(
        task_id="step8_fatslim_apl",
        bash_command=create_bash_command(WF_NAME, "step8_fatslim_apl", "fatslim_apl")
    )

    step9_cpptraj_density = BashOperator(
        task_id="step9_cpptraj_density",
        bash_command=create_bash_command(WF_NAME, "step9_cpptraj_density", "cpptraj_density")
    )

    step10_mda_hole = BashOperator(
        task_id="step10_mda_hole",
        bash_command=create_bash_command(WF_NAME, "step10_mda_hole", "mda_hole")
    )

    step11_lpp_flip_flop = BashOperator(
        task_id="step11_lpp_flip_flop",
        bash_command=create_bash_command(WF_NAME, "step11_lpp_flip_flop", "lpp_flip_flop")
    )

    step1_gmx_image1 >> [step2_gmx_image2, step8_fatslim_apl]
    step2_gmx_image2 >> [step4_lpp_assign_leaflets, step5_lpp_zpositions1, step6_lpp_zpositions2, step9_cpptraj_density, step10_mda_hole]
    [step2_gmx_image2, step4_lpp_assign_leaflets] >> step11_lpp_flip_flop
