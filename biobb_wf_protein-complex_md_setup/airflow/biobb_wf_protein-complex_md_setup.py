from airflow import DAG
from airflow.providers.standard.operators.bash import BashOperator
from datetime import datetime
from airflow.models.baseoperator import cross_downstream
from airflow_cwl_utils import create_bash_command

WF_NAME = "biobb_wf_protein-complex_md_setup"

with DAG(WF_NAME, start_date=datetime(2026, 1, 1), schedule=None) as dag:

    step0_reduce_remove_hydrogens = BashOperator(
        task_id="step0_reduce_remove_hydrogens",
        bash_command=create_bash_command(WF_NAME, "step0_reduce_remove_hydrogens", "reduce_remove_hydrogens")
    )

    step2_extract_molecule = BashOperator(
        task_id="step2_extract_molecule",
        bash_command=create_bash_command(WF_NAME, "step2_extract_molecule", "extract_molecule")
    )

    step00_cat_pdb = BashOperator(
        task_id="step00_cat_pdb",
        bash_command=create_bash_command(WF_NAME, "step00_cat_pdb", "cat_pdb")
    )

    step4_fix_side_chain = BashOperator(
        task_id="step4_fix_side_chain",
        bash_command=create_bash_command(WF_NAME, "step4_fix_side_chain", "fix_side_chain")
    )

    step5_pdb2gmx = BashOperator(
        task_id="step5_pdb2gmx",
        bash_command=create_bash_command(WF_NAME, "step5_pdb2gmx", "pdb2gmx")
    )

    step9_make_ndx = BashOperator(
        task_id="step9_make_ndx",
        bash_command=create_bash_command(WF_NAME, "step9_make_ndx", "make_ndx")
    )

    step10_genrestr = BashOperator(
        task_id="step10_genrestr",
        bash_command=create_bash_command(WF_NAME, "step10_genrestr", "genrestr")
    )

    step11_gmx_trjconv_str_protein = BashOperator(
        task_id="step11_gmx_trjconv_str_protein",
        bash_command=create_bash_command(WF_NAME, "step11_gmx_trjconv_str_protein", "gmx_trjconv_str")
    )

    step12_gmx_trjconv_str_ligand = BashOperator(
        task_id="step12_gmx_trjconv_str_ligand",
        bash_command=create_bash_command(WF_NAME, "step12_gmx_trjconv_str_ligand", "gmx_trjconv_str")
    )

    step13_cat_pdb_hydrogens = BashOperator(
        task_id="step13_cat_pdb_hydrogens",
        bash_command=create_bash_command(WF_NAME, "step13_cat_pdb_hydrogens", "cat_pdb")
    )

    step14_append_ligand = BashOperator(
        task_id="step14_append_ligand",
        bash_command=create_bash_command(WF_NAME, "step14_append_ligand", "append_ligand")
    )

    step15_editconf = BashOperator(
        task_id="step15_editconf",
        bash_command=create_bash_command(WF_NAME, "step15_editconf", "editconf")
    )

    step16_solvate = BashOperator(
        task_id="step16_solvate",
        bash_command=create_bash_command(WF_NAME, "step16_solvate", "solvate")
    )

    step17_grompp_genion = BashOperator(
        task_id="step17_grompp_genion",
        bash_command=create_bash_command(WF_NAME, "step17_grompp_genion", "grompp")
    )

    step18_genion = BashOperator(
        task_id="step18_genion",
        bash_command=create_bash_command(WF_NAME, "step18_genion", "genion")
    )

    step19_grompp_min = BashOperator(
        task_id="step19_grompp_min",
        bash_command=create_bash_command(WF_NAME, "step19_grompp_min", "grompp")
    )

    step20_mdrun_min = BashOperator(
        task_id="step20_mdrun_min",
        bash_command=create_bash_command(WF_NAME, "step20_mdrun_min", "mdrun")
    )

    step21_gmx_energy_min = BashOperator(
        task_id="step21_gmx_energy_min",
        bash_command=create_bash_command(WF_NAME, "step21_gmx_energy_min", "gmx_energy")
    )

    step22_make_ndx = BashOperator(
        task_id="step22_make_ndx",
        bash_command=create_bash_command(WF_NAME, "step22_make_ndx", "make_ndx")
    )

    step23_grompp_nvt = BashOperator(
        task_id="step23_grompp_nvt",
        bash_command=create_bash_command(WF_NAME, "step23_grompp_nvt", "grompp")
    )

    step24_mdrun_nvt = BashOperator(
        task_id="step24_mdrun_nvt",
        bash_command=create_bash_command(WF_NAME, "step24_mdrun_nvt", "mdrun")
    )

    step25_gmx_energy_nvt = BashOperator(
        task_id="step25_gmx_energy_nvt",
        bash_command=create_bash_command(WF_NAME, "step25_gmx_energy_nvt", "gmx_energy")
    )

    step26_grompp_npt = BashOperator(
        task_id="step26_grompp_npt",
        bash_command=create_bash_command(WF_NAME, "step26_grompp_npt", "grompp")
    )

    step27_mdrun_npt = BashOperator(
        task_id="step27_mdrun_npt",
        bash_command=create_bash_command(WF_NAME, "step27_mdrun_npt", "mdrun")
    )

    step28_gmx_energy_npt = BashOperator(
        task_id="step28_gmx_energy_npt",
        bash_command=create_bash_command(WF_NAME, "step28_gmx_energy_npt", "gmx_energy")
    )

    step29_grompp_md = BashOperator(
        task_id="step29_grompp_md",
        bash_command=create_bash_command(WF_NAME, "step29_grompp_md", "grompp")
    )

    step30_mdrun_md = BashOperator(
        task_id="step30_mdrun_md",
        bash_command=create_bash_command(WF_NAME, "step30_mdrun_md", "mdrun")
    )

    step34_gmx_image = BashOperator(
        task_id="step34_gmx_image",
        bash_command=create_bash_command(WF_NAME, "step34_gmx_image", "gmx_image")
    )

    step34b_gmx_image2 = BashOperator(
        task_id="step34b_gmx_image2",
        bash_command=create_bash_command(WF_NAME, "step34b_gmx_image2", "gmx_image")
    )

    step35_gmx_trjconv_str = BashOperator(
        task_id="step35_gmx_trjconv_str",
        bash_command=create_bash_command(WF_NAME, "step35_gmx_trjconv_str", "gmx_trjconv_str")
    )

    step31_rmsd_first = BashOperator(
        task_id="step31_rmsd_first",
        bash_command=create_bash_command(WF_NAME, "step31_rmsd_first", "gmx_rms")
    )

    step32_rmsd_exp = BashOperator(
        task_id="step32_rmsd_exp",
        bash_command=create_bash_command(WF_NAME, "step32_rmsd_exp", "gmx_rms")
    )

    step33_gmx_rgyr = BashOperator(
        task_id="step33_gmx_rgyr",
        bash_command=create_bash_command(WF_NAME, "step33_gmx_rgyr", "gmx_rgyr")
    )

    step36_grompp_md = BashOperator(
        task_id="step36_grompp_md",
        bash_command=create_bash_command(WF_NAME, "step36_grompp_md", "grompp")
    )

    step0_reduce_remove_hydrogens >> step2_extract_molecule >> step00_cat_pdb >> step4_fix_side_chain >> step5_pdb2gmx
    step9_make_ndx >> step10_genrestr
    step5_pdb2gmx >> step11_gmx_trjconv_str_protein
    [step11_gmx_trjconv_str_protein, step12_gmx_trjconv_str_ligand] >> step13_cat_pdb_hydrogens >> step15_editconf
    [step10_genrestr, step5_pdb2gmx] >> step14_append_ligand
    [step14_append_ligand, step15_editconf] >> step16_solvate
    step16_solvate >> step17_grompp_genion
    [step16_solvate, step17_grompp_genion] >> step18_genion
    step18_genion >> step19_grompp_min
    step19_grompp_min >> step20_mdrun_min
    step20_mdrun_min >> [step21_gmx_energy_min, step22_make_ndx]
    [step18_genion, step20_mdrun_min, step22_make_ndx] >> step23_grompp_nvt >> step24_mdrun_nvt
    step24_mdrun_nvt >> step25_gmx_energy_nvt
    [step18_genion, step22_make_ndx, step24_mdrun_nvt] >> step26_grompp_npt >> step27_mdrun_npt
    step27_mdrun_npt >> step28_gmx_energy_npt
    [step18_genion, step22_make_ndx, step27_mdrun_npt] >> step29_grompp_md
    step29_grompp_md >> step30_mdrun_md
    cross_downstream([step19_grompp_min, step22_make_ndx, step30_mdrun_md], [step34_gmx_image, step35_gmx_trjconv_str])
    [step19_grompp_min, step22_make_ndx, step34_gmx_image] >> step34b_gmx_image2
    cross_downstream([step22_make_ndx, step29_grompp_md, step34b_gmx_image2], [step31_rmsd_first, step33_gmx_rgyr])
    [step19_grompp_min, step22_make_ndx, step34b_gmx_image2] >> step32_rmsd_exp
    [step18_genion, step30_mdrun_md] >> step36_grompp_md
