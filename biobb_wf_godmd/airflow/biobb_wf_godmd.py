from airflow import DAG
from airflow.providers.standard.operators.bash import BashOperator
from datetime import datetime
from airflow_cwl_utils import create_bash_command

WF_NAME = "biobb_wf_godmd"

with DAG(WF_NAME, start_date=datetime(2026, 1, 1), schedule=None) as dag:

    step0_extract_chain = BashOperator(
        task_id="step0_extract_chain",
        bash_command=create_bash_command(WF_NAME, "step0_extract_chain", "extract_chain")
    )

    step1_extract_chain = BashOperator(
        task_id="step1_extract_chain",
        bash_command=create_bash_command(WF_NAME, "step1_extract_chain", "extract_chain")
    )

    step2_remove_molecules = BashOperator(
        task_id="step2_remove_molecules",
        bash_command=create_bash_command(WF_NAME, "step2_remove_molecules", "remove_molecules")
    )

    step4_godmd_prep = BashOperator(
        task_id="step4_godmd_prep",
        bash_command=create_bash_command(WF_NAME, "step4_godmd_prep", "godmd_prep")
    )

    step5_godmd_run = BashOperator(
        task_id="step5_godmd_run",
        bash_command=create_bash_command(WF_NAME, "step5_godmd_run", "godmd_run")
    )

    step6_cpptraj_convert = BashOperator(
        task_id="step6_cpptraj_convert",
        bash_command=create_bash_command(WF_NAME, "step6_cpptraj_convert", "cpptraj_convert")
    )

    step0_extract_chain >> step2_remove_molecules
    [step1_extract_chain, step2_remove_molecules] >> step4_godmd_prep
    [step1_extract_chain, step2_remove_molecules, step4_godmd_prep] >> step5_godmd_run >> step6_cpptraj_convert
