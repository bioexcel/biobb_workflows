#!/usr/bin/env bash
#
# biobb_wf_autoencoder — docker flavour e2e test
#
# Builds the workflow docker image from <wf>/docker/Dockerfile and runs it in
# MODE=python (default), mounting the committed inputs (str_in.pdb,
# test_str_in.pdb, trj_in.xtc, test_trj_in.xtc — a protein apo/holo pair with
# short trajectories) read-only at /data and keeping all outputs inside this
# test folder (tests/docker/work/), so the git-tracked docker/ input folder
# is never polluted.
#
# The image is built with --build-arg REPO=biobb_wf_autoencoder (no SUBREPO —
# this workflow has its own jupyter repo, and the conda env inside the image
# is named biobb_wf_autoencoder — the same one the image CMD activates).
#
# Runtime: there is no MD to shorten (the GROMACS steps only image/fmt and
# analyse the committed trajectories), so NO runtime reduction is applied —
# the only non-trivial step is the autoencoder training (100 epochs, batch
# 128 on ~10k backbone frames), which the CI python flavour runs unreduced.
# This workflow has no MPI anywhere.
#
# NOTE: the Dockerfile fetches conda_env/environment.yml (from the jupyter
# repo), the notebook and python/workflow.py from GitHub *main* at build time
# — this test therefore validates the published artefact + the local
# Dockerfile, not unpushed edits.
#
# Usage:
#   ./run_test.sh [--no-build] [--pull] [--image TAG] [--keep]
#     --no-build   do not build the image (it must already exist locally)
#     --pull       pull ghcr.io/bioexcel/biobb_wf_autoencoder:latest instead of building
#     --image TAG  image tag to build/use (default: biobb_wf_autoencoder:test)
#     --keep       keep image + work/ dir after the run
#
# On failure the work/ dir is kept (with the container's full log saved as
# work/docker.log) and recorded in .e2e_workdir: flavour-test-reusable.yaml
# tars it and uploads it as the `e2e-workdir-biobb_wf_autoencoder-docker`
# GitHub artefact.
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WF_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"
REPO_ROOT="$(dirname "$WF_DIR")"
WF_NAME="biobb_wf_autoencoder"

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

# Final workflow outputs (last step in docker/workflow.yml:
# step14_make_plumed)
EXPECTED_OUTPUTS=(
  "plumed.dat"
  "plumed_model.ptc"
)

DOCKER_DIR="$WF_DIR/docker"
WORK_DIR="$SCRIPT_DIR/work"
CONTAINER="biobb-dtest-${WF_NAME//\//-}-$$"

if [[ ! -f "$DOCKER_DIR/Dockerfile" ]]; then
  echo "ERROR: $DOCKER_DIR/Dockerfile not found (wrong repo layout?)" >&2
  exit 1
fi

# Regenerate the per-wf Dockerfile from the common template — into a TEMP
# DIR, not in place: the in-place mode rewrites EVERY workflow's Dockerfile
# and would dirty this working tree whenever another workflow's committed
# file is stale (e.g. a docker/VERSION bump the docker.yaml bot has not
# picked up yet). Same content the publish job builds locally before
# publishing, so the test builds exactly what the publish job will build.
SYNC_DIR="$(mktemp -d)"
bash "$REPO_ROOT/common/docker/sync_dockerfiles.sh" "$SYNC_DIR" >/dev/null
SYNCED_DF="$SYNC_DIR/$WF_NAME/docker/Dockerfile"

# ---------------- per-workflow hooks (edit when porting) ----------------
docker_build_args() {
  # own jupyter repo (no subrepo)
  echo "--build-arg REPO=biobb_wf_autoencoder"
}

extra_data_mounts() {
  # inputs referenced by absolute /data/... paths in docker/workflow.yml
  # (each mounted read-only at /data/<name>)
  echo "-v $DOCKER_DIR/str_in.pdb:/data/str_in.pdb:ro -v $DOCKER_DIR/test_str_in.pdb:/data/test_str_in.pdb:ro -v $DOCKER_DIR/trj_in.xtc:/data/trj_in.xtc:ro -v $DOCKER_DIR/test_trj_in.xtc:/data/test_trj_in.xtc:ro"
}

