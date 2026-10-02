"""Step-by-step pytest for the DOCKER flavour of biobb_wf_autoencoder.

This reuses the exact same step functions as ``biobb_wf_autoencoder.py`` (the
standard conda flavour); the only difference is the config passed via ``--config``
(``../../python/workflow.docker.yml``).

The workflow is mixed, and that config mirrors the split:
  * the GROMACS steps (``gmx_image``, ``make_ndx``, ``gmx_rmsf``) carry a
    ``container_image`` (quay.io/biocontainers) + ``container_path: docker``. They run
    the ``gmx`` binary inside a docker container — the pip-installed venv has no
    ``gmx`` executable, only the python biobb wrappers.
  * the biobb_pytorch MDAE steps (``mdfeaturizer``, ``build_model``, ``train_model``,
    ``evaluate_model``, ``feat2traj``, ``make_plumed``) are pure-Python (torch /
    mdtraj / numpy) and run natively on the host, so they carry NO container
    properties (the venv already has torch / lightning / mlcolvar / mdtraj).

Run it with the dedicated script (pip-installs the biobb packages from
``workflow.env.yml`` and starts the test):

    biobb_wf_autoencoder/tests/python/run_container_test.sh docker

or, if the environment + docker daemon are already ready, directly:

    pytest biobb_wf_autoencoder_docker.py \
        --config ../../python/workflow.docker.yml --remove
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
