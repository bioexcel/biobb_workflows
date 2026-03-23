from airflow import DAG
from airflow.providers.standard.operators.bash import BashOperator
from datetime import datetime
from airflow.models.baseoperator import cross_downstream
from airflow_cwl_utils import create_bash_command

WF_NAME = "biobb_wf_flexdyn"

with DAG(WF_NAME, start_date=datetime(2026, 1, 1), schedule=None) as dag:

    step0_extract_model = BashOperator(
        task_id="step0_extract_model",
        bash_command=create_bash_command(WF_NAME, "step0_extract_model", "extract_model")
    )

    step1_extract_chain = BashOperator(
        task_id="step1_extract_chain",
        bash_command=create_bash_command(WF_NAME, "step1_extract_chain", "extract_chain")
    )

    step2_cpptraj_mask = BashOperator(
        task_id="step2_cpptraj_mask",
        bash_command=create_bash_command(WF_NAME, "step2_cpptraj_mask", "cpptraj_mask")
    )

    step3_cpptraj_mask = BashOperator(
        task_id="step3_cpptraj_mask",
        bash_command=create_bash_command(WF_NAME, "step3_cpptraj_mask", "cpptraj_mask")
    )

    step4_concoord_dist = BashOperator(
        task_id="step4_concoord_dist",
        bash_command=create_bash_command(WF_NAME, "step4_concoord_dist", "concoord_dist")
    )

    step5_concoord_disco = BashOperator(
        task_id="step5_concoord_disco",
        bash_command=create_bash_command(WF_NAME, "step5_concoord_disco", "concoord_disco")
    )

    step6_cpptraj_rms = BashOperator(
        task_id="step6_cpptraj_rms",
        bash_command=create_bash_command(WF_NAME, "step6_cpptraj_rms", "cpptraj_rms")
    )

    step7_cpptraj_convert = BashOperator(
        task_id="step7_cpptraj_convert",
        bash_command=create_bash_command(WF_NAME, "step7_cpptraj_convert", "cpptraj_convert")
    )

    step8_prody_anm = BashOperator(
        task_id="step8_prody_anm",
        bash_command=create_bash_command(WF_NAME, "step8_prody_anm", "prody_anm")
    )

    step9_cpptraj_rms = BashOperator(
        task_id="step9_cpptraj_rms",
        bash_command=create_bash_command(WF_NAME, "step9_cpptraj_rms", "cpptraj_rms")
    )

    step10_cpptraj_convert = BashOperator(
        task_id="step10_cpptraj_convert",
        bash_command=create_bash_command(WF_NAME, "step10_cpptraj_convert", "cpptraj_convert")
    )

    step11_bd_run = BashOperator(
        task_id="step11_bd_run",
        bash_command=create_bash_command(WF_NAME, "step11_bd_run", "bd_run")
    )

    step12_cpptraj_rms = BashOperator(
        task_id="step12_cpptraj_rms",
        bash_command=create_bash_command(WF_NAME, "step12_cpptraj_rms", "cpptraj_rms")
    )

    step13_dmd_run = BashOperator(
        task_id="step13_dmd_run",
        bash_command=create_bash_command(WF_NAME, "step13_dmd_run", "dmd_run")
    )

    step14_cpptraj_rms = BashOperator(
        task_id="step14_cpptraj_rms",
        bash_command=create_bash_command(WF_NAME, "step14_cpptraj_rms", "cpptraj_rms")
    )

    step15_nma_run = BashOperator(
        task_id="step15_nma_run",
        bash_command=create_bash_command(WF_NAME, "step15_nma_run", "nma_run")
    )

    step16_cpptraj_rms = BashOperator(
        task_id="step16_cpptraj_rms",
        bash_command=create_bash_command(WF_NAME, "step16_cpptraj_rms", "cpptraj_rms")
    )

    step17_cpptraj_convert = BashOperator(
        task_id="step17_cpptraj_convert",
        bash_command=create_bash_command(WF_NAME, "step17_cpptraj_convert", "cpptraj_convert")
    )

    step18_nolb_nma = BashOperator(
        task_id="step18_nolb_nma",
        bash_command=create_bash_command(WF_NAME, "step18_nolb_nma", "nolb_nma")
    )

    step19_cpptraj_rms = BashOperator(
        task_id="step19_cpptraj_rms",
        bash_command=create_bash_command(WF_NAME, "step19_cpptraj_rms", "cpptraj_rms")
    )

    step20_cpptraj_convert = BashOperator(
        task_id="step20_cpptraj_convert",
        bash_command=create_bash_command(WF_NAME, "step20_cpptraj_convert", "cpptraj_convert")
    )

    step21_imod_imode = BashOperator(
        task_id="step21_imod_imode",
        bash_command=create_bash_command(WF_NAME, "step21_imod_imode", "imod_imode")
    )

    step22_imod_imc = BashOperator(
        task_id="step22_imod_imc",
        bash_command=create_bash_command(WF_NAME, "step22_imod_imc", "imod_imc")
    )

    step23_cpptraj_rms = BashOperator(
        task_id="step23_cpptraj_rms",
        bash_command=create_bash_command(WF_NAME, "step23_cpptraj_rms", "cpptraj_rms")
    )

    step24_cpptraj_convert = BashOperator(
        task_id="step24_cpptraj_convert",
        bash_command=create_bash_command(WF_NAME, "step24_cpptraj_convert", "cpptraj_convert")
    )

    step26_make_ndx = BashOperator(
        task_id="step26_make_ndx",
        bash_command=create_bash_command(WF_NAME, "step26_make_ndx", "make_ndx")
    )

    step27_gmx_cluster = BashOperator(
        task_id="step27_gmx_cluster",
        bash_command=create_bash_command(WF_NAME, "step27_gmx_cluster", "gmx_cluster")
    )

    step28_cpptraj_rms = BashOperator(
        task_id="step28_cpptraj_rms",
        bash_command=create_bash_command(WF_NAME, "step28_cpptraj_rms", "cpptraj_rms")
    )

    step29_pcz_zip = BashOperator(
        task_id="step29_pcz_zip",
        bash_command=create_bash_command(WF_NAME, "step29_pcz_zip", "pcz_zip")
    )

    step30_pcz_zip = BashOperator(
        task_id="step30_pcz_zip",
        bash_command=create_bash_command(WF_NAME, "step30_pcz_zip", "pcz_zip")
    )

    step31_pcz_info = BashOperator(
        task_id="step31_pcz_info",
        bash_command=create_bash_command(WF_NAME, "step31_pcz_info", "pcz_info")
    )

    step32_pcz_evecs = BashOperator(
        task_id="step32_pcz_evecs",
        bash_command=create_bash_command(WF_NAME, "step32_pcz_evecs", "pcz_evecs")
    )

    step33_pcz_animate = BashOperator(
        task_id="step33_pcz_animate",
        bash_command=create_bash_command(WF_NAME, "step33_pcz_animate", "pcz_animate")
    )

    step34_cpptraj_convert = BashOperator(
        task_id="step34_cpptraj_convert",
        bash_command=create_bash_command(WF_NAME, "step34_cpptraj_convert", "cpptraj_convert")
    )

    step35_pcz_bfactor = BashOperator(
        task_id="step35_pcz_bfactor",
        bash_command=create_bash_command(WF_NAME, "step35_pcz_bfactor", "pcz_bfactor")
    )

    step36_pcz_hinges = BashOperator(
        task_id="step36_pcz_hinges",
        bash_command=create_bash_command(WF_NAME, "step36_pcz_hinges", "pcz_hinges")
    )

    step37_pcz_hinges = BashOperator(
        task_id="step37_pcz_hinges",
        bash_command=create_bash_command(WF_NAME, "step37_pcz_hinges", "pcz_hinges")
    )

    step38_pcz_hinges = BashOperator(
        task_id="step38_pcz_hinges",
        bash_command=create_bash_command(WF_NAME, "step38_pcz_hinges", "pcz_hinges")
    )

    step39_pcz_stiffness = BashOperator(
        task_id="step39_pcz_stiffness",
        bash_command=create_bash_command(WF_NAME, "step39_pcz_stiffness", "pcz_stiffness")
    )

    step40_pcz_collectivity = BashOperator(
        task_id="step40_pcz_collectivity",
        bash_command=create_bash_command(WF_NAME, "step40_pcz_collectivity", "pcz_collectivity")
    )

    step0_extract_model >> step1_extract_chain
    step1_extract_chain >> [step2_cpptraj_mask, step3_cpptraj_mask, step4_concoord_dist, step8_prody_anm, step21_imod_imode]
    step4_concoord_dist >> step5_concoord_disco
    [step1_extract_chain, step4_concoord_dist, step5_concoord_disco] >> step6_cpptraj_rms
    [step4_concoord_dist, step5_concoord_disco] >> step7_cpptraj_convert
    [step1_extract_chain, step8_prody_anm] >> step9_cpptraj_rms
    [step2_cpptraj_mask, step8_prody_anm] >> step10_cpptraj_convert
    step3_cpptraj_mask >> [step11_bd_run, step13_dmd_run, step15_nma_run, step18_nolb_nma, step26_make_ndx]
    [step11_bd_run, step1_extract_chain, step3_cpptraj_mask] >> step12_cpptraj_rms
    [step13_dmd_run, step1_extract_chain, step3_cpptraj_mask] >> step14_cpptraj_rms
    [step15_nma_run, step1_extract_chain, step3_cpptraj_mask] >> step16_cpptraj_rms
    [step15_nma_run, step3_cpptraj_mask] >> step17_cpptraj_convert
    [step18_nolb_nma, step1_extract_chain, step3_cpptraj_mask] >> step19_cpptraj_rms
    [step18_nolb_nma, step3_cpptraj_mask] >> step20_cpptraj_convert
    [step1_extract_chain, step21_imod_imode] >> step22_imod_imc
    [step1_extract_chain, step22_imod_imc] >> step23_cpptraj_rms
    step22_imod_imc >> step24_cpptraj_convert
    [step14_cpptraj_rms, step26_make_ndx, step3_cpptraj_mask] >> step27_gmx_cluster
    [step27_gmx_cluster, step3_cpptraj_mask] >> step28_cpptraj_rms
    cross_downstream([step28_cpptraj_rms, step3_cpptraj_mask], [step29_pcz_zip, step30_pcz_zip])
    step29_pcz_zip >> [step31_pcz_info, step32_pcz_evecs, step33_pcz_animate, step35_pcz_bfactor, step39_pcz_stiffness, step40_pcz_collectivity]
    [step33_pcz_animate, step3_cpptraj_mask] >> step34_cpptraj_convert
    step30_pcz_zip >> [step36_pcz_hinges, step37_pcz_hinges, step38_pcz_hinges]
