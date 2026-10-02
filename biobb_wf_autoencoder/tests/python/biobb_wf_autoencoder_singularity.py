"""Step-by-step pytest for the SINGULARITY flavour of biobb_wf_autoencoder.

This reuses the exact same step functions as ``biobb_wf_autoencoder.py`` (the
standard conda flavour); the only difference is the config passed via ``--config``
(``../../python/workflow.singularity.yml``).

The workflow is mixed, and that config mirrors the split:
  * the GROMACS steps (``gmx_image``, ``make_ndx``, ``gmx_rmsf``) carry a
    ``container_image`` (a depot.galaxyproject.org singularity URL) +
    ``container_path: singularity``. They run the ``gmx`` binary inside a singularity
    container — the pip-installed venv has no ``gmx`` executable, only the python
    biobb wrappers.
  * the biobb_pytorch MDAE steps (``mdfeaturizer``, ``build_model``, ``train_model``,
    ``evaluate_model``, ``feat2traj``, ``make_plumed``) are pure-Python (torch /
    mdtraj / numpy) and run natively on the host, so they carry NO container
    properties (the venv already has torch / lightning / mlcolvar / mdtraj).

Note: biobb issues a ``singularity pull`` on every container step (an image URL never
"exists" as a path) with a mangled target name the registry rejects. The dedicated
script pre-pulls each unique image to a local ``.sif`` and rewrites the scratch
config's ``container_image`` to that local path, so biobb skips its own failing pull.

Run it with the dedicated script (pip-installs the biobb packages from
``workflow.env.yml`` and warms the singularity cache):

    biobb_wf_autoencoder/tests/python/run_container_test.sh singularity

or, if the environment + singularity are already ready, directly:

    pytest biobb_wf_autoencoder_singularity.py \
        --config ../../python/workflow.singularity.yml --remove
"""
from biobb_wf_autoencoder import (  # noqa: F401
    test_step1_gmx_image1,
    test_step2_mdfeaturizer1,
    test_step3_build_model,
    test_step4_train_model,
    test_step5_gmx_image2,
    test_step6_mdfeaturizer2,
    test_step7_evaluate_model,
    test_step8_make_ndx1,
    test_step9_make_ndx2,
    test_step10_gmx_rmsf1,
    test_step11_gmx_rmsf2,
    test_step12_feat2traj,
    test_step13_gmx_rmsf3,
    test_step14_make_plumed,
)
