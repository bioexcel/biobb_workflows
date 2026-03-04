from airflow import DAG
from airflow.providers.standard.operators.bash import BashOperator
from datetime import datetime
from airflow.models.baseoperator import cross_downstream
from airflow_cwl_utils import create_bash_command

WF_NAME = "biobb_wf_md_setup_mutations"
MUTATIONS = ["A:Gly4Lys", "A:Leu8Met", "A:Tyr20Gln"]

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

    step0_reduce_remove_hydrogens >> step1_extract_molecule >> step00_cat_pdb >> step2_fix_side_chain

    for mutation in MUTATIONS:

        step3_mutate = BashOperator(
            task_id=f"step3_mutate_{mutation.replace(':', '_')}",
            bash_command=create_bash_command(WF_NAME, "step3_mutate", "mutate", mutation=mutation)
        )

        step4_pdb2gmx = BashOperator(
            task_id=f"step4_pdb2gmx_{mutation.replace(':', '_')}",
            bash_command=create_bash_command(WF_NAME, "step4_pdb2gmx", "pdb2gmx", mutation=mutation)
        )

        step5_editconf = BashOperator(
            task_id=f"step5_editconf_{mutation.replace(':', '_')}",
            bash_command=create_bash_command(WF_NAME, "step5_editconf", "editconf", mutation=mutation)
        )

        step6_solvate = BashOperator(
            task_id=f"step6_solvate_{mutation.replace(':', '_')}",
            bash_command=create_bash_command(WF_NAME, "step6_solvate", "solvate", mutation=mutation)
        )

        step7_grompp_genion = BashOperator(
            task_id=f"step7_grompp_genion_{mutation.replace(':', '_')}",
            bash_command=create_bash_command(WF_NAME, "step7_grompp_genion", "grompp", mutation=mutation)
        )

        step8_genion = BashOperator(
            task_id=f"step8_genion_{mutation.replace(':', '_')}",
            bash_command=create_bash_command(WF_NAME, "step8_genion", "genion", mutation=mutation)
        )

        step9_grompp_min = BashOperator(
            task_id=f"step9_grompp_min_{mutation.replace(':', '_')}",
            bash_command=create_bash_command(WF_NAME, "step9_grompp_min", "grompp", mutation=mutation)
        )

        step10_mdrun_min = BashOperator(
            task_id=f"step10_mdrun_min_{mutation.replace(':', '_')}",
            bash_command=create_bash_command(WF_NAME, "step10_mdrun_min", "mdrun", mutation=mutation)
        )

        step100_make_ndx = BashOperator(
            task_id=f"step100_make_ndx_{mutation.replace(':', '_')}",
            bash_command=create_bash_command(WF_NAME, "step100_make_ndx", "make_ndx", mutation=mutation)
        )

        step11_grompp_nvt = BashOperator(
            task_id=f"step11_grompp_nvt_{mutation.replace(':', '_')}",
            bash_command=create_bash_command(WF_NAME, "step11_grompp_nvt", "grompp", mutation=mutation)
        )

        step12_mdrun_nvt = BashOperator(
            task_id=f"step12_mdrun_nvt_{mutation.replace(':', '_')}",
            bash_command=create_bash_command(WF_NAME, "step12_mdrun_nvt", "mdrun", mutation=mutation)
        )

        step13_grompp_npt = BashOperator(
            task_id=f"step13_grompp_npt_{mutation.replace(':', '_')}",
            bash_command=create_bash_command(WF_NAME, "step13_grompp_npt", "grompp", mutation=mutation)
        )

        step14_mdrun_npt = BashOperator(
            task_id=f"step14_mdrun_npt_{mutation.replace(':', '_')}",
            bash_command=create_bash_command(WF_NAME, "step14_mdrun_npt", "mdrun", mutation=mutation)
        )

        step15_grompp_md = BashOperator(
            task_id=f"step15_grompp_md_{mutation.replace(':', '_')}",
            bash_command=create_bash_command(WF_NAME, "step15_grompp_md", "grompp", mutation=mutation)
        )

        step16_mdrun_md = BashOperator(
            task_id=f"step16_mdrun_md_{mutation.replace(':', '_')}",
            bash_command=create_bash_command(WF_NAME, "step16_mdrun_md", "mdrun", mutation=mutation)
        )

        step17_gmx_image1 = BashOperator(
            task_id=f"step17_gmx_image1_{mutation.replace(':', '_')}",
            bash_command=create_bash_command(WF_NAME, "step17_gmx_image1", "gmx_image", mutation=mutation)
        )

        step18_gmx_image2 = BashOperator(
            task_id=f"step18_gmx_image2_{mutation.replace(':', '_')}",
            bash_command=create_bash_command(WF_NAME, "step18_gmx_image2", "gmx_image", mutation=mutation)
        )

        step19_gmx_trjconv_str = BashOperator(
            task_id=f"step19_gmx_trjconv_str_{mutation.replace(':', '_')}",
            bash_command=create_bash_command(WF_NAME, "step19_gmx_trjconv_str", "gmx_trjconv_str", mutation=mutation)
        )

        step20_gmx_energy = BashOperator(
            task_id=f"step20_gmx_energy_{mutation.replace(':', '_')}",
            bash_command=create_bash_command(WF_NAME, "step20_gmx_energy", "gmx_energy", mutation=mutation)
        )

        step21_gmx_rgyr = BashOperator(
            task_id=f"step21_gmx_rgyr_{mutation.replace(':', '_')}",
            bash_command=create_bash_command(WF_NAME, "step21_gmx_rgyr", "gmx_rgyr", mutation=mutation)
        )

        step22_rmsd_first = BashOperator(
            task_id=f"step22_rmsd_first_{mutation.replace(':', '_')}",
            bash_command=create_bash_command(WF_NAME, "step22_rmsd_first", "gmx_rms", mutation=mutation)
        )

        step23_rmsd_exp = BashOperator(
            task_id=f"step23_rmsd_exp_{mutation.replace(':', '_')}",
            bash_command=create_bash_command(WF_NAME, "step23_rmsd_exp", "gmx_rms", mutation=mutation)
        )

        step24_grompp_md = BashOperator(
            task_id=f"step24_grompp_md_{mutation.replace(':', '_')}",
            bash_command=create_bash_command(WF_NAME, "step24_grompp_md", "grompp", mutation=mutation)
        )

        step2_fix_side_chain >> step3_mutate >> step4_pdb2gmx
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
