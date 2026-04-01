from airflow import DAG
from airflow.providers.standard.operators.bash import BashOperator
from datetime import datetime
from airflow_cwl_utils import create_bash_command

WF_NAME = "biobb_wf_cmip"

with DAG(WF_NAME, start_date=datetime(2026, 1, 1), schedule=None) as dag:

    step0_cmip_prepare_pdb = BashOperator(
        task_id="step0_cmip_prepare_pdb",
        bash_command=create_bash_command(WF_NAME, "step0_cmip_prepare_pdb", "cmip_prepare_pdb")
    )

    step1_cmip_titration = BashOperator(
        task_id="step1_cmip_titration",
        bash_command=create_bash_command(WF_NAME, "step1_cmip_titration", "cmip_titration")
    )

    step2_cat_pdb = BashOperator(
        task_id="step2_cat_pdb",
        bash_command=create_bash_command(WF_NAME, "step2_cat_pdb", "cat_pdb")
    )

    step3_cmip_run_pos = BashOperator(
        task_id="step3_cmip_run_pos",
        bash_command=create_bash_command(WF_NAME, "step3_cmip_run_pos", "cmip_run")
    )

    step4_cmip_run_neg = BashOperator(
        task_id="step4_cmip_run_neg",
        bash_command=create_bash_command(WF_NAME, "step4_cmip_run_neg", "cmip_run")
    )

    step5_cmip_run_neu = BashOperator(
        task_id="step5_cmip_run_neu",
        bash_command=create_bash_command(WF_NAME, "step5_cmip_run_neu", "cmip_run")
    )

    step6_remove_pdb_water = BashOperator(
        task_id="step6_remove_pdb_water",
        bash_command=create_bash_command(WF_NAME, "step6_remove_pdb_water", "remove_pdb_water")
    )

    step7_extract_heteroatoms = BashOperator(
        task_id="step7_extract_heteroatoms",
        bash_command=create_bash_command(WF_NAME, "step7_extract_heteroatoms", "extract_heteroatoms")
    )

    step8_reduce_add_hydrogens = BashOperator(
        task_id="step8_reduce_add_hydrogens",
        bash_command=create_bash_command(WF_NAME, "step8_reduce_add_hydrogens", "reduce_add_hydrogens")
    )

    step9_acpype_params_ac = BashOperator(
        task_id="step9_acpype_params_ac",
        bash_command=create_bash_command(WF_NAME, "step9_acpype_params_ac", "acpype_params_ac")
    )

    step10_leap_gen_top = BashOperator(
        task_id="step10_leap_gen_top",
        bash_command=create_bash_command(WF_NAME, "step10_leap_gen_top", "leap_gen_top")
    )

    step11_sander_mdrun = BashOperator(
        task_id="step11_sander_mdrun",
        bash_command=create_bash_command(WF_NAME, "step11_sander_mdrun", "sander_mdrun")
    )

    step12_amber_to_pdb = BashOperator(
        task_id="step12_amber_to_pdb",
        bash_command=create_bash_command(WF_NAME, "step12_amber_to_pdb", "amber_to_pdb")
    )

    step13_cmip_prepare_structure = BashOperator(
        task_id="step13_cmip_prepare_structure",
        bash_command=create_bash_command(WF_NAME, "step13_cmip_prepare_structure", "cmip_prepare_structure")
    )

    step14_remove_ligand = BashOperator(
        task_id="step14_remove_ligand",
        bash_command=create_bash_command(WF_NAME, "step14_remove_ligand", "remove_ligand")
    )

    step15_cmip_ignore_residues = BashOperator(
        task_id="step15_cmip_ignore_residues",
        bash_command=create_bash_command(WF_NAME, "step15_cmip_ignore_residues", "cmip_ignore_residues")
    )

    step16_cmip_run_int_en = BashOperator(
        task_id="step16_cmip_run_int_en",
        bash_command=create_bash_command(WF_NAME, "step16_cmip_run_int_en", "cmip_run")
    )

    step17_cmip_prepare_structure = BashOperator(
        task_id="step17_cmip_prepare_structure",
        bash_command=create_bash_command(WF_NAME, "step17_cmip_prepare_structure", "cmip_prepare_structure")
    )

    step18_extract_chain_a = BashOperator(
        task_id="step18_extract_chain_a",
        bash_command=create_bash_command(WF_NAME, "step18_extract_chain_a", "extract_chain")
    )

    step19_extract_chain_b = BashOperator(
        task_id="step19_extract_chain_b",
        bash_command=create_bash_command(WF_NAME, "step19_extract_chain_b", "extract_chain")
    )

    step20_cmip_run_rbd = BashOperator(
        task_id="step20_cmip_run_rbd",
        bash_command=create_bash_command(WF_NAME, "step20_cmip_run_rbd", "cmip_run")
    )

    step21_cmip_run_hace2 = BashOperator(
        task_id="step21_cmip_run_hace2",
        bash_command=create_bash_command(WF_NAME, "step21_cmip_run_hace2", "cmip_run")
    )

    step22_cmip_run_rbd_hace2 = BashOperator(
        task_id="step22_cmip_run_rbd_hace2",
        bash_command=create_bash_command(WF_NAME, "step22_cmip_run_rbd_hace2", "cmip_run")
    )

    step23_cmip_ignore_residues_rbd = BashOperator(
        task_id="step23_cmip_ignore_residues_rbd",
        bash_command=create_bash_command(WF_NAME, "step23_cmip_ignore_residues_rbd", "cmip_ignore_residues")
    )

    step24_cmip_run_prot_prot = BashOperator(
        task_id="step24_cmip_run_prot_prot",
        bash_command=create_bash_command(WF_NAME, "step24_cmip_run_prot_prot", "cmip_run")
    )

    step25_cmip_ignore_residues_hace2 = BashOperator(
        task_id="step25_cmip_ignore_residues_hace2",
        bash_command=create_bash_command(WF_NAME, "step25_cmip_ignore_residues_hace2", "cmip_ignore_residues")
    )

    step26_cmip_run_complex = BashOperator(
        task_id="step26_cmip_run_complex",
        bash_command=create_bash_command(WF_NAME, "step26_cmip_run_complex", "cmip_run")
    )

    step0_cmip_prepare_pdb >> [step1_cmip_titration, step3_cmip_run_pos, step4_cmip_run_neg, step5_cmip_run_neu]
    [step0_cmip_prepare_pdb, step1_cmip_titration] >> step2_cat_pdb
    step6_remove_pdb_water >> step7_extract_heteroatoms >> step8_reduce_add_hydrogens >> step9_acpype_params_ac
    [step6_remove_pdb_water, step9_acpype_params_ac] >> step10_leap_gen_top
    step10_leap_gen_top >> step11_sander_mdrun
    [step10_leap_gen_top, step11_sander_mdrun] >> step12_amber_to_pdb
    [step10_leap_gen_top, step12_amber_to_pdb] >> step13_cmip_prepare_structure
    step13_cmip_prepare_structure >> [step14_remove_ligand, step15_cmip_ignore_residues]
    [step14_remove_ligand, step15_cmip_ignore_residues] >> step16_cmip_run_int_en
    step17_cmip_prepare_structure >> [step18_extract_chain_a, step19_extract_chain_b, step22_cmip_run_rbd_hace2, step23_cmip_ignore_residues_rbd, step25_cmip_ignore_residues_hace2]
    step19_extract_chain_b >> step20_cmip_run_rbd
    step18_extract_chain_a >> step21_cmip_run_hace2
    [step19_extract_chain_b, step20_cmip_run_rbd, step22_cmip_run_rbd_hace2, step23_cmip_ignore_residues_rbd] >> step24_cmip_run_prot_prot
    [step18_extract_chain_a, step21_cmip_run_hace2, step22_cmip_run_rbd_hace2, step25_cmip_ignore_residues_hace2] >> step26_cmip_run_complex
