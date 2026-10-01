"""Step-by-step pytest for the SINGULARITY flavour of biobb_wf_ligand_parameterization.

This reuses the exact same step functions as ``biobb_wf_ligand_parameterization.py``
(the standard conda flavour); the only difference is the config passed via
``--config`` (``../../python/workflow.singularity.yml``). In that config every step
carries a ``container_image`` (a depot.galaxyproject.org singularity URL) +
``container_path: singularity``, so biobb runs the executables (babel, acpype) inside
a singularity container while the python biobb code runs natively (pip-installed).

Note: biobb issues a ``singularity pull`` on every step (the image reference is a
URL, which never "exists" as a path). The two steps here both map to the same
biobb_chemistry image, so they only download once because they share a
``SINGULARITY_CACHE`` — the dedicated script exports a persistent
``SINGULARITY_CACHE`` and pre-pulls the unique images.

Run it with the dedicated script (pip-installs the biobb packages from
``workflow.env.yml`` and warms the singularity cache):

    biobb_wf_ligand_parameterization/tests/python/run_container_test.sh singularity

or, if the environment + singularity are already ready, directly:

    pytest biobb_wf_ligand_parameterization_singularity.py \
        --config ../../python/workflow.singularity.yml --remove
"""
from biobb_wf_ligand_parameterization import (  # noqa: F401
    test_step2_babel_minimize,
    test_step3_acpype_params_gmx,
)
