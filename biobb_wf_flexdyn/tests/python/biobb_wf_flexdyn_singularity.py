"""Step-by-step pytest for the SINGULARITY flavour of biobb_wf_flexdyn.

This reuses the exact same step functions as ``biobb_wf_flexdyn.py`` (the
standard conda flavour); the only difference is the config passed via
``--config`` (``../../python/workflow.singularity.yml``). In that config every
step except ``extract_model``, ``extract_chain`` and ``prody_anm`` carries a
``container_image`` + ``container_path: singularity``, so biobb runs the
executables (cpptraj, concoord, NOLB, iMODS, bd/dmdgoopt/diaghess, pcasuite,
gmx) inside a singularity container while the python biobb code runs natively
(pip-installed).

The workflow is mixed, and the config mirrors the split:
  * ``cpptraj_mask`` / ``cpptraj_rms`` / ``cpptraj_convert``
    (``biobb_analysis``) carry the singularity depot (depot.galaxyproject.org) ``biobb_analysis`` - the conda
    env pins ``biobb_analysis==5.3.0=pyhdfd78af_1`` because only that build
    ships ambertools/cpptraj, so the matching image tag is used.
  * ``concoord_dist`` / ``concoord_disco`` (``dist``/``disco``), ``nolb_nma``
    (``NOLB``) and ``imod_imode`` / ``imod_imc`` (``imode_gcc``/``imc``)
    (``biobb_flexdyn``) carry the singularity depot (depot.galaxyproject.org) ``biobb_flexdyn``.
  * ``bd_run`` / ``dmd_run`` / ``nma_run`` (``biobb_flexserv``) and every
    ``pcz_*`` step carry the singularity depot (depot.galaxyproject.org) ``biobb_flexserv`` (the flexserv and
    pcasuite binaries: bd, dmdgoopt, diaghess, pcazip, pczdump).
  * ``trjcat`` / ``make_ndx`` / ``gmx_cluster`` carry the singularity depot (depot.galaxyproject.org)
    ``biobb_gromacs`` (the gmx binary; same image the md_setup container
    flavour uses for these tools).
  * ``extract_model`` / ``extract_chain`` run ``check_structure``, a
    pip-installed console_script (``biobb_structure_checking``) available on
    the venv PATH, and they read their model files back from a CWD-relative
    temp dir on the host, so they must stay native (no container properties).
  * ``prody_anm`` is pure Python (imports prody) and runs natively in the venv.

Notes on the concoord steps (``concoord_dist`` / ``concoord_disco``): the
tool copies the concoord data files (HBONDS.DAT, ATOMS_*.DAT, ...) from
``$CONCOORDLIB`` on the HOST into the (container-mounted) working dir, and the
test builds the container-side ``CONCOORDLIB`` from ``$CONDA_PREFIX``
(= the container's conda env, /opt/conda in the biobb_flexdyn image).
``run_container_test.sh`` therefore fetches the exact concoord build the
image pins (2.1.2=h9ee0642_4, from bioconda) into a scratch prefix, exports
``CONCOORDLIB`` pointing at it, and exports ``CONDA_PREFIX=/opt/conda``.

Note: ``run_container_test.sh`` strips the conda build pin from
``biobb_analysis==5.3.0=pyhdfd78af_1`` when building the pip requirements
(pip cannot parse conda build strings).

Run it with the dedicated script (pip-installs the biobb packages from
``workflow.env.yml`` and starts the test):

    biobb_wf_flexdyn/tests/python/run_container_test.sh singularity

or, if the environment + singularity are already ready, directly:

    pytest biobb_wf_flexdyn_singularity.py --config ../../python/workflow.singularity.yml --remove
"""
from biobb_wf_flexdyn import (  # noqa: F401
    test_step0_extract_model,
    test_step1_extract_chain,
    test_step2_cpptraj_mask,
    test_step3_cpptraj_mask,
    test_step4_concoord_dist,
    test_step5_concoord_disco,
    test_step6_cpptraj_rms,
    test_step7_cpptraj_convert,
    test_step8_prody_anm,
    test_step9_cpptraj_rms,
    test_step10_cpptraj_convert,
    test_step11_bd_run,
    test_step12_cpptraj_rms,
    test_step13_dmd_run,
    test_step14_cpptraj_rms,
    test_step15_nma_run,
    test_step16_cpptraj_rms,
    test_step17_cpptraj_convert,
    test_step18_nolb_nma,
    test_step19_cpptraj_rms,
    test_step20_cpptraj_convert,
    test_step21_imod_imode,
    test_step22_imod_imc,
    test_step23_cpptraj_rms,
    test_step24_cpptraj_convert,
    test_step25_trjcat,
    test_step26_make_ndx,
    test_step27_gmx_cluster,
    test_step28_cpptraj_rms,
    test_step29_pcz_zip,
    test_step30_pcz_zip,
    test_step31_pcz_info,
    test_step32_pcz_evecs,
    test_step33_pcz_animate,
    test_step34_cpptraj_convert,
    test_step35_pcz_bfactor,
    test_step36_pcz_hinges,
    test_step37_pcz_hinges,
    test_step38_pcz_hinges,
    test_step39_pcz_stiffness,
    test_step40_pcz_collectivity,
)
