#!/usr/bin/env bash
#
# Written by hand for the hand-ported workflow in ../../nextflow, from the run_test.sh template of utils_biobb nextflow_wf_generator.py.
# biobb_wf_dna_helparms — nextflow flavour e2e test
#
# Runs the Nextflow workflow (../../nextflow) with its default samplesheet:
#   nextflow run ../../nextflow -profile docker -c out/test.config
# out/test.config is a copy of nextflow.config with the runtime cuts of
# adjust_runtime below and the test settings, so the committed workflow files
# are never modified. Every step pulls the quay.io/biocontainers/* image of its
# module through the host docker daemon (cached afterwards).
#
# Runtime cuts: none
#
# Asserts: nextflow exits 0 and every output of every step (302 files) is
# published, not empty, in out/results/<id>/<step>/.
#
# Options / environment:
#   --keep               keep out/ (always kept on failure, recorded in .e2e_workdir)
#   PROFILE=apptainer    container profile (default: docker)
#   FULL_STEPS=1         skip the runtime cuts
#   EXTRA_NF_ARGS="..."  extra `nextflow run` arguments
#
# Usage:
#   ./run_test.sh [--keep]
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WF_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"
WF_NAME="biobb_wf_dna_helparms"

KEEP="${KEEP:-0}"
PROFILE="${PROFILE:-docker}"
FULL_STEPS="${FULL_STEPS:-0}"
EXTRA_NF_ARGS="${EXTRA_NF_ARGS:-}"
MAX_ATTEMPTS="${MAX_ATTEMPTS:-1}"

if [[ "${1:-}" == "--keep" ]]; then KEEP=1; fi

