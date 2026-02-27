from airflow import DAG
from airflow.providers.standard.operators.bash import BashOperator
from datetime import datetime
from airflow.models.baseoperator import cross_downstream
from airflow_cwl_utils import create_bash_command

WF_NAME = "biobb_wf_md_setup"

with DAG(WF_NAME, start_date=datetime(2026, 1, 1), schedule=None) as dag:

    step0_reduce_remove_hydrogens = BashOperator(
        task_id="step0_reduce_remove_hydrogens",
        bash_command=create_bash_command(WF_NAME, "step0_reduce_remove_hydrogens", "reduce_remove_hydrogens")
    )

    step1_extract_molecule = BashOperator(
        task_id="step1_extract_molecule",
        bash_command=create_bash_command(WF_NAME, "step1_extract_molecule", "extract_molecule")
    )

    step00_cat_pdb = BashOperator(
        task_id="step00_cat_pdb",
        bash_command=create_bash_command(WF_NAME, "step00_cat_pdb", "cat_pdb")
    )

    step2_fix_side_chain = BashOperator(
        task_id="step2_fix_side_chain",
        bash_command=create_bash_command(WF_NAME, "step2_fix_side_chain", "fix_side_chain")
    )

    step4_pdb2gmx = BashOperator(
        task_id="step4_pdb2gmx",
        bash_command=create_bash_command(WF_NAME, "step4_pdb2gmx", "pdb2gmx")
    )

    step5_editconf = BashOperator(
        task_id="step5_editconf",
        bash_command=create_bash_command(WF_NAME, "step5_editconf", "editconf")
    )

    step6_solvate = BashOperator(
        task_id="step6_solvate",
        bash_command=create_bash_command(WF_NAME, "step6_solvate", "solvate")
    )

    step7_grompp_genion = BashOperator(
        task_id="step7_grompp_genion",
        bash_command=create_bash_command(WF_NAME, "step7_grompp_genion", "grompp")
    )

    step8_genion = BashOperator(
        task_id="step8_genion",
        bash_command=create_bash_command(WF_NAME, "step8_genion", "genion")
    )

    step9_grompp_min = BashOperator(
        task_id="step9_grompp_min",
        bash_command=create_bash_command(WF_NAME, "step9_grompp_min", "grompp")
    )

    step10_mdrun_min = BashOperator(
        task_id="step10_mdrun_min",
        bash_command=create_bash_command(WF_NAME, "step10_mdrun_min", "mdrun")
    )

    step100_make_ndx = BashOperator(
        task_id="step100_make_ndx",
        bash_command=create_bash_command(WF_NAME, "step100_make_ndx", "make_ndx")
    )

    step11_grompp_nvt = BashOperator(
        task_id="step11_grompp_nvt",
        bash_command=create_bash_command(WF_NAME, "step11_grompp_nvt", "grompp")
    )

    step12_mdrun_nvt = BashOperator(
        task_id="step12_mdrun_nvt",
        bash_command=create_bash_command(WF_NAME, "step12_mdrun_nvt", "mdrun")
    )

    step13_grompp_npt = BashOperator(
        task_id="step13_grompp_npt",
        bash_command=create_bash_command(WF_NAME, "step13_grompp_npt", "grompp")
    )

    step14_mdrun_npt = BashOperator(
        task_id="step14_mdrun_npt",
        bash_command=create_bash_command(WF_NAME, "step14_mdrun_npt", "mdrun")
    )

    step15_grompp_md = BashOperator(
        task_id="step15_grompp_md",
        bash_command=create_bash_command(WF_NAME, "step15_grompp_md", "grompp")
    )

    step16_mdrun_md = BashOperator(
        task_id="step16_mdrun_md",
        bash_command=create_bash_command(WF_NAME, "step16_mdrun_md", "mdrun")
    )

    step17_gmx_image1 = BashOperator(
        task_id="step17_gmx_image1",
        bash_command=create_bash_command(WF_NAME, "step17_gmx_image1", "gmx_image")
    )

    step18_gmx_image2 = BashOperator(
        task_id="step18_gmx_image2",
        bash_command=create_bash_command(WF_NAME, "step18_gmx_image2", "gmx_image")
    )

    step19_gmx_trjconv_str = BashOperator(
        task_id="step19_gmx_trjconv_str",
        bash_command=create_bash_command(WF_NAME, "step19_gmx_trjconv_str", "gmx_trjconv_str")
    )

    step20_gmx_energy = BashOperator(
        task_id="step20_gmx_energy",
        bash_command=create_bash_command(WF_NAME, "step20_gmx_energy", "gmx_energy")
    )

    step21_gmx_rgyr = BashOperator(
        task_id="step21_gmx_rgyr",
        bash_command=create_bash_command(WF_NAME, "step21_gmx_rgyr", "gmx_rgyr")
    )

    step22_rmsd_first = BashOperator(
        task_id="step22_rmsd_first",
        bash_command=create_bash_command(WF_NAME, "step22_rmsd_first", "gmx_rms")
    )

    step23_rmsd_exp = BashOperator(
        task_id="step23_rmsd_exp",
        bash_command=create_bash_command(WF_NAME, "step23_rmsd_exp", "gmx_rms")
    )

    step24_grompp_md = BashOperator(
        task_id="step24_grompp_md",
        bash_command=create_bash_command(WF_NAME, "step24_grompp_md", "grompp")
    )

    step0_reduce_remove_hydrogens >> step1_extract_molecule >> step00_cat_pdb >> step2_fix_side_chain >> step4_pdb2gmx
    step4_pdb2gmx >> step5_editconf
    [step4_pdb2gmx, step5_editconf] >> step6_solvate
    step6_solvate >> step7_grompp_genion
    [step6_solvate, step7_grompp_genion] >> step8_genion
    step8_genion >> step9_grompp_min
    step9_grompp_min >> step10_mdrun_min
    step10_mdrun_min >> step100_make_ndx
    [step100_make_ndx, step10_mdrun_min, step8_genion] >> step11_grompp_nvt >> step12_mdrun_nvt
    [step100_make_ndx, step12_mdrun_nvt, step8_genion] >> step13_grompp_npt >> step14_mdrun_npt
    [step100_make_ndx, step14_mdrun_npt, step8_genion] >> step15_grompp_md
    step15_grompp_md >> step16_mdrun_md
    cross_downstream([step100_make_ndx, step16_mdrun_md, step9_grompp_min], [step17_gmx_image1, step19_gmx_trjconv_str])
    [step100_make_ndx, step17_gmx_image1, step9_grompp_min] >> step18_gmx_image2
    step16_mdrun_md >> step20_gmx_energy
    cross_downstream([step100_make_ndx, step15_grompp_md, step18_gmx_image2], [step21_gmx_rgyr, step22_rmsd_first])
    [step100_make_ndx, step18_gmx_image2, step9_grompp_min] >> step23_rmsd_exp
    [step16_mdrun_md, step8_genion] >> step24_grompp_md