adjust_runtime() {
  # $1 = the local copy of docker/workflow.yml. This workflow has no MD runs
  # to shorten (the GROMACS steps only image/analyse the committed
  # trajectories and the AE training is already CI-sized), so nothing to do.
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
  rm -rf "${SYNC_DIR:-}" 2>/dev/null || true
  # The container ran as root: hand the files back to the host user so we can
  # write into / remove $WORK_DIR (on GH runners the 'runner' user cannot
  # delete root-owned dirs). Reuses $IMAGE, so no extra pull.
  if [[ -d "$WORK_DIR" ]]; then
    # shellcheck disable=SC2046
    docker run --rm ${PLATFORM_FLAGS[@]+"${PLATFORM_FLAGS[@]}"} \
      -v "$WORK_DIR:/w" --entrypoint /usr/bin/chown "$IMAGE" \
      -R "$(id -u):$(id -g)" /w >/dev/null 2>&1 || true
  fi
  # On failure, keep the container log + workdir and record the workdir so
  # the on-failure artefact step (flavour-test-reusable.yaml) can tar it
  if [[ "$rc" -ne 0 && -n "${CONTAINER:-}" ]]; then
    docker logs "$CONTAINER" > "$WORK_DIR/docker.log" 2>&1 || true
    [[ -d "$WORK_DIR" ]] && echo "$WORK_DIR" > "$SCRIPT_DIR/.e2e_workdir"
  fi
  docker rm -f "$CONTAINER" >/dev/null 2>&1 || true
  # the image is kept on purpose (same tag as the jupyter test, overwritten on
  # next build) so both flavours share it and reruns are fast; remove it
  # manually with: docker rmi $IMAGE
  if [[ "$rc" -ne 0 ]]; then
    echo "Kept (failed): work=$WORK_DIR (container log: $WORK_DIR/docker.log)"
  elif [[ "$KEEP" -ne 1 ]]; then
    # best effort: a cleanup glitch must never mask the test result (rc)
    rm -rf "$WORK_DIR" 2>/dev/null || {
      echo "WARNING: could not remove $WORK_DIR (left in place)"
      command -v sudo >/dev/null 2>&1 && sudo rm -rf "$WORK_DIR" 2>/dev/null || true
    }
    rm -f "$SCRIPT_DIR/.e2e_workdir"
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
  # conda repodata downloads from the CDN occasionally fail transiently on
  # GH runners (5xx from the conda-forge/bioconda CDN) — retry the build
  BUILD_OK=0
  for attempt in 1 2 3; do
    if # shellcheck disable=SC2046
    docker build ${PLATFORM_FLAGS[@]+"${PLATFORM_FLAGS[@]}"} $(docker_build_args) -f "$SYNCED_DF" -t "$IMAGE" "$DOCKER_DIR"; then
      BUILD_OK=1
      break
    fi
    [[ "$attempt" -eq 3 ]] && break
    echo "  build attempt $attempt/3 failed — retrying in 15 s (transient conda CDN error?)"
    sleep 15
  done
  [[ "$BUILD_OK" -eq 1 ]] || { echo "ERROR: docker build failed after 3 attempts" >&2; exit 1; }
fi
docker image inspect "$IMAGE" >/dev/null 2>&1 || { echo "ERROR: image $IMAGE not found (use --build by default, or build it first)" >&2; exit 1; }

echo ">>> [2/4] prepare local work dir"
rm -rf "$WORK_DIR"
mkdir -p "$WORK_DIR"
cp "$DOCKER_DIR/workflow.yml" "$WORK_DIR/workflow.yml"
adjust_runtime "$WORK_DIR/workflow.yml"

# The workflow writes its results into the subfolder named by working_dir_path
# (in workflow.yml), e.g. <work>/biobb_wf_autoencoder/
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
