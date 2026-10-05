"""Step-by-step pytest for the DOCKER flavour of biobb_wf_amber_md_setup.

This reuses the exact same step functions as ``biobb_wf_amber_md_setup.py``
(the standard conda flavour); the only difference is the config passed via
``--config`` (``../../python/workflow.docker.yml``).

Unlike the conda flavour, every step runs inside a container: the AMBER
binaries (``tleap`` / ``sander`` / ``cpptraj`` / ``ambpdb``) come from the
conda-only ``ambertools`` package, which is not pip-installable, so there is no
host fallback. The split in that config mirrors the four biobb packages:
  * ``reduce_remove_hydrogens`` (step00) -> ``biobb_chemistry``.
  * ``extract_molecule`` (step0) / ``cat_pdb`` (step000) -> ``biobb_structure_utils``.
  * The AMBER prep / MD steps (``pdb4amber_run`` / ``leap_*`` / ``sander_mdrun`` /
    ``process_minout`` / ``process_mdout`` / ``amber_to_pdb``) -> ``biobb_amber``.
  * The trajectory-analysis steps (``cpptraj_rms`` / ``cpptraj_rgyr`` /
    ``cpptraj_image``) -> ``biobb_analysis``.
  * The ``leap_*`` steps run as root (``container_user_id: '0:0'``) because tleap
    writes ``leap.log`` to a root-only-writable install dir in the image.
  * The ``sander_mdrun`` steps declare ``sander.MPI`` / ``mpirun`` in the
    committed config, but ``run_container_test.sh`` strips those from the scratch
    config before running (the test venv resolves ``ambertools`` to a nompi
    build), so they run serially in the container.

Run it with the dedicated script (pip-installs the biobb packages from
``workflow.env.yml`` and starts the test):

    biobb_wf_amber_md_setup/tests/python/run_container_test.sh docker

or, if the environment + docker daemon are already ready, directly:

    pytest biobb_wf_amber_md_setup_docker.py --config ../../python/workflow.docker.yml --remove
"""
from biobb_wf_amber_md_setup import (  # noqa: F401
    test_step00_reduce_remove_hydrogens,
    test_step0_extract_molecule,
    test_step000_cat_pdb,
    test_step1_pdb4amber_run,
    test_step2_leap_gen_top,
    test_step3_sander_mdrun_minH,
    test_step4_process_minout_minH,
    test_step5_sander_mdrun_min,
    test_step6_process_minout_min,
    test_step7_amber_to_pdb,
    test_step8_leap_solvate,
    test_step9_leap_add_ions,
    test_step10_sander_mdrun_energy,
    test_step11_process_minout_energy,
    test_step12_sander_mdrun_warm,
    test_step13_process_mdout_warm,
    test_step14_sander_mdrun_nvt,
    test_step15_process_mdout_nvt,
    test_step16_sander_mdrun_npt,
    test_step17_process_mdout_npt,
    test_step18_sander_mdrun_md,
    test_step19_rmsd_first,
    test_step20_rmsd_exp,
    test_step21_cpptraj_rgyr,
    test_step22_cpptraj_image,
)
