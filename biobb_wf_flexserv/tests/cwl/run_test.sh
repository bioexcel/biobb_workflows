#!/usr/bin/env bash
#
# biobb_wf_flexserv — cwl flavour e2e test
#
# Runs the CWL workflow with cwltool:
#   cwltool --outdir <out> workflow.cwl workflow_input_descriptions.yml
# The per-tool adapters carry DockerRequirements (quay.io/biocontainers/*:
# biobb_flexserv, biobb_analysis, biobb_structure_utils — 5.2.1 tags), so
# the docker daemon is required. First run pulls the tool images (they are
# cached in the daemon afterwards).
#
# The workflow is the 29-step FLEXSERV ensemble comparison on the committed
# CA-only structure.pdb (1A32): BD / DMD / NMA ensemble generation, per-method
# RMSD, PCA compression (pcz zip/unzip) and the PCASuite analyses, ending in
# the similarity indices vs the committed MoDEL 10-ns MD reference
# (Files/1a32.MoDEL.pcz).
#
# Runtime: none — the committed cwl input configs are the unreduced ones
# (same as the python CI), nothing to change.
#
# Extra cwltool args (e.g. --no-match-user on Mac ARM):
#   EXTRA_CWL_ARGS="--no-match-user" ./run_test.sh
#
# Usage:
#   ./run_test.sh [--keep]
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WF_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"
WF_NAME="biobb_wf_flexserv"

KEEP="${KEEP:-0}"
EXTRA_CWL_ARGS="${EXTRA_CWL_ARGS:-}"

if [[ "${1:-}" == "--keep" ]]; then KEEP=1; fi

# Final workflow output (step28_pcz_similarity)
EXPECTED_OUTPUTS=(
  "simIndex_bd_report_nma_vs_md.json"
)

CWL_DIR="$WF_DIR/cwl"
OUT_DIR="$SCRIPT_DIR/out"

if [[ ! -f "$CWL_DIR/workflow.cwl" ]]; then
  echo "ERROR: $CWL_DIR/workflow.cwl not found (wrong repo layout?)" >&2
  exit 1
fi

require() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "ERROR: '$1' not found on PATH." >&2
    [[ "$1" == "cwltool" ]] && echo "Install e.g.: micromamba create -n cwl -c conda-forge cwltool" >&2
    exit 1
  }
}
require docker
require cwltool
docker info >/dev/null 2>&1 || { echo "ERROR: docker daemon not reachable" >&2; exit 1; }

# ---------------- per-workflow hooks (edit when porting) ----------------
adjust_runtime() {
  # $1 = workflow_input_descriptions.yml. No reduction for this workflow:
  # the committed cwl input configs are the unreduced ones (same as the
  # python CI), nothing to change.
  :
}
# --------------------------------------------------------------------------

restore_inputs() {
  [[ -f "$OUT_DIR/input_descriptions.orig.yml" ]] && \
    cp "$OUT_DIR/input_descriptions.orig.yml" "$CWL_DIR/workflow_input_descriptions.yml"
}

cleanup() {
  local rc=$?
  restore_inputs
  if [[ "$rc" -eq 0 ]]; then
    rm -f "$SCRIPT_DIR/.e2e_workdir"
    if [[ "$KEEP" -ne 1 ]]; then
      rm -rf "$OUT_DIR"
    else
      echo "Kept: out=$OUT_DIR"
    fi
  else
    # keep the workdir (full cwltool.log) and record it so the on-failure
    # artefact step (flavour-test-reusable.yaml) can tar + upload it
    [[ -d "$OUT_DIR" ]] && echo "$OUT_DIR" > "$SCRIPT_DIR/.e2e_workdir"
    echo "Kept (failed): out=$OUT_DIR (full log: $OUT_DIR/cwltool.log)"
  fi
  exit "$rc"
}
trap cleanup EXIT

echo ">>> [1/3] prepare"
rm -rf "$OUT_DIR"
mkdir -p "$OUT_DIR"
cp "$CWL_DIR/workflow_input_descriptions.yml" "$OUT_DIR/input_descriptions.orig.yml"
adjust_runtime "$CWL_DIR/workflow_input_descriptions.yml"

