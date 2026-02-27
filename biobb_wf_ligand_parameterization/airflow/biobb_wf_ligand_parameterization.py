from airflow import DAG
from airflow.providers.standard.operators.bash import BashOperator
from datetime import datetime
from airflow_cwl_utils import create_bash_command

WF_NAME = "biobb_wf_ligand_parameterization"

with DAG(WF_NAME, start_date=datetime(2026, 1, 1), schedule=None) as dag:

    step2_babel_minimize = BashOperator(
        task_id="step2_babel_minimize",
        bash_command=create_bash_command(WF_NAME, "step2_babel_minimize", "babel_minimize")
    )

    step3_acpype_params_gmx = BashOperator(
        task_id="step3_acpype_params_gmx",
        bash_command=create_bash_command(WF_NAME, "step3_acpype_params_gmx", "acpype_params_gmx")
    )

    step2_babel_minimize >> step3_acpype_params_gmx
