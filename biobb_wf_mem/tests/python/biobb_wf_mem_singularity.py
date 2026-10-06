"""Step-by-step pytest for the SINGULARITY flavour of biobb_wf_mem.

This reuses the exact same step functions as ``biobb_wf_mem.py`` (the standard
conda flavour); the only difference is the config passed via ``--config``
(``../../python/workflow.singularity.yml``). In that config the binary-launching
steps carry a ``container_image`` + ``container_path: singularity``, so biobb
runs the executables (gmx, fatslim, cpptraj) inside a singularity container while
the python biobb code runs natively (pip-installed).

The workflow is mixed, and the config mirrors the split:
  * ``gmx_image`` x2 (``biobb_analysis``) carries the singularity depot (depot.galaxyproject.org) ``biobb_gromacs``
    (it shells out to ``gmx trjconv``).
  * ``fatslim_membranes`` / ``fatslim_apl`` / ``cpptraj_density`` (``biobb_mem``)
    carry the singularity depot (depot.galaxyproject.org) ``biobb_mem`` (they shell out to ``fatslim`` / ``cpptraj``,
    both in that image).
  * The remaining steps (``lpp_assign_leaflets``, ``lpp_zpositions`` x2,
    ``gorder_aa``, ``mda_hole``, ``lpp_flip_flop``) are pure-Python MDAnalysis
    tools: they run natively in the venv, with NO container properties (with
    ``container_path`` set, biobb would point their file paths at the container
    volume ``/data``, which does not exist on the host).
  * ``gorder_aa`` needs the ``gorder`` package, which biobb_mem imports at
    module level but does not declare as a pip dependency (and which is not on
    PyPI): the ``run_container_test.sh`` script installs the conda-forge
    ``pygorder`` payload (a prebuilt wheel for the venv's python ABI) into the
    venv's site-packages.
  * ``mda_hole`` additionally shells out to the HOLE suite binaries (``hole``,
    ``sph_process``, ``sos_triangle``), which are conda-only: the
    ``run_container_test.sh`` script fetches + extracts the conda-forge
    ``hole2`` package (and its libgfortran5/libgcc-ng runtime) and puts it on
    PATH / LD_LIBRARY_PATH for the native run.

Run it with the dedicated script (pip-installs the biobb packages from
``workflow.env.yml`` and starts the test):

    biobb_wf_mem/tests/python/run_container_test.sh singularity

or, if the environment + singularity are already ready, directly:

    pytest biobb_wf_mem_singularity.py --config ../../python/workflow.singularity.yml --remove
"""
from biobb_wf_mem import (  # noqa: F401
    test_step1_gmx_image1,
    test_step2_gmx_image2,
    test_step3_fatslim_membranes,
    test_step4_lpp_assign_leaflets,
    test_step5_lpp_zpositions1,
    test_step6_lpp_zpositions2,
    test_step7_gorder_aa,
    test_step8_fatslim_apl,
    test_step9_cpptraj_density,
    test_step10_mda_hole,
    test_step11_lpp_flip_flop,
)
