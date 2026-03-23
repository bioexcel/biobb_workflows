from airflow import DAG
from airflow.providers.standard.operators.bash import BashOperator
from datetime import datetime
from airflow_cwl_utils import create_bash_command

WF_NAME = "biobb_wf_virtual-screening_fpocket"

with DAG(WF_NAME, start_date=datetime(2026, 1, 1), schedule=None) as dag:

    step1_fpocket_select = BashOperator(
        task_id="step1_fpocket_select",
        bash_command=create_bash_command(WF_NAME, "step1_fpocket_select", "fpocket_select")
    )

    step2_box = BashOperator(
        task_id="step2_box",
        bash_command=create_bash_command(WF_NAME, "step2_box", "box")
    )

    step3_babel_convert_prep_lig = BashOperator(
        task_id="step3_babel_convert_prep_lig",
        bash_command=create_bash_command(WF_NAME, "step3_babel_convert_prep_lig", "babel_convert")
    )

    step4_str_check_add_hydrogens = BashOperator(
        task_id="step4_str_check_add_hydrogens",
        bash_command=create_bash_command(WF_NAME, "step4_str_check_add_hydrogens", "str_check_add_hydrogens")
    )

    step5_autodock_vina_run = BashOperator(
        task_id="step5_autodock_vina_run",
        bash_command=create_bash_command(WF_NAME, "step5_autodock_vina_run", "autodock_vina_run")
    )

    step6_babel_convert_pose_pdb = BashOperator(
        task_id="step6_babel_convert_pose_pdb",
        bash_command=create_bash_command(WF_NAME, "step6_babel_convert_pose_pdb", "babel_convert")
    )

    step1_fpocket_select >> step2_box
    [step2_box, step3_babel_convert_prep_lig, step4_str_check_add_hydrogens] >> step5_autodock_vina_run >> step6_babel_convert_pose_pdb
