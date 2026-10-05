"""Step-by-step pytest for the SINGULARITY flavour of biobb_wf_haddock.

This reuses the exact same step functions as ``biobb_wf_haddock.py`` (the standard
conda flavour); the only difference is the config passed via ``--config``
(``../../python/workflow.singularity.yml``).

The workflow is mixed, and that config mirrors the split:
  * The PDB-preparation steps are pure-Python and run natively on the host — no
    container: the ``biobb_pdb_tools`` pipeline (tidy / selchain / delhetatm /
    fixinsert / selaltloc / keepcoord / selres / reres / chain / chainxseg) and
    ``biobb_pdb_merge`` (-> the ``pdb_merge`` binary) for steps 0-8.
  * The HADDOCK3 steps shell out to the ``haddock3-restraints`` / ``haddock3``
    binaries via ``run_biobb`` and carry a ``container_image`` (a
    depot.galaxyproject.org biobb_haddock singularity URL) +
    ``container_path: singularity`` — the pip venv has the python wrappers but the
    engine is run from the container (steps 9-23). The ``haddock_wf_data``
    directory is handed across those steps via the shared working-dir mount.

Note: biobb issues a ``singularity pull`` on every container step (an image URL never
"exists" as a path) with a mangled target name the registry rejects. The dedicated
script pre-pulls each unique image to a local ``.sif`` and rewrites the scratch
config's ``container_image`` to that local path, so biobb skips its own failing pull.

Run it with the dedicated script (pip-installs the biobb packages from
``workflow.env.yml`` and warms the singularity cache):

    biobb_wf_haddock/tests/python/run_container_test.sh singularity

or, if the environment + singularity are already ready, directly:

    pytest biobb_wf_haddock_singularity.py \
        --config ../../python/workflow.singularity.yml --remove
"""
from biobb_wf_haddock import (  # noqa: F401
    test_step0_prepare_antibody_reduce,
    test_step1_biobb_pdb_merge,
    test_step2_prepare_antibody_clean,
    test_step3_prepare_antigen_clean,
    test_step4_prepare_reference_structure,
    test_step5_biobb_pdb_merge,
    test_step6_prepare_complex_antibody_clean,
    test_step7_prepare_complex_antigen_clean,
    test_step8_merge_heavy_light_antigen,
    test_step9_haddock3_passive_from_active,
    test_step10_haddock3_actpass_to_ambig,
    test_step11_haddock3_restrain_bodies,
    test_step12_topology,
    test_step13_rigid_body,
    test_step14_capri_eval1,
    test_step15_sele_top,
    test_step16_flex_ref,
    test_step17_capri_eval2,
    test_step18_em_ref,
    test_step19_capri_eval3,
    test_step20_clust_fcc,
    test_step21_sele_top_clusts,
    test_step22_capri_eval4,
    test_step23_contact_map,
)
