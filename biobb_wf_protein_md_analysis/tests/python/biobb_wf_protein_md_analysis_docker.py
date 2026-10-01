"""Step-by-step pytest for the DOCKER flavour of biobb_wf_protein_md_analysis.

This reuses the exact same step functions as ``biobb_wf_protein_md_analysis.py``
(the standard conda flavour); the only difference is the config passed via
``--config`` (``../../python/workflow.docker.yml``). In that config every step
carries a ``container_image`` (quay.io/biocontainers) + ``container_path: docker``,
so biobb runs the executables (cpptraj, gmx cluster) inside a docker container
while the python biobb code runs natively (pip-installed).

Run it with the dedicated script (pip-installs the biobb packages from
``workflow.env.yml`` and starts the test):

    biobb_wf_protein_md_analysis/tests/python/run_container_test.sh docker

or, if the environment + docker daemon are already ready, directly:

    pytest biobb_wf_protein_md_analysis_docker.py \
        --config ../../python/workflow.docker.yml --remove
"""
from biobb_wf_protein_md_analysis import (  # noqa: F401
    test_step1_cpptraj_average,
    test_step2_cpptraj_rms_first,
    test_step3_cpptraj_rms_average,
    test_step4_cpptraj_bfactor,
    test_step5_cpptraj_rgyr,
    test_step6_cpptraj_convert,
    test_step7_gmx_cluster,
)
