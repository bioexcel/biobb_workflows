#!/usr/bin/env bash
#
# Written by hand for the hand-ported workflow in ../../nextflow, from the run_test.sh template of utils_biobb nextflow_wf_generator.py.
# biobb_wf_haddock — nextflow flavour e2e test
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
# Asserts: nextflow exits 0 and every output of every step (42 files) is
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
WF_NAME="biobb_wf_haddock"

KEEP="${KEEP:-0}"
PROFILE="${PROFILE:-docker}"
FULL_STEPS="${FULL_STEPS:-0}"
EXTRA_NF_ARGS="${EXTRA_NF_ARGS:-}"
MAX_ATTEMPTS="${MAX_ATTEMPTS:-1}"

if [[ "${1:-}" == "--keep" ]]; then KEEP=1; fi

# Every output of every step, under out/results (samplesheet id: haddock)
EXPECTED_OUTPUTS=(
  "haddock/step0_prepare_antibody_reduce/haddock_step0_prepare_antibody_reduce_H_file.pdb"
  "haddock/step0_prepare_antibody_reduce/haddock_step0_prepare_antibody_reduce_L_file.pdb"
  "haddock/step0_prepare_antibody_reduce/haddock_step0_prepare_antibody_reduce_HL.zip"
  "haddock/step1_biobb_pdb_merge/haddock_step1_biobb_pdb_merge_file.pdb"
  "haddock/step2_prepare_antibody_clean/haddock_step2_prepare_antibody_clean_file.pdb"
  "haddock/step3_prepare_antigen_clean/haddock_step3_prepare_antigen_clean_file.pdb"
  "haddock/step4_prepare_reference_structure/haddock_step4_prepare_reference_structure_H_file.pdb"
  "haddock/step4_prepare_reference_structure/haddock_step4_prepare_reference_structure_L_file.pdb"
  "haddock/step4_prepare_reference_structure/haddock_step4_prepare_reference_structure_HL.zip"
  "haddock/step5_biobb_pdb_merge/haddock_step5_biobb_pdb_merge_file.pdb"
  "haddock/step6_prepare_complex_antibody_clean/haddock_step6_prepare_complex_antibody_clean_file.pdb"
  "haddock/step7_prepare_complex_antigen_clean/haddock_step7_prepare_complex_antigen_clean_file.pdb"
  "haddock/step7_prepare_complex_antigen_clean/haddock_step7_prepare_complex_antigen_clean_HL_B.zip"
  "haddock/step8_merge_heavy_light_antigen/haddock_step8_merge_heavy_light_antigen_file.pdb"
  "haddock/step9_haddock3_passive_from_active/haddock_step9_haddock3_passive_from_active_actpass.txt"
  "haddock/step10_haddock3_actpass_to_ambig/haddock_step10_haddock3_actpass_to_ambig_tbl.tbl"
  "haddock/step11_haddock3_restrain_bodies/haddock_step11_haddock3_restrain_bodies_tbl.tbl"
  "haddock/step12_topology/haddock_step12_topology_haddock_wf_data.directory/"
  "haddock/step12_topology/haddock_step12_topology_mol1_output_top_zip.zip"
  "haddock/step12_topology/haddock_step12_topology_mol2_output_top_zip.zip"
  "haddock/step13_rigid_body/haddock_step13_rigid_body_haddock_wf_data/"
  "haddock/step13_rigid_body/haddock_step13_rigid_body_docking_output_zip.zip"
  "haddock/step14_capri_eval1/haddock_step14_capri_eval1_haddock_wf_data/"
  "haddock/step14_capri_eval1/haddock_step14_capri_eval1_evaluation_zip.zip"
  "haddock/step15_sele_top/haddock_step15_sele_top_haddock_wf_data/"
  "haddock/step15_sele_top/haddock_step15_sele_top_selection_zip.zip"
  "haddock/step16_flex_ref/haddock_step16_flex_ref_haddock_wf_data/"
  "haddock/step16_flex_ref/haddock_step16_flex_ref_refinement_output_zip.zip"
  "haddock/step17_capri_eval2/haddock_step17_capri_eval2_haddock_wf_data/"
  "haddock/step17_capri_eval2/haddock_step17_capri_eval2_evaluation_zip.zip"
  "haddock/step18_em_ref/haddock_step18_em_ref_haddock_wf_data/"
  "haddock/step18_em_ref/haddock_step18_em_ref_refinement_output_zip.zip"
  "haddock/step19_capri_eval3/haddock_step19_capri_eval3_haddock_wf_data/"
  "haddock/step19_capri_eval3/haddock_step19_capri_eval3_evaluation_zip.zip"
  "haddock/step20_clust_fcc/haddock_step20_clust_fcc_haddock_wf_data/"
  "haddock/step20_clust_fcc/haddock_step20_clust_fcc_cluster_zip.zip"
  "haddock/step21_sele_top_clusts/haddock_step21_sele_top_clusts_haddock_wf_data/"
  "haddock/step21_sele_top_clusts/haddock_step21_sele_top_clusts_selection_zip.zip"
  "haddock/step22_capri_eval4/haddock_step22_capri_eval4_haddock_wf_data/"
  "haddock/step22_capri_eval4/haddock_step22_capri_eval4_evaluation_zip.zip"
  "haddock/step23_contact_map/haddock_step23_contact_map_haddock_wf_data/"
  "haddock/step23_contact_map/haddock_step23_contact_map_contactmap_zip.zip"
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
  echo "  PASS: all 42 outputs"
  echo "PASS: $WF_NAME nextflow flavour e2e test"
else
  echo "  (files actually present under $OUT_DIR/results:)"
  find "$OUT_DIR/results" -type f 2>/dev/null | sed "s|^$OUT_DIR/results/|    |" | head -40
  echo "FAIL: $WF_NAME nextflow flavour e2e test (see missing outputs above)"
  exit 1
fi
