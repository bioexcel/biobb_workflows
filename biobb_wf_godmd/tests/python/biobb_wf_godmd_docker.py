"""Step-by-step pytest for the DOCKER flavour of biobb_wf_godmd.

This reuses the exact same step functions as ``biobb_wf_godmd.py`` (the standard
conda flavour); the only difference is the config passed via ``--config``
(``../../python/workflow.docker.yml``).

The workflow is mixed, and that config mirrors the split:
  * ``extract_chain`` (x2) + ``remove_molecules`` (x2) are pure-Python
    (``biobb_structure_utils``) and run natively on the host — no container.
  * ``godmd_prep`` + ``godmd_run`` shell out to the GOdMD toolchain
    (``water`` / ``discrete``) via ``run_biobb`` and carry a ``container_image``
    (quay.io/biocontainers/biobb_godmd) + ``container_path: docker`` — the pip venv
    has the python wrappers but not those binaries.
  * ``cpptraj_convert`` runs the AMBER ``cpptraj`` binary and carries
    ``biobb_analysis`` (quay.io) + ``container_path: docker``.

Run it with the dedicated script (pip-installs the biobb packages from
``workflow.env.yml`` and starts the test):

    biobb_wf_godmd/tests/python/run_container_test.sh docker

or, if the environment + docker daemon are already ready, directly:

    pytest biobb_wf_godmd_docker.py --config ../../python/workflow.docker.yml --remove
"""
from biobb_wf_godmd import (  # noqa: F401
    test_step0_extract_chain,
    test_step1_extract_chain,
    test_step2_remove_molecules,
    test_step4_godmd_prep,
    test_step5_godmd_run,
    test_step6_cpptraj_convert,
)