# Every output of every step, under out/results (samplesheet id: dna_helparms)
EXPECTED_OUTPUTS=(
  "dna_helparms/step1_biobb_curves/dna_helparms_step1_biobb_curves_cda.cda"
  "dna_helparms/step1_biobb_curves/dna_helparms_step1_biobb_curves_lis.lis"
  "dna_helparms/step1_biobb_curves/dna_helparms_step1_biobb_curves_zip.zip"
  "dna_helparms/step2_biobb_canal/dna_helparms_step2_biobb_canal_zip.zip"
  "dna_helparms/step4_dna_averages_base_pair_step/dna_helparms_step4_dna_averages_base_pair_step_outputs.zip"
  "dna_helparms/step4_dna_averages_base_pair_step/dna_helparms_step4_dna_averages_base_pair_step_rise_csv.csv"
  "dna_helparms/step4_dna_averages_base_pair_step/dna_helparms_step4_dna_averages_base_pair_step_rise_jpg.jpg"
  "dna_helparms/step4_dna_averages_base_pair_step/dna_helparms_step4_dna_averages_base_pair_step_roll_csv.csv"
  "dna_helparms/step4_dna_averages_base_pair_step/dna_helparms_step4_dna_averages_base_pair_step_roll_jpg.jpg"
  "dna_helparms/step4_dna_averages_base_pair_step/dna_helparms_step4_dna_averages_base_pair_step_shift_csv.csv"
  "dna_helparms/step4_dna_averages_base_pair_step/dna_helparms_step4_dna_averages_base_pair_step_shift_jpg.jpg"
  "dna_helparms/step4_dna_averages_base_pair_step/dna_helparms_step4_dna_averages_base_pair_step_slide_csv.csv"
  "dna_helparms/step4_dna_averages_base_pair_step/dna_helparms_step4_dna_averages_base_pair_step_slide_jpg.jpg"
  "dna_helparms/step4_dna_averages_base_pair_step/dna_helparms_step4_dna_averages_base_pair_step_tilt_csv.csv"
  "dna_helparms/step4_dna_averages_base_pair_step/dna_helparms_step4_dna_averages_base_pair_step_tilt_jpg.jpg"
  "dna_helparms/step4_dna_averages_base_pair_step/dna_helparms_step4_dna_averages_base_pair_step_twist_csv.csv"
  "dna_helparms/step4_dna_averages_base_pair_step/dna_helparms_step4_dna_averages_base_pair_step_twist_jpg.jpg"
  "dna_helparms/step5_dna_averages_base_pair/dna_helparms_step5_dna_averages_base_pair_buckle_csv.csv"
  "dna_helparms/step5_dna_averages_base_pair/dna_helparms_step5_dna_averages_base_pair_buckle_jpg.jpg"
  "dna_helparms/step5_dna_averages_base_pair/dna_helparms_step5_dna_averages_base_pair_opening_csv.csv"
  "dna_helparms/step5_dna_averages_base_pair/dna_helparms_step5_dna_averages_base_pair_opening_jpg.jpg"
  "dna_helparms/step5_dna_averages_base_pair/dna_helparms_step5_dna_averages_base_pair_outputs.zip"
  "dna_helparms/step5_dna_averages_base_pair/dna_helparms_step5_dna_averages_base_pair_propel_csv.csv"
  "dna_helparms/step5_dna_averages_base_pair/dna_helparms_step5_dna_averages_base_pair_propel_jpg.jpg"
  "dna_helparms/step5_dna_averages_base_pair/dna_helparms_step5_dna_averages_base_pair_shear_csv.csv"
  "dna_helparms/step5_dna_averages_base_pair/dna_helparms_step5_dna_averages_base_pair_shear_jpg.jpg"
  "dna_helparms/step5_dna_averages_base_pair/dna_helparms_step5_dna_averages_base_pair_stagger_csv.csv"
  "dna_helparms/step5_dna_averages_base_pair/dna_helparms_step5_dna_averages_base_pair_stagger_jpg.jpg"
  "dna_helparms/step5_dna_averages_base_pair/dna_helparms_step5_dna_averages_base_pair_stretch_csv.csv"
  "dna_helparms/step5_dna_averages_base_pair/dna_helparms_step5_dna_averages_base_pair_stretch_jpg.jpg"
  "dna_helparms/step6_dna_averages_axis_base_pairs/dna_helparms_step6_dna_averages_axis_base_pairs_inclin_csv.csv"
  "dna_helparms/step6_dna_averages_axis_base_pairs/dna_helparms_step6_dna_averages_axis_base_pairs_inclin_jpg.jpg"
  "dna_helparms/step6_dna_averages_axis_base_pairs/dna_helparms_step6_dna_averages_axis_base_pairs_outputs.zip"
  "dna_helparms/step6_dna_averages_axis_base_pairs/dna_helparms_step6_dna_averages_axis_base_pairs_tip_csv.csv"
  "dna_helparms/step6_dna_averages_axis_base_pairs/dna_helparms_step6_dna_averages_axis_base_pairs_tip_jpg.jpg"
  "dna_helparms/step6_dna_averages_axis_base_pairs/dna_helparms_step6_dna_averages_axis_base_pairs_xdisp_csv.csv"
  "dna_helparms/step6_dna_averages_axis_base_pairs/dna_helparms_step6_dna_averages_axis_base_pairs_xdisp_jpg.jpg"
  "dna_helparms/step6_dna_averages_axis_base_pairs/dna_helparms_step6_dna_averages_axis_base_pairs_ydisp_csv.csv"
  "dna_helparms/step6_dna_averages_axis_base_pairs/dna_helparms_step6_dna_averages_axis_base_pairs_ydisp_jpg.jpg"
  "dna_helparms/step7_dna_averages_grooves/dna_helparms_step7_dna_averages_grooves_majd_csv.csv"
  "dna_helparms/step7_dna_averages_grooves/dna_helparms_step7_dna_averages_grooves_majd_jpg.jpg"
  "dna_helparms/step7_dna_averages_grooves/dna_helparms_step7_dna_averages_grooves_majw_csv.csv"
  "dna_helparms/step7_dna_averages_grooves/dna_helparms_step7_dna_averages_grooves_majw_jpg.jpg"
  "dna_helparms/step7_dna_averages_grooves/dna_helparms_step7_dna_averages_grooves_mind_csv.csv"
  "dna_helparms/step7_dna_averages_grooves/dna_helparms_step7_dna_averages_grooves_mind_jpg.jpg"
  "dna_helparms/step7_dna_averages_grooves/dna_helparms_step7_dna_averages_grooves_minw_csv.csv"
  "dna_helparms/step7_dna_averages_grooves/dna_helparms_step7_dna_averages_grooves_minw_jpg.jpg"
  "dna_helparms/step7_dna_averages_grooves/dna_helparms_step7_dna_averages_grooves_outputs.zip"
  "dna_helparms/step8_puckering/dna_helparms_step8_puckering_csv.csv"
  "dna_helparms/step8_puckering/dna_helparms_step8_puckering_jpg.jpg"
  "dna_helparms/step8_puckering/dna_helparms_step8_puckering_outputs.zip"
  "dna_helparms/step9_canonicalag/dna_helparms_step9_canonicalag_csv.csv"
  "dna_helparms/step9_canonicalag/dna_helparms_step9_canonicalag_jpg.jpg"
  "dna_helparms/step9_canonicalag/dna_helparms_step9_canonicalag_outputs.zip"
  "dna_helparms/step10_bipopulations/dna_helparms_step10_bipopulations_csv.csv"
  "dna_helparms/step10_bipopulations/dna_helparms_step10_bipopulations_jpg.jpg"
  "dna_helparms/step10_bipopulations/dna_helparms_step10_bipopulations_outputs.zip"
  "dna_helparms/step12_dna_timeseries_base_pair_step/dna_helparms_step12_dna_timeseries_base_pair_step_outputs.zip"
  "dna_helparms/step12_dna_timeseries_base_pair_step/dna_helparms_step12_dna_timeseries_base_pair_step_rise_zip.zip"
  "dna_helparms/step12_dna_timeseries_base_pair_step/dna_helparms_step12_dna_timeseries_base_pair_step_roll_zip.zip"
  "dna_helparms/step12_dna_timeseries_base_pair_step/dna_helparms_step12_dna_timeseries_base_pair_step_shift_zip.zip"
  "dna_helparms/step12_dna_timeseries_base_pair_step/dna_helparms_step12_dna_timeseries_base_pair_step_slide_zip.zip"
  "dna_helparms/step12_dna_timeseries_base_pair_step/dna_helparms_step12_dna_timeseries_base_pair_step_tilt_zip.zip"
  "dna_helparms/step12_dna_timeseries_base_pair_step/dna_helparms_step12_dna_timeseries_base_pair_step_twist_zip.zip"
  "dna_helparms/step13_dna_timeseries_base_pair/dna_helparms_step13_dna_timeseries_base_pair_buckle_zip.zip"
  "dna_helparms/step13_dna_timeseries_base_pair/dna_helparms_step13_dna_timeseries_base_pair_opening_zip.zip"
  "dna_helparms/step13_dna_timeseries_base_pair/dna_helparms_step13_dna_timeseries_base_pair_outputs.zip"
  "dna_helparms/step13_dna_timeseries_base_pair/dna_helparms_step13_dna_timeseries_base_pair_propel_zip.zip"
  "dna_helparms/step13_dna_timeseries_base_pair/dna_helparms_step13_dna_timeseries_base_pair_shear_zip.zip"
  "dna_helparms/step13_dna_timeseries_base_pair/dna_helparms_step13_dna_timeseries_base_pair_stagger_zip.zip"
  "dna_helparms/step13_dna_timeseries_base_pair/dna_helparms_step13_dna_timeseries_base_pair_stretch_zip.zip"
  "dna_helparms/step14_dna_timeseries_axis_base_pairs/dna_helparms_step14_dna_timeseries_axis_base_pairs_inclin_zip.zip"
  "dna_helparms/step14_dna_timeseries_axis_base_pairs/dna_helparms_step14_dna_timeseries_axis_base_pairs_outputs.zip"
  "dna_helparms/step14_dna_timeseries_axis_base_pairs/dna_helparms_step14_dna_timeseries_axis_base_pairs_tip_zip.zip"
  "dna_helparms/step14_dna_timeseries_axis_base_pairs/dna_helparms_step14_dna_timeseries_axis_base_pairs_xdisp_zip.zip"
  "dna_helparms/step14_dna_timeseries_axis_base_pairs/dna_helparms_step14_dna_timeseries_axis_base_pairs_ydisp_zip.zip"
  "dna_helparms/step15_dna_timeseries_grooves/dna_helparms_step15_dna_timeseries_grooves_majd_zip.zip"
  "dna_helparms/step15_dna_timeseries_grooves/dna_helparms_step15_dna_timeseries_grooves_majw_zip.zip"
  "dna_helparms/step15_dna_timeseries_grooves/dna_helparms_step15_dna_timeseries_grooves_mind_zip.zip"
  "dna_helparms/step15_dna_timeseries_grooves/dna_helparms_step15_dna_timeseries_grooves_minw_zip.zip"
  "dna_helparms/step15_dna_timeseries_grooves/dna_helparms_step15_dna_timeseries_grooves_outputs.zip"
  "dna_helparms/step16_dna_timeseries_backbone_torsions/dna_helparms_step16_dna_timeseries_backbone_torsions_alphaC_zip.zip"
  "dna_helparms/step16_dna_timeseries_backbone_torsions/dna_helparms_step16_dna_timeseries_backbone_torsions_alphaW_zip.zip"
  "dna_helparms/step16_dna_timeseries_backbone_torsions/dna_helparms_step16_dna_timeseries_backbone_torsions_betaC_zip.zip"
  "dna_helparms/step16_dna_timeseries_backbone_torsions/dna_helparms_step16_dna_timeseries_backbone_torsions_betaW_zip.zip"
  "dna_helparms/step16_dna_timeseries_backbone_torsions/dna_helparms_step16_dna_timeseries_backbone_torsions_chiC_zip.zip"
  "dna_helparms/step16_dna_timeseries_backbone_torsions/dna_helparms_step16_dna_timeseries_backbone_torsions_chiW_zip.zip"
  "dna_helparms/step16_dna_timeseries_backbone_torsions/dna_helparms_step16_dna_timeseries_backbone_torsions_deltaC_zip.zip"
  "dna_helparms/step16_dna_timeseries_backbone_torsions/dna_helparms_step16_dna_timeseries_backbone_torsions_deltaW_zip.zip"
  "dna_helparms/step16_dna_timeseries_backbone_torsions/dna_helparms_step16_dna_timeseries_backbone_torsions_epsilC_zip.zip"
  "dna_helparms/step16_dna_timeseries_backbone_torsions/dna_helparms_step16_dna_timeseries_backbone_torsions_epsilW_zip.zip"
  "dna_helparms/step16_dna_timeseries_backbone_torsions/dna_helparms_step16_dna_timeseries_backbone_torsions_gammaC_zip.zip"
  "dna_helparms/step16_dna_timeseries_backbone_torsions/dna_helparms_step16_dna_timeseries_backbone_torsions_gammaW_zip.zip"
  "dna_helparms/step16_dna_timeseries_backbone_torsions/dna_helparms_step16_dna_timeseries_backbone_torsions_outputs.zip"
  "dna_helparms/step16_dna_timeseries_backbone_torsions/dna_helparms_step16_dna_timeseries_backbone_torsions_phaseC_zip.zip"
  "dna_helparms/step16_dna_timeseries_backbone_torsions/dna_helparms_step16_dna_timeseries_backbone_torsions_phaseW_zip.zip"
  "dna_helparms/step16_dna_timeseries_backbone_torsions/dna_helparms_step16_dna_timeseries_backbone_torsions_zetaC_zip.zip"
  "dna_helparms/step16_dna_timeseries_backbone_torsions/dna_helparms_step16_dna_timeseries_backbone_torsions_zetaW_zip.zip"
  "dna_helparms/step18_basepair_stiffness/dna_helparms_step18_basepair_stiffness_2_GC_csv.csv"
  "dna_helparms/step18_basepair_stiffness/dna_helparms_step18_basepair_stiffness_2_GC_jpg.jpg"
  "dna_helparms/step18_basepair_stiffness/dna_helparms_step18_basepair_stiffness_3_CG_csv.csv"
  "dna_helparms/step18_basepair_stiffness/dna_helparms_step18_basepair_stiffness_3_CG_jpg.jpg"
  "dna_helparms/step18_basepair_stiffness/dna_helparms_step18_basepair_stiffness_4_GA_csv.csv"
  "dna_helparms/step18_basepair_stiffness/dna_helparms_step18_basepair_stiffness_4_GA_jpg.jpg"
  "dna_helparms/step18_basepair_stiffness/dna_helparms_step18_basepair_stiffness_5_AA_csv.csv"
  "dna_helparms/step18_basepair_stiffness/dna_helparms_step18_basepair_stiffness_5_AA_jpg.jpg"
  "dna_helparms/step18_basepair_stiffness/dna_helparms_step18_basepair_stiffness_6_AT_csv.csv"
  "dna_helparms/step18_basepair_stiffness/dna_helparms_step18_basepair_stiffness_6_AT_jpg.jpg"
  "dna_helparms/step18_basepair_stiffness/dna_helparms_step18_basepair_stiffness_7_TT_csv.csv"
  "dna_helparms/step18_basepair_stiffness/dna_helparms_step18_basepair_stiffness_7_TT_jpg.jpg"
  "dna_helparms/step18_basepair_stiffness/dna_helparms_step18_basepair_stiffness_8_TC_csv.csv"
  "dna_helparms/step18_basepair_stiffness/dna_helparms_step18_basepair_stiffness_8_TC_jpg.jpg"
  "dna_helparms/step18_basepair_stiffness/dna_helparms_step18_basepair_stiffness_9_CG_csv.csv"
  "dna_helparms/step18_basepair_stiffness/dna_helparms_step18_basepair_stiffness_9_CG_jpg.jpg"
  "dna_helparms/step18_basepair_stiffness/dna_helparms_step18_basepair_stiffness_10_GC_csv.csv"
  "dna_helparms/step18_basepair_stiffness/dna_helparms_step18_basepair_stiffness_10_GC_jpg.jpg"
  "dna_helparms/step18_basepair_stiffness/dna_helparms_step18_basepair_stiffness_outputs.zip"
  "dna_helparms/step19_dna_bimodality/dna_helparms_step19_dna_bimodality_outputs.zip"
  "dna_helparms/step19_dna_bimodality/dna_helparms_step19_dna_bimodality_rise_2_GC_csv.csv"
  "dna_helparms/step19_dna_bimodality/dna_helparms_step19_dna_bimodality_rise_2_GC_jpg.jpg"
  "dna_helparms/step19_dna_bimodality/dna_helparms_step19_dna_bimodality_rise_3_CG_csv.csv"
  "dna_helparms/step19_dna_bimodality/dna_helparms_step19_dna_bimodality_rise_3_CG_jpg.jpg"
  "dna_helparms/step19_dna_bimodality/dna_helparms_step19_dna_bimodality_rise_4_GA_csv.csv"
  "dna_helparms/step19_dna_bimodality/dna_helparms_step19_dna_bimodality_rise_4_GA_jpg.jpg"
  "dna_helparms/step19_dna_bimodality/dna_helparms_step19_dna_bimodality_rise_5_AA_csv.csv"
  "dna_helparms/step19_dna_bimodality/dna_helparms_step19_dna_bimodality_rise_5_AA_jpg.jpg"
  "dna_helparms/step19_dna_bimodality/dna_helparms_step19_dna_bimodality_rise_6_AT_csv.csv"
  "dna_helparms/step19_dna_bimodality/dna_helparms_step19_dna_bimodality_rise_6_AT_jpg.jpg"
  "dna_helparms/step19_dna_bimodality/dna_helparms_step19_dna_bimodality_rise_7_TT_csv.csv"
  "dna_helparms/step19_dna_bimodality/dna_helparms_step19_dna_bimodality_rise_7_TT_jpg.jpg"
  "dna_helparms/step19_dna_bimodality/dna_helparms_step19_dna_bimodality_rise_8_TC_csv.csv"
  "dna_helparms/step19_dna_bimodality/dna_helparms_step19_dna_bimodality_rise_8_TC_jpg.jpg"
  "dna_helparms/step19_dna_bimodality/dna_helparms_step19_dna_bimodality_rise_9_CG_csv.csv"
  "dna_helparms/step19_dna_bimodality/dna_helparms_step19_dna_bimodality_rise_9_CG_jpg.jpg"
  "dna_helparms/step19_dna_bimodality/dna_helparms_step19_dna_bimodality_rise_10_GC_csv.csv"
  "dna_helparms/step19_dna_bimodality/dna_helparms_step19_dna_bimodality_rise_10_GC_jpg.jpg"
  "dna_helparms/step19_dna_bimodality/dna_helparms_step19_dna_bimodality_roll_2_GC_csv.csv"
  "dna_helparms/step19_dna_bimodality/dna_helparms_step19_dna_bimodality_roll_2_GC_jpg.jpg"
  "dna_helparms/step19_dna_bimodality/dna_helparms_step19_dna_bimodality_roll_3_CG_csv.csv"
  "dna_helparms/step19_dna_bimodality/dna_helparms_step19_dna_bimodality_roll_3_CG_jpg.jpg"
  "dna_helparms/step19_dna_bimodality/dna_helparms_step19_dna_bimodality_roll_4_GA_csv.csv"
  "dna_helparms/step19_dna_bimodality/dna_helparms_step19_dna_bimodality_roll_4_GA_jpg.jpg"
  "dna_helparms/step19_dna_bimodality/dna_helparms_step19_dna_bimodality_roll_5_AA_csv.csv"
  "dna_helparms/step19_dna_bimodality/dna_helparms_step19_dna_bimodality_roll_5_AA_jpg.jpg"
  "dna_helparms/step19_dna_bimodality/dna_helparms_step19_dna_bimodality_roll_6_AT_csv.csv"
  "dna_helparms/step19_dna_bimodality/dna_helparms_step19_dna_bimodality_roll_6_AT_jpg.jpg"
  "dna_helparms/step19_dna_bimodality/dna_helparms_step19_dna_bimodality_roll_7_TT_csv.csv"
  "dna_helparms/step19_dna_bimodality/dna_helparms_step19_dna_bimodality_roll_7_TT_jpg.jpg"
  "dna_helparms/step19_dna_bimodality/dna_helparms_step19_dna_bimodality_roll_8_TC_csv.csv"
  "dna_helparms/step19_dna_bimodality/dna_helparms_step19_dna_bimodality_roll_8_TC_jpg.jpg"
  "dna_helparms/step19_dna_bimodality/dna_helparms_step19_dna_bimodality_roll_9_CG_csv.csv"
  "dna_helparms/step19_dna_bimodality/dna_helparms_step19_dna_bimodality_roll_9_CG_jpg.jpg"
  "dna_helparms/step19_dna_bimodality/dna_helparms_step19_dna_bimodality_roll_10_GC_csv.csv"
  "dna_helparms/step19_dna_bimodality/dna_helparms_step19_dna_bimodality_roll_10_GC_jpg.jpg"
  "dna_helparms/step19_dna_bimodality/dna_helparms_step19_dna_bimodality_shift_2_GC_csv.csv"
  "dna_helparms/step19_dna_bimodality/dna_helparms_step19_dna_bimodality_shift_2_GC_jpg.jpg"
  "dna_helparms/step19_dna_bimodality/dna_helparms_step19_dna_bimodality_shift_3_CG_csv.csv"
  "dna_helparms/step19_dna_bimodality/dna_helparms_step19_dna_bimodality_shift_3_CG_jpg.jpg"
  "dna_helparms/step19_dna_bimodality/dna_helparms_step19_dna_bimodality_shift_4_GA_csv.csv"
  "dna_helparms/step19_dna_bimodality/dna_helparms_step19_dna_bimodality_shift_4_GA_jpg.jpg"
  "dna_helparms/step19_dna_bimodality/dna_helparms_step19_dna_bimodality_shift_5_AA_csv.csv"
  "dna_helparms/step19_dna_bimodality/dna_helparms_step19_dna_bimodality_shift_5_AA_jpg.jpg"
  "dna_helparms/step19_dna_bimodality/dna_helparms_step19_dna_bimodality_shift_6_AT_csv.csv"
  "dna_helparms/step19_dna_bimodality/dna_helparms_step19_dna_bimodality_shift_6_AT_jpg.jpg"
  "dna_helparms/step19_dna_bimodality/dna_helparms_step19_dna_bimodality_shift_7_TT_csv.csv"
  "dna_helparms/step19_dna_bimodality/dna_helparms_step19_dna_bimodality_shift_7_TT_jpg.jpg"
  "dna_helparms/step19_dna_bimodality/dna_helparms_step19_dna_bimodality_shift_8_TC_csv.csv"
  "dna_helparms/step19_dna_bimodality/dna_helparms_step19_dna_bimodality_shift_8_TC_jpg.jpg"
  "dna_helparms/step19_dna_bimodality/dna_helparms_step19_dna_bimodality_shift_9_CG_csv.csv"
  "dna_helparms/step19_dna_bimodality/dna_helparms_step19_dna_bimodality_shift_9_CG_jpg.jpg"
  "dna_helparms/step19_dna_bimodality/dna_helparms_step19_dna_bimodality_shift_10_GC_csv.csv"
  "dna_helparms/step19_dna_bimodality/dna_helparms_step19_dna_bimodality_shift_10_GC_jpg.jpg"
  "dna_helparms/step19_dna_bimodality/dna_helparms_step19_dna_bimodality_slide_2_GC_csv.csv"
  "dna_helparms/step19_dna_bimodality/dna_helparms_step19_dna_bimodality_slide_2_GC_jpg.jpg"
  "dna_helparms/step19_dna_bimodality/dna_helparms_step19_dna_bimodality_slide_3_CG_csv.csv"
  "dna_helparms/step19_dna_bimodality/dna_helparms_step19_dna_bimodality_slide_3_CG_jpg.jpg"
  "dna_helparms/step19_dna_bimodality/dna_helparms_step19_dna_bimodality_slide_4_GA_csv.csv"
  "dna_helparms/step19_dna_bimodality/dna_helparms_step19_dna_bimodality_slide_4_GA_jpg.jpg"
  "dna_helparms/step19_dna_bimodality/dna_helparms_step19_dna_bimodality_slide_5_AA_csv.csv"
  "dna_helparms/step19_dna_bimodality/dna_helparms_step19_dna_bimodality_slide_5_AA_jpg.jpg"
  "dna_helparms/step19_dna_bimodality/dna_helparms_step19_dna_bimodality_slide_6_AT_csv.csv"
  "dna_helparms/step19_dna_bimodality/dna_helparms_step19_dna_bimodality_slide_6_AT_jpg.jpg"
  "dna_helparms/step19_dna_bimodality/dna_helparms_step19_dna_bimodality_slide_7_TT_csv.csv"
  "dna_helparms/step19_dna_bimodality/dna_helparms_step19_dna_bimodality_slide_7_TT_jpg.jpg"
  "dna_helparms/step19_dna_bimodality/dna_helparms_step19_dna_bimodality_slide_8_TC_csv.csv"
  "dna_helparms/step19_dna_bimodality/dna_helparms_step19_dna_bimodality_slide_8_TC_jpg.jpg"
  "dna_helparms/step19_dna_bimodality/dna_helparms_step19_dna_bimodality_slide_9_CG_csv.csv"
  "dna_helparms/step19_dna_bimodality/dna_helparms_step19_dna_bimodality_slide_9_CG_jpg.jpg"
  "dna_helparms/step19_dna_bimodality/dna_helparms_step19_dna_bimodality_slide_10_GC_csv.csv"
  "dna_helparms/step19_dna_bimodality/dna_helparms_step19_dna_bimodality_slide_10_GC_jpg.jpg"
  "dna_helparms/step19_dna_bimodality/dna_helparms_step19_dna_bimodality_tilt_2_GC_csv.csv"
  "dna_helparms/step19_dna_bimodality/dna_helparms_step19_dna_bimodality_tilt_2_GC_jpg.jpg"
  "dna_helparms/step19_dna_bimodality/dna_helparms_step19_dna_bimodality_tilt_3_CG_csv.csv"
  "dna_helparms/step19_dna_bimodality/dna_helparms_step19_dna_bimodality_tilt_3_CG_jpg.jpg"
  "dna_helparms/step19_dna_bimodality/dna_helparms_step19_dna_bimodality_tilt_4_GA_csv.csv"
  "dna_helparms/step19_dna_bimodality/dna_helparms_step19_dna_bimodality_tilt_4_GA_jpg.jpg"
  "dna_helparms/step19_dna_bimodality/dna_helparms_step19_dna_bimodality_tilt_5_AA_csv.csv"
  "dna_helparms/step19_dna_bimodality/dna_helparms_step19_dna_bimodality_tilt_5_AA_jpg.jpg"
  "dna_helparms/step19_dna_bimodality/dna_helparms_step19_dna_bimodality_tilt_6_AT_csv.csv"
  "dna_helparms/step19_dna_bimodality/dna_helparms_step19_dna_bimodality_tilt_6_AT_jpg.jpg"
  "dna_helparms/step19_dna_bimodality/dna_helparms_step19_dna_bimodality_tilt_7_TT_csv.csv"
  "dna_helparms/step19_dna_bimodality/dna_helparms_step19_dna_bimodality_tilt_7_TT_jpg.jpg"
  "dna_helparms/step19_dna_bimodality/dna_helparms_step19_dna_bimodality_tilt_8_TC_csv.csv"
  "dna_helparms/step19_dna_bimodality/dna_helparms_step19_dna_bimodality_tilt_8_TC_jpg.jpg"
  "dna_helparms/step19_dna_bimodality/dna_helparms_step19_dna_bimodality_tilt_9_CG_csv.csv"
  "dna_helparms/step19_dna_bimodality/dna_helparms_step19_dna_bimodality_tilt_9_CG_jpg.jpg"
  "dna_helparms/step19_dna_bimodality/dna_helparms_step19_dna_bimodality_tilt_10_GC_csv.csv"
  "dna_helparms/step19_dna_bimodality/dna_helparms_step19_dna_bimodality_tilt_10_GC_jpg.jpg"
  "dna_helparms/step19_dna_bimodality/dna_helparms_step19_dna_bimodality_twist_2_GC_csv.csv"
  "dna_helparms/step19_dna_bimodality/dna_helparms_step19_dna_bimodality_twist_2_GC_jpg.jpg"
  "dna_helparms/step19_dna_bimodality/dna_helparms_step19_dna_bimodality_twist_3_CG_csv.csv"
  "dna_helparms/step19_dna_bimodality/dna_helparms_step19_dna_bimodality_twist_3_CG_jpg.jpg"
  "dna_helparms/step19_dna_bimodality/dna_helparms_step19_dna_bimodality_twist_4_GA_csv.csv"
  "dna_helparms/step19_dna_bimodality/dna_helparms_step19_dna_bimodality_twist_4_GA_jpg.jpg"
  "dna_helparms/step19_dna_bimodality/dna_helparms_step19_dna_bimodality_twist_5_AA_csv.csv"
  "dna_helparms/step19_dna_bimodality/dna_helparms_step19_dna_bimodality_twist_5_AA_jpg.jpg"
  "dna_helparms/step19_dna_bimodality/dna_helparms_step19_dna_bimodality_twist_6_AT_csv.csv"
  "dna_helparms/step19_dna_bimodality/dna_helparms_step19_dna_bimodality_twist_6_AT_jpg.jpg"
  "dna_helparms/step19_dna_bimodality/dna_helparms_step19_dna_bimodality_twist_7_TT_csv.csv"
  "dna_helparms/step19_dna_bimodality/dna_helparms_step19_dna_bimodality_twist_7_TT_jpg.jpg"
  "dna_helparms/step19_dna_bimodality/dna_helparms_step19_dna_bimodality_twist_8_TC_csv.csv"
  "dna_helparms/step19_dna_bimodality/dna_helparms_step19_dna_bimodality_twist_8_TC_jpg.jpg"
  "dna_helparms/step19_dna_bimodality/dna_helparms_step19_dna_bimodality_twist_9_CG_csv.csv"
  "dna_helparms/step19_dna_bimodality/dna_helparms_step19_dna_bimodality_twist_9_CG_jpg.jpg"
  "dna_helparms/step19_dna_bimodality/dna_helparms_step19_dna_bimodality_twist_10_GC_csv.csv"
  "dna_helparms/step19_dna_bimodality/dna_helparms_step19_dna_bimodality_twist_10_GC_jpg.jpg"
  "dna_helparms/step20_intraseqcorr/dna_helparms_step20_intraseqcorr_buckle_csv.csv"
  "dna_helparms/step20_intraseqcorr/dna_helparms_step20_intraseqcorr_buckle_jpg.jpg"
  "dna_helparms/step20_intraseqcorr/dna_helparms_step20_intraseqcorr_opening_csv.csv"
  "dna_helparms/step20_intraseqcorr/dna_helparms_step20_intraseqcorr_opening_jpg.jpg"
  "dna_helparms/step20_intraseqcorr/dna_helparms_step20_intraseqcorr_outputs.zip"
  "dna_helparms/step20_intraseqcorr/dna_helparms_step20_intraseqcorr_propel_csv.csv"
  "dna_helparms/step20_intraseqcorr/dna_helparms_step20_intraseqcorr_propel_jpg.jpg"
  "dna_helparms/step20_intraseqcorr/dna_helparms_step20_intraseqcorr_shear_csv.csv"
  "dna_helparms/step20_intraseqcorr/dna_helparms_step20_intraseqcorr_shear_jpg.jpg"
  "dna_helparms/step20_intraseqcorr/dna_helparms_step20_intraseqcorr_stagger_csv.csv"
  "dna_helparms/step20_intraseqcorr/dna_helparms_step20_intraseqcorr_stagger_jpg.jpg"
  "dna_helparms/step20_intraseqcorr/dna_helparms_step20_intraseqcorr_stretch_csv.csv"
  "dna_helparms/step20_intraseqcorr/dna_helparms_step20_intraseqcorr_stretch_jpg.jpg"
  "dna_helparms/step21_interseqcorr/dna_helparms_step21_interseqcorr_outputs.zip"
  "dna_helparms/step21_interseqcorr/dna_helparms_step21_interseqcorr_rise_csv.csv"
  "dna_helparms/step21_interseqcorr/dna_helparms_step21_interseqcorr_rise_jpg.jpg"
  "dna_helparms/step21_interseqcorr/dna_helparms_step21_interseqcorr_roll_csv.csv"
  "dna_helparms/step21_interseqcorr/dna_helparms_step21_interseqcorr_roll_jpg.jpg"
  "dna_helparms/step21_interseqcorr/dna_helparms_step21_interseqcorr_shift_csv.csv"
  "dna_helparms/step21_interseqcorr/dna_helparms_step21_interseqcorr_shift_jpg.jpg"
  "dna_helparms/step21_interseqcorr/dna_helparms_step21_interseqcorr_slide_csv.csv"
  "dna_helparms/step21_interseqcorr/dna_helparms_step21_interseqcorr_slide_jpg.jpg"
  "dna_helparms/step21_interseqcorr/dna_helparms_step21_interseqcorr_tilt_csv.csv"
  "dna_helparms/step21_interseqcorr/dna_helparms_step21_interseqcorr_tilt_jpg.jpg"
  "dna_helparms/step21_interseqcorr/dna_helparms_step21_interseqcorr_twist_csv.csv"
  "dna_helparms/step21_interseqcorr/dna_helparms_step21_interseqcorr_twist_jpg.jpg"
  "dna_helparms/step22_intrahpcorr/dna_helparms_step22_intrahpcorr_1_C_csv.csv"
  "dna_helparms/step22_intrahpcorr/dna_helparms_step22_intrahpcorr_1_C_jpg.jpg"
  "dna_helparms/step22_intrahpcorr/dna_helparms_step22_intrahpcorr_2_G_csv.csv"
  "dna_helparms/step22_intrahpcorr/dna_helparms_step22_intrahpcorr_2_G_jpg.jpg"
  "dna_helparms/step22_intrahpcorr/dna_helparms_step22_intrahpcorr_3_C_csv.csv"
  "dna_helparms/step22_intrahpcorr/dna_helparms_step22_intrahpcorr_3_C_jpg.jpg"
  "dna_helparms/step22_intrahpcorr/dna_helparms_step22_intrahpcorr_4_G_csv.csv"
  "dna_helparms/step22_intrahpcorr/dna_helparms_step22_intrahpcorr_4_G_jpg.jpg"
  "dna_helparms/step22_intrahpcorr/dna_helparms_step22_intrahpcorr_5_A_csv.csv"
  "dna_helparms/step22_intrahpcorr/dna_helparms_step22_intrahpcorr_5_A_jpg.jpg"
  "dna_helparms/step22_intrahpcorr/dna_helparms_step22_intrahpcorr_6_A_csv.csv"
  "dna_helparms/step22_intrahpcorr/dna_helparms_step22_intrahpcorr_6_A_jpg.jpg"
  "dna_helparms/step22_intrahpcorr/dna_helparms_step22_intrahpcorr_7_T_csv.csv"
  "dna_helparms/step22_intrahpcorr/dna_helparms_step22_intrahpcorr_7_T_jpg.jpg"
  "dna_helparms/step22_intrahpcorr/dna_helparms_step22_intrahpcorr_8_T_csv.csv"
  "dna_helparms/step22_intrahpcorr/dna_helparms_step22_intrahpcorr_8_T_jpg.jpg"
  "dna_helparms/step22_intrahpcorr/dna_helparms_step22_intrahpcorr_9_C_csv.csv"
  "dna_helparms/step22_intrahpcorr/dna_helparms_step22_intrahpcorr_9_C_jpg.jpg"
  "dna_helparms/step22_intrahpcorr/dna_helparms_step22_intrahpcorr_10_G_csv.csv"
  "dna_helparms/step22_intrahpcorr/dna_helparms_step22_intrahpcorr_10_G_jpg.jpg"
  "dna_helparms/step22_intrahpcorr/dna_helparms_step22_intrahpcorr_11_C_csv.csv"
  "dna_helparms/step22_intrahpcorr/dna_helparms_step22_intrahpcorr_11_C_jpg.jpg"
  "dna_helparms/step22_intrahpcorr/dna_helparms_step22_intrahpcorr_12_G_csv.csv"
  "dna_helparms/step22_intrahpcorr/dna_helparms_step22_intrahpcorr_12_G_jpg.jpg"
  "dna_helparms/step22_intrahpcorr/dna_helparms_step22_intrahpcorr_outputs.zip"
  "dna_helparms/step23_interhpcorr/dna_helparms_step23_interhpcorr_2_GC_csv.csv"
  "dna_helparms/step23_interhpcorr/dna_helparms_step23_interhpcorr_2_GC_jpg.jpg"
  "dna_helparms/step23_interhpcorr/dna_helparms_step23_interhpcorr_3_CG_csv.csv"
  "dna_helparms/step23_interhpcorr/dna_helparms_step23_interhpcorr_3_CG_jpg.jpg"
  "dna_helparms/step23_interhpcorr/dna_helparms_step23_interhpcorr_4_GA_csv.csv"
  "dna_helparms/step23_interhpcorr/dna_helparms_step23_interhpcorr_4_GA_jpg.jpg"
  "dna_helparms/step23_interhpcorr/dna_helparms_step23_interhpcorr_5_AA_csv.csv"
  "dna_helparms/step23_interhpcorr/dna_helparms_step23_interhpcorr_5_AA_jpg.jpg"
  "dna_helparms/step23_interhpcorr/dna_helparms_step23_interhpcorr_6_AT_csv.csv"
  "dna_helparms/step23_interhpcorr/dna_helparms_step23_interhpcorr_6_AT_jpg.jpg"
  "dna_helparms/step23_interhpcorr/dna_helparms_step23_interhpcorr_7_TT_csv.csv"
  "dna_helparms/step23_interhpcorr/dna_helparms_step23_interhpcorr_7_TT_jpg.jpg"
  "dna_helparms/step23_interhpcorr/dna_helparms_step23_interhpcorr_8_TC_csv.csv"
  "dna_helparms/step23_interhpcorr/dna_helparms_step23_interhpcorr_8_TC_jpg.jpg"
  "dna_helparms/step23_interhpcorr/dna_helparms_step23_interhpcorr_9_CG_csv.csv"
  "dna_helparms/step23_interhpcorr/dna_helparms_step23_interhpcorr_9_CG_jpg.jpg"
  "dna_helparms/step23_interhpcorr/dna_helparms_step23_interhpcorr_10_GC_csv.csv"
  "dna_helparms/step23_interhpcorr/dna_helparms_step23_interhpcorr_10_GC_jpg.jpg"
  "dna_helparms/step23_interhpcorr/dna_helparms_step23_interhpcorr_outputs.zip"
  "dna_helparms/step24_intrabpcorr/dna_helparms_step24_intrabpcorr_csv.csv"
  "dna_helparms/step24_intrabpcorr/dna_helparms_step24_intrabpcorr_jpg.jpg"
  "dna_helparms/step24_intrabpcorr/dna_helparms_step24_intrabpcorr_outputs.zip"
  "dna_helparms/step25_interbpcorr/dna_helparms_step25_interbpcorr_csv.csv"
  "dna_helparms/step25_interbpcorr/dna_helparms_step25_interbpcorr_jpg.jpg"
  "dna_helparms/step25_interbpcorr/dna_helparms_step25_interbpcorr_outputs.zip"
)

