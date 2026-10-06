"""Step-by-step pytest for the SINGULARITY flavour of biobb_wf_flexserv.

This reuses the exact same step functions as ``biobb_wf_flexserv.py`` (the
standard conda flavour); the only difference is the config passed via
``--config`` (``../../python/workflow.singularity.yml``). In that config every
step except ``extract_atoms`` carries a ``container_image`` +
``container_path: singularity``, so biobb runs the executables (bd, dmdgoopt,
diaghess, pczip/pcasuite, cpptraj) inside a singularity container while the
python biobb code runs natively (pip-installed).

The workflow is mixed, and the config mirrors the split:
  * ``bd_run`` / ``dmd_run`` / ``nma_run`` (``biobb_flexserv``) and every
    ``pcz_*`` step carry the singularity depot (depot.galaxyproject.org) ``biobb_flexserv`` (the flexserv and
    pcasuite binaries: bd, dmdgoopt, diaghess, pcazip, pcaunzip, pczdump).
  * ``cpptraj_rms`` / ``cpptraj_convert`` (``biobb_analysis``) carry
    the singularity depot (depot.galaxyproject.org) ``biobb_analysis`` - the conda env pins
    ``biobb_analysis==5.3.0=pyhdfd78af_1`` because only that build ships
    ambertools/cpptraj, so the matching image tag is used.
  * ``extract_atoms`` (``biobb_structure_utils``) is pure Python: it runs
    natively in the venv, with NO container properties (with
    ``container_path`` set, biobb would point its file paths at the container
    volume ``/data``, which does not exist on the host).

Note: ``run_container_test.sh`` strips the conda build pin from
``biobb_analysis==5.3.0=pyhdfd78af_1`` when building the pip requirements
(pip cannot parse conda build strings) and adds ``numpy`` (imported by
``pcz_similarity`` but not declared by biobb_flexserv's pip metadata).

Run it with the dedicated script (pip-installs the biobb packages from
``workflow.env.yml`` and starts the test):

    biobb_wf_flexserv/tests/python/run_container_test.sh singularity

or, if the environment + singularity are already ready, directly:

    pytest biobb_wf_flexserv_singularity.py --config ../../python/workflow.singularity.yml --remove
"""
from biobb_wf_flexserv import (  # noqa: F401
    test_step0_extract_atoms,
    test_step1_bd_run,
    test_step2_cpptraj_rms,
    test_step3_dmd_run,
    test_step4_cpptraj_rms,
    test_step5_nma_run,
    test_step6_cpptraj_rms,
    test_step7_pcz_zip,
    test_step8_pcz_zip,
    test_step9_pcz_zip,
    test_step10_pcz_unzip,
    test_step11_pcz_unzip,
    test_step12_pcz_unzip,
    test_step13_cpptraj_rms,
    test_step14_cpptraj_rms,
    test_step15_cpptraj_rms,
    test_step16_pcz_info,
    test_step17_pcz_evecs,
    test_step18_pcz_animate,
    test_step19_cpptraj_convert,
    test_step20_pcz_bfactor,
    test_step21_pcz_hinges,
    test_step22_pcz_hinges,
    test_step23_pcz_hinges,
    test_step24_pcz_stiffness,
    test_step25_pcz_collectivity,
    test_step26_pcz_similarity,
    test_step27_pcz_similarity,
    test_step28_pcz_similarity,
)
