from airflow import DAG
from airflow.providers.standard.operators.bash import BashOperator
from datetime import datetime
from airflow_cwl_utils import create_bash_command

WF_NAME = "biobb_wf_structure_checking"

with DAG(WF_NAME, start_date=datetime(2026, 1, 1), schedule=None) as dag:

    step0_structure_check_init = BashOperator(
        task_id="step0_structure_check_init",
        bash_command=create_bash_command(WF_NAME, "step0_structure_check_init", "structure_check")
    )

    step1_extract_model = BashOperator(
        task_id="step1_extract_model",
        bash_command=create_bash_command(WF_NAME, "step1_extract_model", "extract_model")
    )

    step2_extract_chain = BashOperator(
        task_id="step2_extract_chain",
        bash_command=create_bash_command(WF_NAME, "step2_extract_chain", "extract_chain")
    )

    step3_fix_altlocs = BashOperator(
        task_id="step3_fix_altlocs",
        bash_command=create_bash_command(WF_NAME, "step3_fix_altlocs", "fix_altlocs")
    )

    step4_fix_ssbonds = BashOperator(
        task_id="step4_fix_ssbonds",
        bash_command=create_bash_command(WF_NAME, "step4_fix_ssbonds", "fix_ssbonds")
    )

    step5_remove_molecules_ions = BashOperator(
        task_id="step5_remove_molecules_ions",
        bash_command=create_bash_command(WF_NAME, "step5_remove_molecules_ions", "remove_molecules")
    )

    step6_remove_molecules_ligands = BashOperator(
        task_id="step6_remove_molecules_ligands",
        bash_command=create_bash_command(WF_NAME, "step6_remove_molecules_ligands", "remove_molecules")
    )

    step7_reduce_remove_hydrogens = BashOperator(
        task_id="step7_reduce_remove_hydrogens",
        bash_command=create_bash_command(WF_NAME, "step7_reduce_remove_hydrogens", "reduce_remove_hydrogens")
    )

    step8_remove_pdb_water = BashOperator(
        task_id="step8_remove_pdb_water",
        bash_command=create_bash_command(WF_NAME, "step8_remove_pdb_water", "remove_pdb_water")
    )

    step9_fix_amides = BashOperator(
        task_id="step9_fix_amides",
        bash_command=create_bash_command(WF_NAME, "step9_fix_amides", "fix_amides")
    )

    step10_fix_chirality = BashOperator(
        task_id="step10_fix_chirality",
        bash_command=create_bash_command(WF_NAME, "step10_fix_chirality", "fix_chirality")
    )

    step11_fix_side_chain = BashOperator(
        task_id="step11_fix_side_chain",
        bash_command=create_bash_command(WF_NAME, "step11_fix_side_chain", "fix_side_chain")
    )

    step12_fix_backbone = BashOperator(
        task_id="step12_fix_backbone",
        bash_command=create_bash_command(WF_NAME, "step12_fix_backbone", "fix_backbone")
    )

    step13_leap_gen_top = BashOperator(
        task_id="step13_leap_gen_top",
        bash_command=create_bash_command(WF_NAME, "step13_leap_gen_top", "leap_gen_top")
    )

    step14_sander_mdrun = BashOperator(
        task_id="step14_sander_mdrun",
        bash_command=create_bash_command(WF_NAME, "step14_sander_mdrun", "sander_mdrun")
    )

    step15_amber_to_pdb = BashOperator(
        task_id="step15_amber_to_pdb",
        bash_command=create_bash_command(WF_NAME, "step15_amber_to_pdb", "amber_to_pdb")
    )

    step16_fix_pdb = BashOperator(
        task_id="step16_fix_pdb",
        bash_command=create_bash_command(WF_NAME, "step16_fix_pdb", "fix_pdb")
    )

    step17_structure_check = BashOperator(
        task_id="step17_structure_check",
        bash_command=create_bash_command(WF_NAME, "step17_structure_check", "structure_check")
    )

    step1_extract_model >> step2_extract_chain >> step3_fix_altlocs >> step4_fix_ssbonds >> step5_remove_molecules_ions >> step6_remove_molecules_ligands >> step7_reduce_remove_hydrogens >> step8_remove_pdb_water >> step9_fix_amides >> step10_fix_chirality >> step11_fix_side_chain >> step12_fix_backbone >> step13_leap_gen_top
    step13_leap_gen_top >> step14_sander_mdrun
    [step13_leap_gen_top, step14_sander_mdrun] >> step15_amber_to_pdb >> step16_fix_pdb >> step17_structure_check