NF_DIR="$WF_DIR/nextflow"
OUT_DIR="$SCRIPT_DIR/out"

if [[ ! -f "$NF_DIR/main.nf" ]]; then
  echo "ERROR: $NF_DIR/main.nf not found (wrong repo layout?)" >&2
  exit 1
fi

require() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "ERROR: '$1' not found on PATH." >&2
    [[ "$1" == "nextflow" ]] && echo "Install e.g.: curl -s https://get.nextflow.io | bash (needs Java 17+)" >&2
    exit 1
  }
}
require nextflow
if [[ "$PROFILE" == "docker" ]]; then
  require docker
  docker info >/dev/null 2>&1 || { echo "ERROR: docker daemon not reachable" >&2; exit 1; }
fi

# BSD sed (macOS) needs an empty backup suffix, GNU sed (Linux) does not
if sed --version >/dev/null 2>&1; then SED_INPLACE=(sed -i -E); else SED_INPLACE=(sed -i '' -E); fi

# ---------------- per-workflow runtime cuts (TEST_SETTINGS of nextflow_wf_generator.py) ----------------
adjust_runtime() {
  # $1 = copy of nextflow.config
  :
}
# --------------------------------------------------------------------------------------------------------

cleanup() {
  local rc=$?
  if [[ "$rc" -ne 0 && -d "$OUT_DIR" ]]; then
    echo "$OUT_DIR" > "$SCRIPT_DIR/.e2e_workdir"
    echo "Kept for debugging: $OUT_DIR"
  elif [[ "$KEEP" -ne 1 ]]; then
    rm -rf "$OUT_DIR" "$SCRIPT_DIR/.e2e_workdir"
  else
    rm -f "$SCRIPT_DIR/.e2e_workdir"
    echo "Kept: out=$OUT_DIR"
  fi
  exit "$rc"
}
trap cleanup EXIT

