"""Step-by-step pytest for the DOCKER flavour of biobb_wf_ligand_parameterization.

This reuses the exact same step functions as ``biobb_wf_ligand_parameterization.py``
(the standard conda flavour); the only difference is the config passed via
``--config`` (``../../python/workflow.docker.yml``). In that config every step
carries a ``container_image`` (quay.io/biocontainers) + ``container_path: docker``,
so biobb runs the executables (babel, acpype) inside a docker container while the
python biobb code runs natively (pip-installed).

Run it with the dedicated script (pip-installs the biobb packages from
``workflow.env.yml`` and starts the test):

    biobb_wf_ligand_parameterization/tests/python/run_container_test.sh docker

or, if the environment + docker daemon are already ready, directly:

    pytest biobb_wf_ligand_parameterization_docker.py \
        --config ../../python/workflow.docker.yml --remove
"""
from biobb_wf_ligand_parameterization import (  # noqa: F401
    test_step2_babel_minimize,
    test_step3_acpype_params_gmx,
)
