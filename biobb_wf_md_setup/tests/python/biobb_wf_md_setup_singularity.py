"""Step-by-step pytest for the SINGULARITY flavour of biobb_wf_md_setup.

This reuses the exact same step functions as ``biobb_wf_md_setup.py`` (the
standard conda flavour); the only difference is the config passed via
``--config`` (``../../python/workflow.singularity.yml``). In that config every
step carries a ``container_image`` (a depot.galaxyproject.org singularity URL)
+ ``container_path: singularity``, so biobb runs the executables (reduce, gmx,
...) inside a singularity container while the python biobb code runs natively
(pip-installed).

Note: biobb issues a ``singularity pull`` on every step (the image reference is
a URL, which never "exists" as a path), naming the pulled file after the URL.
All 22 ``biobb_gromacs`` steps therefore resolve to the SAME image. They only
download once because they share a ``SINGULARITY_CACHE`` — the dedicated script
exports a persistent ``SINGULARITY_CACHE`` and pre-pulls the unique images so
each package is fetched a single time, not once per step.

Run it with the dedicated script (pip-installs the biobb packages from
``workflow.env.yml`` and warms the singularity cache):

    biobb_wf_md_setup/tests/python/run_container_test.sh singularity

or, if the environment + singularity are already ready, directly:

    pytest biobb_wf_md_setup_singularity.py \
        --config ../../python/workflow.singularity.yml --remove
"""
from biobb_wf_md_setup import (  # noqa: F401
    test_step0_reduce_remove_hydrogens,
    test_step1_extract_molecule,
    test_step00_cat_pdb,
    test_step2_fix_side_chain,
    test_step4_pdb2gmx,
    test_step5_editconf,
    test_step6_solvate,
    test_step7_grompp_genion,
    test_step8_genion,
    test_step9_grompp_min,
    test_step10_mdrun_min,
    test_step100_make_ndx,
    test_step11_grompp_nvt,
    test_step12_mdrun_nvt,
    test_step13_grompp_npt,
    test_step14_mdrun_npt,
    test_step15_grompp_md,
    test_step16_mdrun_md,
    test_step17_gmx_image1,
    test_step18_gmx_image2,
    test_step19_gmx_trjconv_str,
    test_step20_gmx_energy,
    test_step22_rmsd_first,
    test_step23_rmsd_exp,
)