echo ">>> [1/4] prepare"
rm -rf "$OUT_DIR" "$SCRIPT_DIR/.e2e_workdir"
mkdir -p "$OUT_DIR"
cp "$NF_DIR/nextflow.config" "$OUT_DIR/test.config"
if [[ "$FULL_STEPS" -ne 1 ]]; then adjust_runtime "$OUT_DIR/test.config"; fi
NCPU="$(getconf _NPROCESSORS_ONLN 2>/dev/null || sysctl -n hw.ncpu)"
cat >> "$OUT_DIR/test.config" <<EOF

// e2e test settings: no task asks for more CPUs than the host has, task status in trace.tsv
process.resourceLimits = [cpus: $NCPU]
trace {
    enabled = true
    file = 'trace.tsv'
    overwrite = true
    fields = 'process,tag,status,exit,realtime'
}
EOF
case "$(uname -m)" in
  arm64|aarch64)
    if [[ "$PROFILE" == "docker" ]]; then
      echo "WARNING: ARM host, the biocontainers are amd64 only: running them with --platform linux/amd64 (slow)"
      cat >> "$OUT_DIR/test.config" <<'EOF'
profiles {
    docker {
        docker.runOptions = '-u $(id -u):$(id -g) --platform linux/amd64'
    }
}
EOF
    fi
    ;;