# cwltool has no per-step timeout: one stuck tool would hold the lane for
# hours. Guard with GNU coreutils `timeout` (Linux runners); skipped where
# unavailable (macOS). On a timeout the killed cwltool may leave the running
# tool container orphaned (locally: check `docker ps -a`).
#
# 90 min per attempt: 29 tool containers (startup overhead) + the BD/DMD/NMA
# ensemble runs — more margin than a small wf needs, still bounded.
#
# The workflow makes a few small network calls that can fail transiently
# from CI. Retry the whole run a few times before failing (a hang is NOT
# retried — it is not transient).
CWL_TIMEOUT_MIN="${CWL_TIMEOUT_MIN:-90}"
CWL_MAX_ATTEMPTS="${CWL_MAX_ATTEMPTS:-3}"
echo ">>> [2/3] cwltool run (up to $CWL_MAX_ATTEMPTS attempts, ${CWL_TIMEOUT_MIN} min each)"
RC=1
for attempt in $(seq 1 "$CWL_MAX_ATTEMPTS"); do
  set +e
  # shellcheck disable=SC2086
  if command -v timeout >/dev/null 2>&1; then
    ( cd "$CWL_DIR" && timeout --kill-after=60 "${CWL_TIMEOUT_MIN}m" \
        cwltool --outdir "$OUT_DIR" \
        workflow.cwl workflow_input_descriptions.yml $EXTRA_CWL_ARGS ) \
      > "$OUT_DIR/cwltool.log" 2>&1
  else
    ( cd "$CWL_DIR" && cwltool --outdir "$OUT_DIR" \
        workflow.cwl workflow_input_descriptions.yml $EXTRA_CWL_ARGS ) \
      > "$OUT_DIR/cwltool.log" 2>&1
  fi
  RC=$?
  set -e
  if [[ "$RC" -eq 0 ]]; then
    break
  fi
  if [[ "$RC" -eq 124 || "$RC" -eq 137 ]]; then
    break
  fi
  if [[ "$attempt" -lt "$CWL_MAX_ATTEMPTS" ]]; then
    echo "  attempt $attempt/$CWL_MAX_ATTEMPTS failed (rc=$RC) — last 10 log lines:"
    tail -10 "$OUT_DIR/cwltool.log" | sed 's/^/    /'
    echo "  retrying in 30 s (transient network failure?)"
    sleep 30
  fi
done

if [[ "$RC" -eq 124 || "$RC" -eq 137 ]]; then
  echo "FAIL: cwltool HUNG (killed after ${CWL_TIMEOUT_MIN} min) — last 50 log lines (stuck step = last step in the log):"
  tail -50 "$OUT_DIR/cwltool.log"
  exit "$RC"
fi
if [[ "$RC" -ne 0 ]]; then
  echo "FAIL: cwltool exited with code $RC after $CWL_MAX_ATTEMPTS attempt(s) — last 50 log lines:"
  tail -50 "$OUT_DIR/cwltool.log"
  exit "$RC"
fi

echo ">>> [3/3] assert outputs (searched under $OUT_DIR)"
FAIL=0
for out in "${EXPECTED_OUTPUTS[@]}"; do
  found="$(find "$OUT_DIR" -type f -name "$out" 2>/dev/null | head -1)"
  if [[ -n "$found" && -s "$found" ]]; then
    echo "  PASS: $out  (in $(basename "$(dirname "$found")"))"
  else
    echo "  FAIL: not found (or empty): $out"
    FAIL=1
  fi
done
if [[ "$FAIL" -ne 0 ]]; then
  echo "  (files actually present under $OUT_DIR:)"
  find "$OUT_DIR" -maxdepth 3 -type f 2>/dev/null | sed 's/^/    /' | head -40
fi

if [[ "$FAIL" -eq 0 ]]; then
  echo "PASS: $WF_NAME cwl flavour e2e test"
else
  echo "FAIL: $WF_NAME cwl flavour e2e test (see missing outputs above)"
  exit 1
fi
