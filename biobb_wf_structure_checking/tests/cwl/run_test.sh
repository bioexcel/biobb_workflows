#!/usr/bin/env bash
#
# biobb_wf_structure_checking — cwl flavour e2e test
#
# Runs the CWL workflow with cwltool:
#   cwltool --outdir <out> workflow.cwl workflow_input_descriptions.yml
# The per-tool adapters carry DockerRequirements (quay.io/biocontainers/*),
# so the docker daemon is required. First run pulls the tool images
# (they are cached in the daemon afterwards).
#
# The workflow is the 18-step structure quality check on the committed
# structure.pdb (1Z83): model/chain extraction, altloc/ssbond fixes, ion and
# ligand removal, hydrogen/water stripping, amide/chirality/side-chain/
# backbone fixes, LEAP topology, a short sander minimization (500 cycles —
# already serial in the committed cwl input config, no MPI), and the final
# structure_check report.
#
# Runtime: none — the sander step is a short minimization and the cwl input
# config is already serial (no MPI lines), so nothing is reduced.
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
WF_NAME="biobb_wf_structure_checking"

KEEP="${KEEP:-0}"
EXTRA_CWL_ARGS="${EXTRA_CWL_ARGS:-}"

if [[ "${1:-}" == "--keep" ]]; then KEEP=1; fi

# Final workflow output (step17_structure_check)
EXPECTED_OUTPUTS=(
  "structure.report_final.json"
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
  # the sander step is a short (500-cycle) minimization and the committed
  # cwl input config is already serial (no MPI lines).
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
  if [[ "$KEEP" -ne 1 ]]; then
    rm -rf "$OUT_DIR"
  else
    echo "Kept: out=$OUT_DIR"
  fi
  exit "$rc"
}
trap cleanup EXIT

echo ">>> [1/3] prepare"
rm -rf "$OUT_DIR"
mkdir -p "$OUT_DIR"
cp "$CWL_DIR/workflow_input_descriptions.yml" "$OUT_DIR/input_descriptions.orig.yml"
adjust_runtime "$CWL_DIR/workflow_input_descriptions.yml"

echo ">>> [2/3] cwltool run"
set +e
# shellcheck disable=SC2086
( cd "$CWL_DIR" && cwltool --outdir "$OUT_DIR" \
    workflow.cwl workflow_input_descriptions.yml $EXTRA_CWL_ARGS ) \
  > "$OUT_DIR/cwltool.log" 2>&1
RC=$?
set -e

if [[ "$RC" -ne 0 ]]; then
  echo "FAIL: cwltool exited with code $RC — last 50 log lines:"
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
