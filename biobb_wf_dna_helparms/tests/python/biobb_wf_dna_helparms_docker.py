"""Step-by-step pytest for the DOCKER flavour of biobb_wf_dna_helparms.

This reuses the exact same step functions as ``biobb_wf_dna_helparms.py`` (the
standard conda flavour); the only difference is the config passed via ``--config``
(``../../python/workflow.docker.yml``). In that config every step carries a
``container_image`` (quay.io/biocontainers/biobb_dna) + ``container_path: docker``,
so biobb runs the executables (curves++/canal, the dna_averages/timeseries/correlation
tools) inside a docker container while the python biobb code runs natively (pip-installed).

Note: this workflow does a lot of host-side post-processing between containerized
steps (extracting the canal/timeseries zips, ``Path.glob`` over the extracted series
CSVs, re-compressing outputs). Under docker the containerized outputs are staged back
to the host working dir before that post-processing runs, and each next tool's inputs
are staged into its sandbox. All 22 steps map to the same biobb_dna image.

Run it with the dedicated script (pip-installs the biobb packages from
``workflow.env.yml`` and starts the test):

    biobb_wf_dna_helparms/tests/python/run_container_test.sh docker

or, if the environment + docker daemon are already ready, directly:

    pytest biobb_wf_dna_helparms_docker.py --config ../../python/workflow.docker.yml --remove
"""
from biobb_wf_dna_helparms import (  # noqa: F401
    test_step1_biobb_curves,
    test_step2_biobb_canal,
    test_step4_dna_averages_base_pair_step,
    test_step5_dna_averages_base_pair,
    test_step6_dna_averages_axis_base_pairs,
    test_step7_dna_averages_grooves,
    test_step8_puckering,
    test_step9_canonicalag,
    test_step10_bipopulations,
    test_step12_dna_timeseries_base_pair_step,
    test_step13_dna_timeseries_base_pair,
    test_step14_dna_timeseries_axis_base_pairs,
    test_step15_dna_timeseries_grooves,
    test_step16_dna_timeseries_backbone_torsions,
    test_step18_basepair_stiffness,
    test_step19_dna_bimodality,
    test_step20_intraseqcorr,
    test_step21_interseqcorr,
    test_step22_intrahpcorr,
    test_step23_interhpcorr,
    test_step24_intrabpcorr,
    test_step25_interbpcorr,
)
