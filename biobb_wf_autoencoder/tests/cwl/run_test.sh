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
# --no-match-user is passed unconditionally (see the cwltool run below).
# EXTRA_CWL_ARGS can add more cwltool args if ever needed:
#   EXTRA_CWL_ARGS="--debug" ./run_test.sh
#
# Runtime: there is no MD to shorten (the GROMACS steps only image/fmt and
# analyse the committed trajectories), so NO runtime reduction is applied —
# the only non-trivial step is the autoencoder training (100 epochs, batch
# 128 on ~10k backbone frames), which the CI python flavour runs unreduced.
# This workflow has no MPI anywhere.
#
# On failure the script keeps $OUT_DIR (with the full cwltool.log) and
# records it in .e2e_workdir: flavour-test-reusable.yaml tars it and uploads
# it as the `e2e-workdir-biobb_wf_autoencoder-cwl` GitHub artefact — the real
# tool errors (container stderr, pull errors) are only in that log.
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

echo ">>> [1/3] pre-pull tool images (retries transient registry failures)"
# This flavour runs on a cold runner: every tool image must be pulled before
# cwltool reaches the step that needs it, and one transient quay.io hiccup
# would otherwise kill the whole run mid-workflow.
TOOL_IMAGES="$(grep -h 'dockerPull:' "$CWL_DIR/biobb_adapters"/*.cwl | awk '{print $2}' | sort -u)"
for img in $TOOL_IMAGES; do
  PULL_OK=0
  for attempt in 1 2 3; do
    if docker pull "$img" >/dev/null; then PULL_OK=1; break; fi
    [[ "$attempt" -eq 3 ]] && break
    echo "  pull $img attempt $attempt/3 failed — retrying in 15 s"
    sleep 15
  done
  [[ "$PULL_OK" -eq 1 ]] || { echo "ERROR: docker pull failed for $img after 3 attempts" >&2; exit 1; }
  echo "  ready: $img"
done

echo ">>> [2/3] cwltool run"
rm -rf "$OUT_DIR"
mkdir -p "$OUT_DIR"
set +e
# --no-match-user: without it cwltool runs every tool container as the
# invoking uid (1001 on GH runners); that uid has no /etc/passwd entry
# inside the tool image, so any tool that calls getpass.getuser() — torch's
# cache-dir lookup in biobb_pytorch's mdfeaturizer — dies with "OSError: No
# username set in the environment" before writing its outputs. Running as
# the image's default user is exactly what the airflow flavour does (its
# cwltool goes through --user-space-docker-cmd, which passes no --user),
# which is why only this flavour failed.
# shellcheck disable=SC2086
( cd "$CWL_DIR" && cwltool --no-match-user --outdir "$OUT_DIR" \
    workflow.cwl workflow_input_descriptions.yml $EXTRA_CWL_ARGS ) \
  > "$OUT_DIR/cwltool.log" 2>&1
RC=$?
set -e

if [[ "$RC" -ne 0 ]]; then
  echo "FAIL: cwltool exited with code $RC"
  echo "--- error/warning lines (cwltool.log) ---"
  grep -E "ERROR|WARNING" "$OUT_DIR/cwltool.log" | head -40 || true
  echo "--- last 50 log lines ---"
  tail -50 "$OUT_DIR/cwltool.log"
  echo "(full log kept in $OUT_DIR/cwltool.log — uploaded as the on-failure artefact)"
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
