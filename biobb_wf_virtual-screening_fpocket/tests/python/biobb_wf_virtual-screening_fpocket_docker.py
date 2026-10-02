"""Step-by-step pytest for the DOCKER flavour of biobb_wf_virtual-screening_fpocket.

This reuses the exact same step functions as ``biobb_wf_virtual-screening_fpocket.py``
(the standard conda flavour); the only difference is the config passed via
``--config`` (``../../python/workflow.docker.yml``).

The standard test module's file name contains a hyphen (not a valid Python
identifier), so it cannot be imported normally; it is loaded from its file path
with ``importlib`` and its test functions re-exported here.

The workflow is mixed, and that config mirrors the split:
  * ``fpocket_select`` + ``box`` are pure-Python (``biobb_vs``) and run natively
    on the host — no container.
  * ``str_check_add_hydrogens`` (``biobb_structure_utils``) is a host step; it
    shells out to the ``check_structure`` console script, which the
    ``run_container_test.sh`` venv ``PATH`` fix makes resolvable.
  * ``babel_convert`` (x2) shells out to the OpenBabel ``obabel`` binary and
    carries ``biobb_chemistry`` (quay.io) + ``container_path: docker``.
  * ``autodock_vina_run`` shells out to the AutoDock Vina ``vina`` binary and
    carries ``biobb_vs`` (quay.io) + ``container_path: docker`` (Vina is not
    compiled for Apple Silicon, so it must run in a container).

Run it with the dedicated script (pip-installs the biobb packages from
``workflow.env.yml`` and starts the test):

    biobb_wf_virtual-screening_fpocket/tests/python/run_container_test.sh docker

or, if the environment + docker daemon are already ready, directly:

    pytest biobb_wf_virtual-screening_fpocket_docker.py --config ../../python/workflow.docker.yml --remove
"""
import importlib.util
import os

_spec = importlib.util.spec_from_file_location(
    "biobb_wf_virtual_screening_fpocket",
    os.path.join(os.path.dirname(__file__), "biobb_wf_virtual-screening_fpocket.py"),
)
_std = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(_std)

test_step1_fpocket_select = _std.test_step1_fpocket_select
test_step2_box = _std.test_step2_box
test_step3_babel_convert_prep_lig = _std.test_step3_babel_convert_prep_lig
test_step4_str_check_add_hydrogens = _std.test_step4_str_check_add_hydrogens
test_step5_autodock_vina_run = _std.test_step5_autodock_vina_run
test_step6_babel_convert_pose_pdb = _std.test_step6_babel_convert_pose_pdb
