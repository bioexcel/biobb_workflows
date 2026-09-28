#!/usr/bin/env bash
#
# biobb_wf_cmip — cwl flavour e2e test
#
# Runs the CWL workflow with cwltool:
#   cwltool --outdir <out> workflow.cwl workflow_input_descriptions.yml
# The per-tool adapters carry DockerRequirements (quay.io/biocontainers/*),
# so the docker daemon is required. The tool images are pre-pulled before the
# run (retries transient registry failures).
#
# --no-match-user is passed unconditionally (see the cwltool run below).
# EXTRA_CWL_ARGS can add more cwltool args if ever needed:
#   EXTRA_CWL_ARGS="--debug" ./run_test.sh
#
# NOTE: the MIP steps (cmip_run, AMBER sander) allocate ~25 GiB of RAM — run
# this on a machine with that much free memory. It is SKIPPED in CI for this
# reason (tests/cwl/SKIP).
#
# On failure the script keeps $OUT_DIR (with the full cwltool.log) and
# records it in .e2e_workdir: flavour-test-reusable.yaml tars it and uploads
# it as the `e2e-workdir-biobb_wf_cmip-cwl` GitHub artefact — the real tool
# errors (container stderr, pull errors) are only in that log.
#
# Usage:
#   ./run_test.sh [--keep]
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WF_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"
WF_NAME="biobb_wf_cmip"

KEEP="${KEEP:-0}"
EXTRA_CWL_ARGS="${EXTRA_CWL_ARGS:-}"

if [[ "${1:-}" == "--keep" ]]; then KEEP=1; fi

# Final workflow outputs (step26_cmip_run_complex)
EXPECTED_OUTPUTS=(
  "hACE2.energies.box.output.json"
  "complex_2.energies.box.output.json"
  "hACE2.energies.byat.out"
  "hACE2.energies.log"
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
  # $1 = workflow_input_descriptions.yml. Runtime knobs live inside JSON config
  # strings, e.g.:
  #   sed -i -E 's/("nsteps": )[0-9]+/\1 10/g' "$1"
  #   sed -i -E 's/("mpi_np": )[0-9]+/\1 2/g' "$1"
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

echo ">>> [1/4] prepare"
rm -rf "$OUT_DIR"
mkdir -p "$OUT_DIR"
cp "$CWL_DIR/workflow_input_descriptions.yml" "$OUT_DIR/input_descriptions.orig.yml"
adjust_runtime "$CWL_DIR/workflow_input_descriptions.yml"

echo ">>> [2/4] pre-pull tool images (retries transient registry failures)"
# A cold daemon must have every tool image before cwltool reaches the step
# that needs it; one transient quay.io hiccup would otherwise kill the whole
# run mid-workflow (and this run takes hours to that point).
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

echo ">>> [3/4] cwltool run"
set +e
# --no-match-user: without it cwltool runs every tool container as the
# invoking uid; that uid has no /etc/passwd entry inside the tool image, so
# any tool that resolves the username (getpass.getuser()) dies before writing
# its outputs. Running as the image's default user is exactly what the
# airflow flavour does (its cwltool goes through --user-space-docker-cmd,
# which passes no --user).
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
  echo "(full log kept in $OUT_DIR/cwltool.log)"
  exit "$RC"
fi

echo ">>> [4/4] assert outputs (searched under $OUT_DIR)"
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