esac

if [[ "$PROFILE" == "docker" ]]; then
  echo ">>> [2/4] pull the module images"
  for img in $(grep -ho "quay.io/biocontainers/[^']*" "$NF_DIR"/modules/*/*/*/main.nf | sort -u); do
    PULL_OK=0
    for attempt in 1 2 3; do
      if docker pull -q "$img" >/dev/null; then PULL_OK=1; break; fi
      [[ "$attempt" -eq 3 ]] && break
      echo "  pull $img attempt $attempt/3 failed, retrying in 15 s"
      sleep 15
    done
    [[ "$PULL_OK" -eq 1 ]] || { echo "ERROR: docker pull failed for $img after 3 attempts" >&2; exit 1; }
  done
else
  echo ">>> [2/4] images are pulled by nextflow ($PROFILE profile)"
fi

echo ">>> [3/4] nextflow run (up to $MAX_ATTEMPTS attempts)"
RC=1
for attempt in $(seq 1 "$MAX_ATTEMPTS"); do
  RESUME=""
  if [[ "$attempt" -gt 1 ]]; then RESUME="-resume"; fi
  set +e
  # shellcheck disable=SC2086
  ( cd "$OUT_DIR" && nextflow run "$NF_DIR" -profile "$PROFILE" -c test.config -ansi-log false $RESUME $EXTRA_NF_ARGS ) \
    >> "$OUT_DIR/nextflow_run.log" 2>&1
  RC=$?
  set -e
  [[ "$RC" -eq 0 ]] && break
  if [[ "$attempt" -lt "$MAX_ATTEMPTS" ]]; then
    echo "  attempt $attempt/$MAX_ATTEMPTS failed (rc=$RC), resuming in 30 s"
    sleep 30
  fi
