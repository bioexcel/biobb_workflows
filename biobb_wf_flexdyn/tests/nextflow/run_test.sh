#!/usr/bin/env bash
#
# Written by hand for the hand-ported workflow in ../../nextflow, from the run_test.sh template of utils_biobb nextflow_wf_generator.py.
# biobb_wf_flexdyn — nextflow flavour e2e test
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
# Asserts: nextflow exits 0 and every output of every step (53 files) is
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
WF_NAME="biobb_wf_flexdyn"

KEEP="${KEEP:-0}"
PROFILE="${PROFILE:-docker}"
FULL_STEPS="${FULL_STEPS:-0}"
EXTRA_NF_ARGS="${EXTRA_NF_ARGS:-}"
MAX_ATTEMPTS="${MAX_ATTEMPTS:-1}"

if [[ "${1:-}" == "--keep" ]]; then KEEP=1; fi

# Every output of every step, under out/results (samplesheet id: flexdyn)
EXPECTED_OUTPUTS=(
  "flexdyn/step0_extract_model/flexdyn_step0_extract_model_structure.pdb"
  "flexdyn/step1_extract_chain/flexdyn_step1_extract_chain_structure.pdb"
  "flexdyn/step2_cpptraj_mask/flexdyn_step2_cpptraj_mask_cpptraj.pdb"
  "flexdyn/step3_cpptraj_mask/flexdyn_step3_cpptraj_mask_cpptraj.pdb"
  "flexdyn/step4_concoord_dist/flexdyn_step4_concoord_dist_pdb.pdb"
  "flexdyn/step4_concoord_dist/flexdyn_step4_concoord_dist_gro.gro"
  "flexdyn/step4_concoord_dist/flexdyn_step4_concoord_dist_dat.dat"
  "flexdyn/step5_concoord_disco/flexdyn_step5_concoord_disco_traj.pdb"
  "flexdyn/step5_concoord_disco/flexdyn_step5_concoord_disco_rmsd.dat"
  "flexdyn/step5_concoord_disco/flexdyn_step5_concoord_disco_bfactor.pdb"
  "flexdyn/step6_cpptraj_rms/flexdyn_step6_cpptraj_rms_cpptraj.dat"
  "flexdyn/step7_cpptraj_convert/flexdyn_step7_cpptraj_convert_cpptraj.trr"
  "flexdyn/step8_prody_anm/flexdyn_step8_prody_anm_pdb.pdb"
  "flexdyn/step9_cpptraj_rms/flexdyn_step9_cpptraj_rms_cpptraj.dat"
  "flexdyn/step10_cpptraj_convert/flexdyn_step10_cpptraj_convert_cpptraj.trr"
  "flexdyn/step11_bd_run/flexdyn_step11_bd_run_log.log"
  "flexdyn/step11_bd_run/flexdyn_step11_bd_run_crd.mdcrd"
  "flexdyn/step12_cpptraj_rms/flexdyn_step12_cpptraj_rms_cpptraj.dat"
  "flexdyn/step12_cpptraj_rms/flexdyn_step12_cpptraj_rms_traj.trr"
  "flexdyn/step13_dmd_run/flexdyn_step13_dmd_run_log.log"
  "flexdyn/step13_dmd_run/flexdyn_step13_dmd_run_crd.mdcrd"
  "flexdyn/step14_cpptraj_rms/flexdyn_step14_cpptraj_rms_cpptraj.dat"
  "flexdyn/step14_cpptraj_rms/flexdyn_step14_cpptraj_rms_traj.trr"
  "flexdyn/step15_nma_run/flexdyn_step15_nma_run_log.log"
  "flexdyn/step15_nma_run/flexdyn_step15_nma_run_crd.mdcrd"
  "flexdyn/step16_cpptraj_rms/flexdyn_step16_cpptraj_rms_cpptraj.dat"
  "flexdyn/step17_cpptraj_convert/flexdyn_step17_cpptraj_convert_cpptraj.trr"
  "flexdyn/step18_nolb_nma/flexdyn_step18_nolb_nma_pdb.pdb"
  "flexdyn/step19_cpptraj_rms/flexdyn_step19_cpptraj_rms_cpptraj.dat"
  "flexdyn/step20_cpptraj_convert/flexdyn_step20_cpptraj_convert_cpptraj.trr"
  "flexdyn/step21_imod_imode/flexdyn_step21_imod_imode_dat.dat"
  "flexdyn/step22_imod_imc/flexdyn_step22_imod_imc_traj.pdb"
  "flexdyn/step23_cpptraj_rms/flexdyn_step23_cpptraj_rms_cpptraj.dat"
  "flexdyn/step24_cpptraj_convert/flexdyn_step24_cpptraj_convert_cpptraj.trr"
  "flexdyn/step25_trjcat/flexdyn_step25_trjcat_trj.trr"
  "flexdyn/step26_make_ndx/flexdyn_step26_make_ndx_ndx.ndx"
  "flexdyn/step27_gmx_cluster/flexdyn_step27_gmx_cluster_pdb.pdb"
  "flexdyn/step28_cpptraj_rms/flexdyn_step28_cpptraj_rms_cpptraj.dat"
  "flexdyn/step28_cpptraj_rms/flexdyn_step28_cpptraj_rms_traj.crd"
  "flexdyn/step29_pcz_zip/flexdyn_step29_pcz_zip_pcz.pcz"
  "flexdyn/step30_pcz_zip/flexdyn_step30_pcz_zip_pcz.pcz"
  "flexdyn/step31_pcz_info/flexdyn_step31_pcz_info_json.json"
  "flexdyn/step32_pcz_evecs/flexdyn_step32_pcz_evecs_json.json"
  "flexdyn/step33_pcz_animate/flexdyn_step33_pcz_animate_crd.crd"
  "flexdyn/step34_cpptraj_convert/flexdyn_step34_cpptraj_convert_cpptraj.dcd"
  "flexdyn/step35_pcz_bfactor/flexdyn_step35_pcz_bfactor_dat.dat"
  "flexdyn/step35_pcz_bfactor/flexdyn_step35_pcz_bfactor_pdb.pdb"
  "flexdyn/step36_pcz_hinges/flexdyn_step36_pcz_hinges_json.json"
  "flexdyn/step37_pcz_hinges/flexdyn_step37_pcz_hinges_json.json"
  "flexdyn/step38_pcz_hinges/flexdyn_step38_pcz_hinges_json.json"
  "flexdyn/step39_pcz_stiffness/flexdyn_step39_pcz_stiffness_json.json"
  "flexdyn/step40_pcz_collectivity/flexdyn_step40_pcz_collectivity_json.json"
  "flexdyn/step25_trjcat/flexdyn_step25_trjcat_trj_zip.zip"
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
  echo "  PASS: all 53 outputs"
  echo "PASS: $WF_NAME nextflow flavour e2e test"
else
  echo "  (files actually present under $OUT_DIR/results:)"
  find "$OUT_DIR/results" -type f 2>/dev/null | sed "s|^$OUT_DIR/results/|    |" | head -40
  echo "FAIL: $WF_NAME nextflow flavour e2e test (see missing outputs above)"
  exit 1
fi
