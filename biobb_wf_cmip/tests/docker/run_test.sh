#!/usr/bin/env bash
#
# biobb_wf_cmip — docker flavour e2e test
#
# Builds the workflow docker image from <wf>/docker/Dockerfile and runs it in
# MODE=python (default), mounting the committed inputs read-only and keeping
# all outputs inside this test folder (tests/docker/work/), so the git-tracked
# docker/ input folder is never polluted.
#
# NOTE: the Dockerfile fetches conda_env/environment.yml, the notebook and
# python/workflow.py from GitHub *main* at build time — this test therefore
# validates the published artefact + the local Dockerfile, not unpushed edits.
#
# Usage:
#   ./run_test.sh [--no-build] [--pull] [--image TAG] [--keep]
#     --no-build   do not build the image (it must already exist locally)
#     --pull       pull ghcr.io/bioexcel/biobb_wf_cmip:latest instead of building
#     --image TAG  image tag to build/use (default: biobb_wf_cmip:test)
#     --keep       keep image + work/ dir after the run
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WF_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"
REPO_ROOT="$(dirname "$WF_DIR")"
WF_NAME="biobb_wf_cmip"

IMAGE="${WF_NAME}:test"
DO_BUILD=1
DO_PULL=0
KEEP="${KEEP:-0}"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --no-build) DO_BUILD=0; shift ;;
    --pull)     DO_PULL=1; DO_BUILD=0; shift ;;
    --image)    IMAGE="$2"; shift 2 ;;
    --keep)     KEEP=1; shift ;;
    *) echo "Unknown option: $1" >&2; exit 2 ;;
  esac
done

# Final workflow outputs (step26_cmip_run_complex in python/workflow.yml)
EXPECTED_OUTPUTS=(
  "hACE2.energies.box.output.json"
  "complex_2.energies.box.output.json"
  "hACE2.energies.byat.out"
  "hACE2.energies.log"
)

DOCKER_DIR="$WF_DIR/docker"
WORK_DIR="$SCRIPT_DIR/work"
CONTAINER="biobb-dtest-${WF_NAME//\//-}-$$"

if [[ ! -f "$DOCKER_DIR/Dockerfile" ]]; then
  echo "ERROR: $DOCKER_DIR/Dockerfile not found (wrong repo layout?)" >&2
  exit 1
fi

# ---------------- per-workflow hooks (edit when porting) ----------------
docker_build_args() {
  # plain repo: no SUBREPO. Subrepo workflows add e.g.:
  #   echo "--build-arg REPO=biobb_wf_amber --build-arg SUBREPO=abc_setup"
  echo "--build-arg REPO=$WF_NAME"
}

extra_data_mounts() {
  # raw inputs shipped in docker/ (each mounted read-only at /data/<name>)
  for f in structure.pdb complex.pdb Files; do
    echo "-v $DOCKER_DIR/$f:/data/$f:ro"
  done
}

adjust_runtime() {
  # $1 = local workflow.yml used for the run. Reduce runtimes for heavy wfs, e.g.:
  #   sed -i -E 's/(nstlim: )[0-9]+/\1 100/' "$1"
  :
}
# --------------------------------------------------------------------------

require() {
  command -v "$1" >/dev/null 2>&1 || { echo "ERROR: '$1' not found on PATH" >&2; exit 1; }
}
require docker
docker info >/dev/null 2>&1 || { echo "ERROR: docker daemon not reachable" >&2; exit 1; }

PLATFORM_FLAGS=()
if [[ "$(uname -m)" == "arm64" || "$(uname -m)" == "aarch64" ]]; then
  PLATFORM_FLAGS=(--platform linux/amd64)
  echo "WARNING: ARM host — amd64 image will run under QEMU emulation (very slow)."
fi

cleanup() {
  local rc=$?
  docker rm -f "$CONTAINER" >/dev/null 2>&1 || true
  # the image is kept on purpose (same tag, overwritten on next build) so
  # reruns are fast; remove it manually with: docker rmi $IMAGE
  if [[ "$KEEP" -ne 1 ]]; then
    rm -rf "$WORK_DIR"
  else
    echo "Kept: image=$IMAGE work=$WORK_DIR"
  fi
  exit "$rc"
}
trap cleanup EXIT

echo ">>> [1/4] build stage (image=$IMAGE)"
if [[ "$DO_PULL" -eq 1 ]]; then
  IMAGE="ghcr.io/bioexcel/$WF_NAME:latest"
  docker pull "$IMAGE"
elif [[ "$DO_BUILD" -eq 1 ]]; then
  # shellcheck disable=SC2046
  docker build ${PLATFORM_FLAGS[@]+"${PLATFORM_FLAGS[@]}"} $(docker_build_args) -t "$IMAGE" "$DOCKER_DIR"
fi
docker image inspect "$IMAGE" >/dev/null 2>&1 || { echo "ERROR: image $IMAGE not found (use --build by default, or build it first)" >&2; exit 1; }

echo ">>> [2/4] prepare local work dir"
rm -rf "$WORK_DIR"
mkdir -p "$WORK_DIR"
cp "$DOCKER_DIR/workflow.yml" "$WORK_DIR/workflow.yml"
adjust_runtime "$WORK_DIR/workflow.yml"

# The workflow writes its results into the subfolder named by working_dir_path
# (in workflow.yml), e.g. <work>/biobb_wf_cmip/
WORK_SUBDIR="$(sed -n '/^global_properties:/,/^$/p' "$WORK_DIR/workflow.yml" \
  | sed -n 's/^ *working_dir_path: *//p' | head -1)"
CHECK_DIR="$WORK_DIR"
[[ -n "$WORK_SUBDIR" ]] && CHECK_DIR="$WORK_DIR/$WORK_SUBDIR"

echo ">>> [3/4] run container (MODE=python)"
set +e
# shellcheck disable=SC2046
docker run ${PLATFORM_FLAGS[@]+"${PLATFORM_FLAGS[@]}"} \
  --name "$CONTAINER" \
  -e MODE=python \
  -v "$WORK_DIR/workflow.yml:/data/workflow.yml:ro" \
  $(extra_data_mounts) \
  -v "$WORK_DIR:/data/wf_python" \
  "$IMAGE"
RC=$?
set -e

if [[ "$RC" -ne 0 ]]; then
  echo "FAIL: container exited with code $RC — last 50 log lines:"
  docker logs "$CONTAINER" 2>&1 | tail -50
  exit "$RC"
fi

echo ">>> [4/4] assert outputs (searched under $WORK_DIR, BioBB writes each step into its own subfolder)"
FAIL=0
for out in "${EXPECTED_OUTPUTS[@]}"; do
  found="$(find "$WORK_DIR" -type f -name "$out" 2>/dev/null | head -1)"
  if [[ -n "$found" && -s "$found" ]]; then
    echo "  PASS: $out  (in $(basename "$(dirname "$found")"))"
  else
    echo "  FAIL: not found (or empty): $out"
    FAIL=1
  fi
done
if [[ "$FAIL" -ne 0 ]]; then
  echo "  (files actually present under $WORK_DIR:)"
  find "$WORK_DIR" -maxdepth 3 -type f 2>/dev/null | sed 's/^/    /' | head -40
fi

if [[ "$FAIL" -eq 0 ]]; then
  echo "PASS: $WF_NAME docker flavour e2e test"
else
  echo "FAIL: $WF_NAME docker flavour e2e test (see missing outputs above)"
  exit 1
fi
