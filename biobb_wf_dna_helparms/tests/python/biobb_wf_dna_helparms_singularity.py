"""Step-by-step pytest for the SINGULARITY flavour of biobb_wf_dna_helparms.

This reuses the exact same step functions as ``biobb_wf_dna_helparms.py`` (the
standard conda flavour); the only difference is the config passed via ``--config``
(``../../python/workflow.singularity.yml``). In that config every step carries a
``container_image`` (a depot.galaxyproject.org singularity URL) +
``container_path: singularity``, so biobb runs the executables (curves++/canal, the
dna_averages/timeseries/correlation tools) inside a singularity container while the
python biobb code runs natively (pip-installed).

Note: this workflow does a lot of host-side post-processing between containerized
steps (extracting the canal/timeseries zips, ``Path.glob`` over the extracted series
CSVs, re-compressing outputs). All 22 steps map to the same biobb_dna image, so they
only download once because they share a ``SINGULARITY_CACHE`` — the dedicated script
exports a persistent ``SINGULARITY_CACHE`` and pre-pulls the unique images.

Run it with the dedicated script (pip-installs the biobb packages from
``workflow.env.yml`` and warms the singularity cache):

    biobb_wf_dna_helparms/tests/python/run_container_test.sh singularity

or, if the environment + singularity are already ready, directly:

    pytest biobb_wf_dna_helparms_singularity.py --config ../../python/workflow.singularity.yml --remove
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
