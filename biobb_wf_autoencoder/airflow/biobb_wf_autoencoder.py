from airflow import DAG
from airflow.providers.standard.operators.bash import BashOperator
from datetime import datetime
from airflow_cwl_utils import create_bash_command

WF_NAME = "biobb_wf_autoencoder"

with DAG(WF_NAME, start_date=datetime(2026, 1, 1), schedule=None) as dag:

    step1_gmx_image1 = BashOperator(
        task_id="step1_gmx_image1",
        bash_command=create_bash_command(WF_NAME, "step1_gmx_image1", "gmx_image")
    )

    step2_mdfeaturizer1 = BashOperator(
        task_id="step2_mdfeaturizer1",
        bash_command=create_bash_command(WF_NAME, "step2_mdfeaturizer1", "mdfeaturizer")
    )

    step3_build_model = BashOperator(
        task_id="step3_build_model",
        bash_command=create_bash_command(WF_NAME, "step3_build_model", "build_model")
    )

    step4_train_model = BashOperator(
        task_id="step4_train_model",
        bash_command=create_bash_command(WF_NAME, "step4_train_model", "train_model")
    )

    step5_gmx_image2 = BashOperator(
        task_id="step5_gmx_image2",
        bash_command=create_bash_command(WF_NAME, "step5_gmx_image2", "gmx_image")
    )

    step6_mdfeaturizer2 = BashOperator(
        task_id="step6_mdfeaturizer2",
        bash_command=create_bash_command(WF_NAME, "step6_mdfeaturizer2", "mdfeaturizer")
    )

    step7_evaluate_model = BashOperator(
        task_id="step7_evaluate_model",
        bash_command=create_bash_command(WF_NAME, "step7_evaluate_model", "evaluate_model")
    )

    step8_make_ndx1 = BashOperator(
        task_id="step8_make_ndx1",
        bash_command=create_bash_command(WF_NAME, "step8_make_ndx1", "make_ndx")
    )

    step9_make_ndx2 = BashOperator(
        task_id="step9_make_ndx2",
        bash_command=create_bash_command(WF_NAME, "step9_make_ndx2", "make_ndx")
    )

    step10_gmx_rmsf1 = BashOperator(
        task_id="step10_gmx_rmsf1",
        bash_command=create_bash_command(WF_NAME, "step10_gmx_rmsf1", "gmx_rmsf")
    )

    step11_gmx_rmsf2 = BashOperator(
        task_id="step11_gmx_rmsf2",
        bash_command=create_bash_command(WF_NAME, "step11_gmx_rmsf2", "gmx_rmsf")
    )

    step12_feat2traj = BashOperator(
        task_id="step12_feat2traj",
        bash_command=create_bash_command(WF_NAME, "step12_feat2traj", "feat2traj")
    )

    step13_gmx_rmsf3 = BashOperator(
        task_id="step13_gmx_rmsf3",
        bash_command=create_bash_command(WF_NAME, "step13_gmx_rmsf3", "gmx_rmsf")
    )

    step14_make_plumed = BashOperator(
        task_id="step14_make_plumed",
        bash_command=create_bash_command(WF_NAME, "step14_make_plumed", "make_plumed")
    )

    step1_gmx_image1 >> step2_mdfeaturizer1
    step5_gmx_image2 >> step6_mdfeaturizer2
    step2_mdfeaturizer1 >> step3_build_model
    [step2_mdfeaturizer1, step3_build_model] >> step4_train_model
    [step2_mdfeaturizer1, step4_train_model] >> step7_evaluate_model
    step8_make_ndx1 >> step10_gmx_rmsf1
    step9_make_ndx2 >> step11_gmx_rmsf2
    [step6_mdfeaturizer2, step7_evaluate_model] >> step12_feat2traj
    [step12_feat2traj, step9_make_ndx2] >> step13_gmx_rmsf3
    [step2_mdfeaturizer1, step4_train_model, step8_make_ndx1] >> step14_make_plumed
