"""Step-by-step pytest for the DOCKER flavour of biobb_wf_protein-complex_md_setup.

This reuses the exact same step functions as ``biobb_wf_protein-complex_md_setup.py``
(the standard conda flavour); the only difference is the config passed via
``--config`` (``../../python/workflow.docker.yml``).

The standard test module's file name contains a hyphen (not a valid Python
identifier), so it cannot be imported normally; it is loaded from its file path
with ``importlib`` and its test functions re-exported here.

The workflow is mixed, and that config mirrors the split:
  * ``reduce_remove_hydrogens`` (``biobb_chemistry``) carries quay.io +
    ``container_path: docker``.
  * ``fix_side_chain`` (``biobb_model``) carries quay.io + ``container_path: docker``.
  * ``extract_molecule`` (``biobb_structure_utils``) is a host step; it shells out
    to the ``check_structure`` console script (``binary_path: check_structure``),
    which the ``run_container_test.sh`` venv ``PATH`` fix makes resolvable.
  * ``cat_pdb`` (``biobb_structure_utils``, x2) is pure-Python and runs natively - no container.
  * Every GROMACS step (``biobb_gromacs`` / ``biobb_analysis``) carries quay.io
    ``biobb_gromacs`` + ``container_path: docker``.

Note: the three ``grompp`` production steps use ``tc-grps: Protein non-Protein``
here (instead of the conda flavour's ``Protein_Other Water_and_ions``) to work
around a biobb_gromacs container bug - in container mode ``grompp`` drops the
``-n <index>`` flag (it guards it with ``Path(<container_volume>/...).exists()``,
False on the host), so the custom ``Protein_Other`` tc-group cannot resolve.
``non-Protein`` is a default group, so no index file is needed. The
``Protein_Other`` index group is still built by ``make_ndx`` and used by the
post-processing steps (``gmx_rms``/``gmx_rgyr``/``gmx_image``/``gmx_trjconv_str``),
which pass ``-n`` correctly.

Note: the NPT / production-MD ``grompp`` steps override ``pcoupl: Berendsen``
here (instead of the preset's ``Parrinello-Rahman, tau-p=1.0``). At the fast
10-step test length this protein+ligand system is under-equilibrated, so the
noisy Parrinello-Rahman coupling makes the NPT/MD ``mdrun`` blow up (LINCS
deviation -> segfault, exit -11). The noiseless Berendsen coupling keeps the
short run stable (physics is irrelevant for a 10-step pipeline test).

Run it with the dedicated script (pip-installs the biobb packages from
``workflow.env.yml`` and starts the test):

    biobb_wf_protein-complex_md_setup/tests/python/run_container_test.sh docker

or, if the environment + docker are already ready, directly:

    pytest biobb_wf_protein-complex_md_setup_docker.py --config ../../python/workflow.docker.yml --remove
"""
import importlib.util
import os

_spec = importlib.util.spec_from_file_location(
    "biobb_wf_protein_complex_md_setup",
    os.path.join(os.path.dirname(__file__), "biobb_wf_protein-complex_md_setup.py"),
)
_std = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(_std)

test_step0_reduce_remove_hydrogens = _std.test_step0_reduce_remove_hydrogens
test_step2_extract_molecule = _std.test_step2_extract_molecule
test_step00_cat_pdb = _std.test_step00_cat_pdb
test_step4_fix_side_chain = _std.test_step4_fix_side_chain
test_step5_pdb2gmx = _std.test_step5_pdb2gmx
test_step9_make_ndx = _std.test_step9_make_ndx
test_step10_genrestr = _std.test_step10_genrestr
test_step11_gmx_trjconv_str_protein = _std.test_step11_gmx_trjconv_str_protein
test_step12_gmx_trjconv_str_ligand = _std.test_step12_gmx_trjconv_str_ligand
test_step13_cat_pdb_hydrogens = _std.test_step13_cat_pdb_hydrogens
test_step14_append_ligand = _std.test_step14_append_ligand
test_step15_editconf = _std.test_step15_editconf
test_step16_solvate = _std.test_step16_solvate
test_step17_grompp_genion = _std.test_step17_grompp_genion
test_step18_genion = _std.test_step18_genion
test_step19_grompp_min = _std.test_step19_grompp_min
test_step20_mdrun_min = _std.test_step20_mdrun_min
test_step21_gmx_energy_min = _std.test_step21_gmx_energy_min
test_step22_make_ndx = _std.test_step22_make_ndx
test_step23_grompp_nvt = _std.test_step23_grompp_nvt
test_step24_mdrun_nvt = _std.test_step24_mdrun_nvt
test_step25_gmx_energy_nvt = _std.test_step25_gmx_energy_nvt
test_step26_grompp_npt = _std.test_step26_grompp_npt
test_step27_mdrun_npt = _std.test_step27_mdrun_npt
test_step28_gmx_energy_npt = _std.test_step28_gmx_energy_npt
test_step29_grompp_md = _std.test_step29_grompp_md
test_step30_mdrun_md = _std.test_step30_mdrun_md
test_step34_gmx_image = _std.test_step34_gmx_image
test_step34b_gmx_image2 = _std.test_step34b_gmx_image2
test_step35_gmx_trjconv_str = _std.test_step35_gmx_trjconv_str
test_step31_rmsd_first = _std.test_step31_rmsd_first
test_step32_rmsd_exp = _std.test_step32_rmsd_exp
test_step33_gmx_rgyr = _std.test_step33_gmx_rgyr
