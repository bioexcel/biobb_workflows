"""Step-by-step pytest for the SINGULARITY flavour of biobb_wf_pmx_tutorial.

This reuses the step functions of ``biobb_wf_pmx_tutorial.py`` (the standard
conda flavour); the only difference is the config passed via ``--config``
(``../../python/workflow.singularity.yml``). In that config every gromacs step
(``trjconv``, ``pdb2gmx``, ``make_ndx``, ``grompp``, ``mdrun``) carries
``container_image`` + ``container_path: singularity`` — the ``biobb_gromacs``
image — so the gmx binaries run in a singularity container while the python
biobb code runs natively (pip-installed). The PMX steps stay native:
``pmx_mutate`` / ``pmx_gentop`` are pure python and ``pmx_analyse`` launches
the ``pmx`` console script of the ``pmx-biobb`` pip package (a
``biobb_pmx`` dependency, on the venv PATH).

The full 2-ensemble x 2-frame matrix is kept (44 test instances; stateA skips
its EM step in-test); what keeps this lane fast is the same MD shortening the
CI python flavour applies
(python-reusable.yaml seds ``nsteps`` to 50, the container runner seds it to
10 in its scratch config): the EM / equilibration mdp blocks and the PMX
thermodynamic-integration run (5000 lambda windows x 10 steps each) run for
10 steps instead of 10000/5000.

The custom PMX force field (amber99sb-star-ildn-mut) normally reaches gmx via
the ``GMXLIB`` env var, which the step tests build from ``$CONDA_PREFIX`` — a
host path that does not exist inside the container. GROMACS also detects
``<name>.ff`` directories in the working directory, so the
``_pmx_container_forcefield`` fixture in ``conftest.py`` (container flavours
only) copies the FF dir the topology references into the sandbox (the
container CWD) right after ``pdb2gmx`` / ``grompp`` staging.

``run_container_test.sh`` points ``CONDA_PREFIX`` at the venv (python 3.12,
required — the step tests hardcode
``$CONDA_PREFIX/lib/python3.12/site-packages/pmx/data/mutff/``): the venv
carries that tree via the ``pmx-biobb`` dependency of ``biobb_pmx``, which the
native ``pmx_mutate`` / ``pmx_gentop`` steps read as their ``gmx_lib``.

Run it with the dedicated script (pip-installs the biobb packages from
``workflow.env.yml`` and starts the test):

    biobb_wf_pmx_tutorial/tests/python/run_container_test.sh singularity

or, if the environment + singularity are already ready, directly:

    pytest biobb_wf_pmx_tutorial_singularity.py --config ../../python/workflow.singularity.yml --remove
"""
from biobb_wf_pmx_tutorial import (  # noqa: F401
    test_final_step,
    test_step0_trjconv,
    test_step1_pmx_mutate,
    test_step2_gmx_pdb2gmx,
    test_step3_pmx_gentop,
    test_step4_gmx_makendx,
    test_step5_gmx_grompp,
    test_step6_gmx_mdrun,
    test_step7_gmx_grompp,
    test_step8_gmx_mdrun,
    test_step9_gmx_grompp,
    test_step10_gmx_mdrun,
    test_step11_pmx_analyse,
)
