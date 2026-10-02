"""Step-by-step pytest for the SINGULARITY flavour of biobb_wf_structure_checking.

This reuses the exact same step functions as ``biobb_wf_structure_checking.py``
(the standard conda flavour); the only difference is the config passed via
``--config`` (``../../python/workflow.singularity.yml``).

The workflow is mixed, and that config mirrors the split:
  * Most steps run natively on the host: the pure-Python ``biobb_structure_utils``
    + ``biobb_model`` tools (``extract_model`` / ``extract_chain`` /
    ``remove_molecules`` / ``remove_pdb_water`` / ``fix_*`` / ``fix_pdb``), and
    ``structure_check`` (step0 + step17) which shells out to the ``check_structure``
    console script. That one is pip-installed from ``workflow.env.yml`` — pinned to
    ``biobb_structure_checking==3.16.2``, the last release before 3.16.3's crashing
    sequence-mismatch check — and made resolvable by the ``run_container_test.sh``
    venv ``PATH`` fix.
  * ``reduce_remove_hydrogens`` (step7) shells out to OpenBabel and carries
    ``biobb_chemistry`` (depot) + ``container_path: singularity``.
  * ``leap_gen_top`` / ``sander_mdrun`` / ``amber_to_pdb`` (step13/14/15) shell out to
    the Amber toolchain (``leap`` / ``sander`` / ``cpptraj``) and carry
    ``biobb_amber`` (depot) + ``container_path: singularity``.

Run it with the dedicated script (pip-installs the biobb packages from
``workflow.env.yml`` and starts the test):

    biobb_wf_structure_checking/tests/python/run_container_test.sh singularity

or, if the environment + singularity are already ready, directly:

    pytest biobb_wf_structure_checking_singularity.py --config ../../python/workflow.singularity.yml --remove
"""
from biobb_wf_structure_checking import (  # noqa: F401
    test_step0_structure_check_init,
    test_step1_extract_model,
    test_step2_extract_chain,
    test_step3_fix_altlocs,
    test_step4_fix_ssbonds,
    test_step5_remove_molecules_ions,
    test_step6_remove_molecules_ligands,
    test_step7_reduce_remove_hydrogens,
    test_step8_remove_pdb_water,
    test_step9_fix_amides,
    test_step10_fix_chirality,
    test_step11_fix_side_chain,
    test_step12_fix_backbone,
    test_step13_leap_gen_top,
    test_step14_sander_mdrun,
    test_step15_amber_to_pdb,
    test_step16_fix_pdb,
    test_step17_structure_check,
)