done

if [[ "$RC" -ne 0 ]]; then
  echo "FAIL: nextflow exited with code $RC — failed tasks and last 50 log lines:"
  [[ -f "$OUT_DIR/trace.tsv" ]] && awk -F'\t' 'NR > 1 && $3 != "COMPLETED" { print "  " $1 " (" $2 "): " $3 ", exit " $4 }' "$OUT_DIR/trace.tsv"
  tail -50 "$OUT_DIR/nextflow_run.log"
  exit "$RC"
fi

echo ">>> [4/4] assert outputs (under $OUT_DIR/results)"
FAIL=0
for out in "${EXPECTED_OUTPUTS[@]}"; do
  path="$OUT_DIR/results/$out"
  if [[ "$out" == */ ]]; then
    [[ -d "$path" && -n "$(ls -A "$path" 2>/dev/null)" ]] && continue
  else
    [[ -s "$path" ]] && continue
  fi
  echo "  FAIL: not found (or empty): $out"
  FAIL=1
done

if [[ "$FAIL" -eq 0 ]]; then
  echo "  PASS: all 302 outputs"
  echo "PASS: $WF_NAME nextflow flavour e2e test"
else
  echo "  (files actually present under $OUT_DIR/results:)"
  find "$OUT_DIR/results" -type f 2>/dev/null | sed "s|^$OUT_DIR/results/|    |" | head -40
  echo "FAIL: $WF_NAME nextflow flavour e2e test (see missing outputs above)"
  exit 1
fi
