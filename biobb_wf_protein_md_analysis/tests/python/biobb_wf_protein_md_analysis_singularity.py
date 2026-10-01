"""Step-by-step pytest for the SINGULARITY flavour of biobb_wf_protein_md_analysis.

This reuses the exact same step functions as ``biobb_wf_protein_md_analysis.py``
(the standard conda flavour); the only difference is the config passed via
``--config`` (``../../python/workflow.singularity.yml``). In that config every step
carries a ``container_image`` (a depot.galaxyproject.org singularity URL) +
``container_path: singularity``, so biobb runs the executables (cpptraj, gmx
cluster) inside a singularity container while the python biobb code runs natively
(pip-installed).

Note: biobb issues a ``singularity pull`` on every step (the image reference is a
URL, which never "exists" as a path). All 7 steps map to the same biobb_analysis
image, so they only download once because they share a ``SINGULARITY_CACHE`` — the
dedicated script exports a persistent ``SINGULARITY_CACHE`` and pre-pulls the
unique images.

Run it with the dedicated script (pip-installs the biobb packages from
``workflow.env.yml`` and warms the singularity cache):

    biobb_wf_protein_md_analysis/tests/python/run_container_test.sh singularity

or, if the environment + singularity are already ready, directly:

    pytest biobb_wf_protein_md_analysis_singularity.py \
        --config ../../python/workflow.singularity.yml --remove
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
