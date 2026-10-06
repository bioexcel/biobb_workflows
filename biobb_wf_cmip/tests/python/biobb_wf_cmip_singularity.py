"""Step-by-step pytest for the SINGULARITY flavour of biobb_wf_cmip (reduced run).

This reuses the step functions of ``biobb_wf_cmip.py`` (the standard conda
flavour); the only difference is the config passed via ``--config``
(``../../python/workflow.singularity.yml``). In that config every step that
launches an executable carries a ``container_image`` + ``container_path:
singularity``, so biobb runs the binaries (PDB2PQR, acpype, tleap, sander,
ambpdb, cmip) inside a singularity container while the python biobb code runs
natively (pip-installed).

REDUCED RUN - the heavy MIP grid steps are NOT in this test module (see
``tests/python/SKIP``): ``cmip_titration`` and the ``cmip_run`` MIP /
pb_interaction_energy runs (mip_pos/mip_neg/mip_neu on steps 3/4/5,
interaction energies on steps 16/24/26) allocate ~25 GiB in sander and fail
on the 7 GiB GH-hosted runner - the same reason this workflow's python CI
test and the docker/cwl/airflow e2e are opted out. So the heavy steps
(1, 3, 4, 5, 16, 24, 26) and step2 (it consumes step1's output) are not in
this module. The ``check_only`` cmip_run steps (20/21/22, dry run / box
determination only) are memory-light and stay in.

The config mirrors the split:
  * ``cmip_titration`` / ``cmip_run`` carry the singularity depot (depot.galaxyproject.org) ``biobb_cmip``
    (the cmip / titration binaries).
  * ``reduce_add_hydrogens`` (PDB2PQR) / ``acpype_params_ac`` (acpype) carry
    the singularity depot (depot.galaxyproject.org) ``biobb_chemistry``.
  * ``leap_gen_top`` (tleap) / ``sander_mdrun`` (sander) / ``amber_to_pdb``
    (ambpdb) carry the singularity depot (depot.galaxyproject.org) ``biobb_amber``. ``sander_mdrun`` drops the
    ``sander.MPI`` / ``mpi_np`` / ``mpi_bin`` properties of the standard
    config (no mpirun in the 5.3.x envs - the CWL/airflow flavours strip
    them the same way), so the plain ``sander`` binary of the image is used.
  * Native (no container properties): ``cmip_prepare_pdb`` and
    ``extract_chain`` run ``check_structure`` (a pip-installed console_script
    of ``biobb_structure_checking``, on the venv PATH), and ``cat_pdb`` /
    ``remove_pdb_water`` / ``extract_heteroatoms`` / ``remove_ligand`` /
    ``cmip_prepare_structure`` / ``cmip_ignore_residues`` are pure Python.

Note on the cmip steps: ``cmip_run`` / ``cmip_titration`` default
``input_vdw_params_path`` to ``$CONDA_PREFIX/share/cmip/dat/vdwprm`` and stage
that file from the HOST, so ``run_container_test.sh`` fetches the cmip conda
package (2.7.0, from bioconda) into a scratch prefix and exports
``CONDA_PREFIX`` pointing at it.

Run it with the dedicated script (pip-installs the biobb packages from
``workflow.env.yml`` and starts the test):

    biobb_wf_cmip/tests/python/run_container_test.sh singularity

or, if the environment + singularity are already ready, directly:

    pytest biobb_wf_cmip_singularity.py --config ../../python/workflow.singularity.yml --remove
"""
from biobb_wf_cmip import (  # noqa: F401
    test_step0_cmip_prepare_pdb,
    test_step6_remove_pdb_water,
    test_step7_extract_heteroatoms,
    test_step8_reduce_add_hydrogens,
    test_step9_acpype_params_ac,
    test_step10_leap_gen_top,
    test_step11_sander_mdrun,
    test_step12_amber_to_pdb,
    test_step13_cmip_prepare_structure,
    test_step14_remove_ligand,
    test_step15_cmip_ignore_residues,
    test_step17_cmip_prepare_structure,
    test_step18_extract_chain_a,
    test_step19_extract_chain_b,
    test_step20_cmip_run_rbd,
    test_step21_cmip_run_hace2,
    test_step22_cmip_run_rbd_hace2,
    test_step23_cmip_ignore_residues_rbd,
    test_step25_cmip_ignore_residues_hace2,
)
