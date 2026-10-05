"""Step-by-step pytest for the DOCKER flavour of biobb_wf_amber_abc_setup.

This reuses the exact same step functions as ``biobb_wf_amber_abc_setup.py``
(the standard conda flavour); the only difference is the config passed via
``--config`` (``../../python/workflow.docker.yml``).

Unlike the conda flavour, every step runs inside a container: the AMBER
binaries (``tleap`` / ``sander`` / ``cpptraj`` / ``parmed``) come from the
conda-only ``ambertools`` package, which is not pip-installable, so there is no
host fallback. The split in that config mirrors the two biobb packages:
  * The AMBER setup / MD steps (steps 1-26: ``leap_*`` /
    ``cpptraj_randomize_ions`` / ``parmed_hmassrepartition`` / ``sander_mdrun`` /
    ``process_minout`` / ``process_mdout``) shell out to the Amber toolchain and
    carry ``biobb_amber`` (quay.io) + ``container_path: docker``.
  * The trajectory-analysis steps (steps 27-30: ``cpptraj_rms`` /
    ``cpptraj_rgyr`` / ``cpptraj_image``) carry ``biobb_analysis`` (quay.io) +
    ``container_path: docker``.
  * The ``leap_*`` steps run as root (``container_user_id: '0:0'``) because tleap
    writes ``leap.log`` to a root-only-writable install dir in the image.
  * The ``sander_mdrun`` steps declare ``sander.MPI`` / ``mpirun`` in the
    committed config, but ``run_container_test.sh`` strips those from the scratch
    config before running (the test venv resolves ``ambertools`` to a nompi
    build), so they run serially in the container.

Run it with the dedicated script (pip-installs the biobb packages from
``workflow.env.yml`` and starts the test):

    biobb_wf_amber_abc_setup/tests/python/run_container_test.sh docker

or, if the environment + docker daemon are already ready, directly:

    pytest biobb_wf_amber_abc_setup_docker.py --config ../../python/workflow.docker.yml --remove
"""
from biobb_wf_amber_abc_setup import (  # noqa: F401
    test_step1_leap_gen_top,
    test_step2_leap_solvate,
    test_step3_leap_add_ions,
    test_step4_cpptraj_randomize_ions,
    test_step5_parmed_hmassrepartition,
    test_step6_sander_mdrun_eq1,
    test_step7_process_minout_eq1,
    test_step8_sander_mdrun_eq2,
    test_step9_process_mdout_eq2,
    test_step10_sander_mdrun_eq3,
    test_step11_process_minout_eq3,
    test_step12_sander_mdrun_eq4,
    test_step13_process_minout_eq4,
    test_step14_sander_mdrun_eq5,
    test_step15_process_minout_eq5,
    test_step16_sander_mdrun_eq6,
    test_step17_process_mdout_eq6,
    test_step18_sander_mdrun_eq7,
    test_step19_process_mdout_eq7,
    test_step20_sander_mdrun_eq8,
    test_step21_process_mdout_eq8,
    test_step22_sander_mdrun_eq9,
    test_step23_process_mdout_eq9,
    test_step24_sander_mdrun_eq10,
    test_step26_sander_mdrun_md,
    test_step27_rmsd_first,
    test_step28_rmsd_exp,
    test_step29_cpptraj_rgyr,
    test_step30_cpptraj_image,
)
