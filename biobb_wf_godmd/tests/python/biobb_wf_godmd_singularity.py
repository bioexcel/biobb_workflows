"""Step-by-step pytest for the SINGULARITY flavour of biobb_wf_godmd.

This reuses the exact same step functions as ``biobb_wf_godmd.py`` (the standard
conda flavour); the only difference is the config passed via ``--config``
(``../../python/workflow.singularity.yml``).

The workflow is mixed, and that config mirrors the split:
  * ``extract_chain`` (x2) + ``remove_molecules`` (x2) are pure-Python
    (``biobb_structure_utils``) and run natively on the host — no container.
  * ``godmd_prep`` + ``godmd_run`` shell out to the GOdMD toolchain
    (``water`` / ``discrete``) via ``run_biobb`` and carry a ``container_image``
    (a depot.galaxyproject.org biobb_godmd singularity URL) +
    ``container_path: singularity`` — the pip venv has the python wrappers but not
    those binaries.
  * ``cpptraj_convert`` runs the AMBER ``cpptraj`` binary and carries
    ``biobb_analysis`` (depot.galaxyproject.org) + ``container_path: singularity``.

Note: biobb issues a ``singularity pull`` on every container step (an image URL never
"exists" as a path) with a mangled target name the registry rejects. The dedicated
script pre-pulls each unique image to a local ``.sif`` and rewrites the scratch
config's ``container_image`` to that local path, so biobb skips its own failing pull.

Run it with the dedicated script (pip-installs the biobb packages from
``workflow.env.yml`` and warms the singularity cache):

    biobb_wf_godmd/tests/python/run_container_test.sh singularity

or, if the environment + singularity are already ready, directly:

    pytest biobb_wf_godmd_singularity.py \
        --config ../../python/workflow.singularity.yml --remove
"""
from biobb_wf_godmd import (  # noqa: F401
    test_step0_extract_chain,
    test_step1_extract_chain,
    test_step2_remove_molecules,
    test_step4_godmd_prep,
    test_step5_godmd_run,
    test_step6_cpptraj_convert,
)
