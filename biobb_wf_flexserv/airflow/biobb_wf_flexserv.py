from airflow import DAG
from airflow.providers.standard.operators.bash import BashOperator
from datetime import datetime
from airflow.models.baseoperator import cross_downstream
from airflow_cwl_utils import create_bash_command

WF_NAME = "biobb_wf_flexserv"

with DAG(WF_NAME, start_date=datetime(2026, 1, 1), schedule=None) as dag:

    step0_extract_atoms = BashOperator(
        task_id="step0_extract_atoms",
        bash_command=create_bash_command(WF_NAME, "step0_extract_atoms", "extract_atoms")
    )

    step1_bd_run = BashOperator(
        task_id="step1_bd_run",
        bash_command=create_bash_command(WF_NAME, "step1_bd_run", "bd_run")
    )

    step2_cpptraj_rms = BashOperator(
        task_id="step2_cpptraj_rms",
        bash_command=create_bash_command(WF_NAME, "step2_cpptraj_rms", "cpptraj_rms")
    )

    step3_dmd_run = BashOperator(
        task_id="step3_dmd_run",
        bash_command=create_bash_command(WF_NAME, "step3_dmd_run", "dmd_run")
    )

    step4_cpptraj_rms = BashOperator(
        task_id="step4_cpptraj_rms",
        bash_command=create_bash_command(WF_NAME, "step4_cpptraj_rms", "cpptraj_rms")
    )

    step5_nma_run = BashOperator(
        task_id="step5_nma_run",
        bash_command=create_bash_command(WF_NAME, "step5_nma_run", "nma_run")
    )

    step6_cpptraj_rms = BashOperator(
        task_id="step6_cpptraj_rms",
        bash_command=create_bash_command(WF_NAME, "step6_cpptraj_rms", "cpptraj_rms")
    )

    step7_pcz_zip = BashOperator(
        task_id="step7_pcz_zip",
        bash_command=create_bash_command(WF_NAME, "step7_pcz_zip", "pcz_zip")
    )

    step8_pcz_zip = BashOperator(
        task_id="step8_pcz_zip",
        bash_command=create_bash_command(WF_NAME, "step8_pcz_zip", "pcz_zip")
    )

    step9_pcz_zip = BashOperator(
        task_id="step9_pcz_zip",
        bash_command=create_bash_command(WF_NAME, "step9_pcz_zip", "pcz_zip")
    )

    step10_pcz_unzip = BashOperator(
        task_id="step10_pcz_unzip",
        bash_command=create_bash_command(WF_NAME, "step10_pcz_unzip", "pcz_unzip")
    )

    step11_pcz_unzip = BashOperator(
        task_id="step11_pcz_unzip",
        bash_command=create_bash_command(WF_NAME, "step11_pcz_unzip", "pcz_unzip")
    )

    step12_pcz_unzip = BashOperator(
        task_id="step12_pcz_unzip",
        bash_command=create_bash_command(WF_NAME, "step12_pcz_unzip", "pcz_unzip")
    )

    step13_cpptraj_rms = BashOperator(
        task_id="step13_cpptraj_rms",
        bash_command=create_bash_command(WF_NAME, "step13_cpptraj_rms", "cpptraj_rms")
    )

    step14_cpptraj_rms = BashOperator(
        task_id="step14_cpptraj_rms",
        bash_command=create_bash_command(WF_NAME, "step14_cpptraj_rms", "cpptraj_rms")
    )

    step15_cpptraj_rms = BashOperator(
        task_id="step15_cpptraj_rms",
        bash_command=create_bash_command(WF_NAME, "step15_cpptraj_rms", "cpptraj_rms")
    )

    step16_pcz_info = BashOperator(
        task_id="step16_pcz_info",
        bash_command=create_bash_command(WF_NAME, "step16_pcz_info", "pcz_info")
    )

    step17_pcz_evecs = BashOperator(
        task_id="step17_pcz_evecs",
        bash_command=create_bash_command(WF_NAME, "step17_pcz_evecs", "pcz_evecs")
    )

    step18_pcz_animate = BashOperator(
        task_id="step18_pcz_animate",
        bash_command=create_bash_command(WF_NAME, "step18_pcz_animate", "pcz_animate")
    )

    step19_cpptraj_convert = BashOperator(
        task_id="step19_cpptraj_convert",
        bash_command=create_bash_command(WF_NAME, "step19_cpptraj_convert", "cpptraj_convert")
    )

    step20_pcz_bfactor = BashOperator(
        task_id="step20_pcz_bfactor",
        bash_command=create_bash_command(WF_NAME, "step20_pcz_bfactor", "pcz_bfactor")
    )

    step21_pcz_hinges = BashOperator(
        task_id="step21_pcz_hinges",
        bash_command=create_bash_command(WF_NAME, "step21_pcz_hinges", "pcz_hinges")
    )

    step22_pcz_hinges = BashOperator(
        task_id="step22_pcz_hinges",
        bash_command=create_bash_command(WF_NAME, "step22_pcz_hinges", "pcz_hinges")
    )

    step23_pcz_hinges = BashOperator(
        task_id="step23_pcz_hinges",
        bash_command=create_bash_command(WF_NAME, "step23_pcz_hinges", "pcz_hinges")
    )

    step24_pcz_stiffness = BashOperator(
        task_id="step24_pcz_stiffness",
        bash_command=create_bash_command(WF_NAME, "step24_pcz_stiffness", "pcz_stiffness")
    )

    step25_pcz_collectivity = BashOperator(
        task_id="step25_pcz_collectivity",
        bash_command=create_bash_command(WF_NAME, "step25_pcz_collectivity", "pcz_collectivity")
    )

    step26_pcz_similarity = BashOperator(
        task_id="step26_pcz_similarity",
        bash_command=create_bash_command(WF_NAME, "step26_pcz_similarity", "pcz_similarity")
    )

    step27_pcz_similarity = BashOperator(
        task_id="step27_pcz_similarity",
        bash_command=create_bash_command(WF_NAME, "step27_pcz_similarity", "pcz_similarity")
    )

    step28_pcz_similarity = BashOperator(
        task_id="step28_pcz_similarity",
        bash_command=create_bash_command(WF_NAME, "step28_pcz_similarity", "pcz_similarity")
    )

    step0_extract_atoms >> [step1_bd_run, step3_dmd_run, step5_nma_run]
    cross_downstream([step0_extract_atoms, step1_bd_run], [step2_cpptraj_rms, step7_pcz_zip])
    cross_downstream([step0_extract_atoms, step3_dmd_run], [step4_cpptraj_rms, step8_pcz_zip])
    cross_downstream([step0_extract_atoms, step5_nma_run], [step6_cpptraj_rms, step9_pcz_zip])
    step7_pcz_zip >> [step10_pcz_unzip, step21_pcz_hinges, step22_pcz_hinges, step23_pcz_hinges, step26_pcz_similarity]
    step8_pcz_zip >> [step11_pcz_unzip, step27_pcz_similarity]
    step9_pcz_zip >> [step12_pcz_unzip, step16_pcz_info, step17_pcz_evecs, step18_pcz_animate, step20_pcz_bfactor, step24_pcz_stiffness, step25_pcz_collectivity, step28_pcz_similarity]
    [step0_extract_atoms, step10_pcz_unzip] >> step13_cpptraj_rms
    [step0_extract_atoms, step11_pcz_unzip] >> step14_cpptraj_rms
    [step0_extract_atoms, step12_pcz_unzip] >> step15_cpptraj_rms
    [step0_extract_atoms, step18_pcz_animate] >> step19_cpptraj_convert
