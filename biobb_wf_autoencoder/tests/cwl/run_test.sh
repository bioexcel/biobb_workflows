#!/usr/bin/env bash
#
# biobb_wf_autoencoder — cwl flavour e2e test
#
# Runs the CWL workflow with cwltool:
#   cwltool --outdir <out> workflow.cwl workflow_input_descriptions.yml
# The per-tool adapters carry DockerRequirements (quay.io/biocontainers/*),
# so the docker daemon is required. First run pulls the tool images
# (they are cached in the daemon afterwards). The committed inputs next to
# the input yml (str_in.pdb, test_str_in.pdb, trj_in.xtc, test_trj_in.xtc)
# are picked up by cwltool (relative paths resolve against the yml's dir).
#
# Extra cwltool args (e.g. --no-match-user on Mac ARM):
#   EXTRA_CWL_ARGS="--no-match-user" ./run_test.sh
#
# Runtime: there is no MD to shorten (the GROMACS steps only image/fmt and
# analyse the committed trajectories), so NO runtime reduction is applied —
# the only non-trivial step is the autoencoder training (100 epochs, batch
# 128 on ~10k backbone frames), which the CI python flavour runs unreduced.
# This workflow has no MPI anywhere.
#
# Usage:
#   ./run_test.sh [--keep]
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WF_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"
WF_NAME="biobb_wf_autoencoder"

KEEP="${KEEP:-0}"
EXTRA_CWL_ARGS="${EXTRA_CWL_ARGS:-}"

if [[ "${1:-}" == "--keep" ]]; then KEEP=1; fi

# Final workflow outputs (step14_make_plumed)
EXPECTED_OUTPUTS=(
  "plumed.dat"
  "plumed_model.ptc"
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

cleanup() {
  local rc=$?
  if [[ "$KEEP" -ne 1 ]]; then
    rm -rf "$OUT_DIR"
  else
    echo "Kept: out=$OUT_DIR"
  fi
  exit "$rc"
}
trap cleanup EXIT

echo ">>> [1/2] cwltool run"
rm -rf "$OUT_DIR"
mkdir -p "$OUT_DIR"
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

echo ">>> [2/2] assert outputs (searched under $OUT_DIR)"
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
