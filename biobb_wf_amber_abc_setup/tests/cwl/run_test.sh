#!/usr/bin/env bash
#
# biobb_wf_amber_abc_setup — cwl flavour e2e test
#
# Runs the CWL workflow with cwltool:
#   cwltool --outdir <out> workflow.cwl workflow_input_descriptions.yml
# The per-tool adapters carry DockerRequirements (quay.io/biocontainers/*),
# so the docker daemon is required. First run pulls the tool images
# (they are cached in the daemon afterwards).
#
# Extra cwltool args (e.g. --no-match-user on Mac ARM):
#   EXTRA_CWL_ARGS="--no-match-user" ./run_test.sh
#
# Runtime: every sander step is shortened with the same values the CI python
# flavour uses (.github/workflows/python-reusable.yaml): nstlim -> 100,
# maxcyc -> 50 (the mdin overrides live in the JSON config strings of
# workflow_input_descriptions.yml). The un-reduced workflow would run ~100 ps
# of production MD.
#
# Usage:
#   ./run_test.sh [--keep]
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WF_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"
WF_NAME="biobb_wf_amber_abc_setup"

KEEP="${KEEP:-0}"
EXTRA_CWL_ARGS="${EXTRA_CWL_ARGS:-}"

if [[ "${1:-}" == "--keep" ]]; then KEEP=1; fi

# Final workflow output (step30_cpptraj_image)
EXPECTED_OUTPUTS=(
  "setup.imaged_traj.xtc"
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
  # $1 = workflow_input_descriptions.yml. Shorten every sander step to the CI
  # python values (the mdin overrides are JSON strings inside this yml).
  # BSD sed (macOS) needs an empty backup suffix, GNU sed (Linux) does not
  local SED_INPLACE
  if sed --version >/dev/null 2>&1; then SED_INPLACE=(sed -i); else SED_INPLACE=(sed -i ''); fi
  "${SED_INPLACE[@]}" "s/\"maxcyc\": [0-9]*/\"maxcyc\": 50/g" "$1"
  "${SED_INPLACE[@]}" "s/\"nstlim\": [0-9]*/\"nstlim\": 100/g" "$1"
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
