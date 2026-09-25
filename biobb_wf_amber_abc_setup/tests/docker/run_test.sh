#!/usr/bin/env bash
#
# biobb_wf_amber_abc_setup — docker flavour e2e test
#
# Builds the workflow docker image from <wf>/docker/Dockerfile and runs it in
# MODE=python (default), mounting the committed inputs (sequence.pdb and the
# ABCix_config_files/ mdin set) read-only at /data and keeping all outputs
# inside this test folder (tests/docker/work/), so the git-tracked docker/
# input folder is never polluted.
#
# Subrepo workflow: the image is built with --build-arg REPO=biobb_wf_amber
# --build-arg SUBREPO=abc_setup (the jupyter repo biobb_wf_amber is shared by
# the amber subrepos, and the conda env inside the image is named
# biobb_wf_amber — the same one the image CMD activates).
#
# Runtime: the python flavour runs sander.MPI (mpi_np in python/workflow.yml);
# docker/workflow.yml strips those MPI lines, so the sander steps here are
# serial. All sander steps are shortened with the same values the CI python
# flavour uses (.github/workflows/python-reusable.yaml: nstlim -> 100,
# maxcyc -> 50) — the un-reduced workflow would run ~100 ps of production MD.
#
# NOTE: the Dockerfile fetches conda_env/environment.yml (from the jupyter
# repo), the notebook and python/workflow.py from GitHub *main* at build time
# — this test therefore validates the published artefact + the local
# Dockerfile, not unpushed edits.
#
# Usage:
#   ./run_test.sh [--no-build] [--pull] [--image TAG] [--keep]
#     --no-build   do not build the image (it must already exist locally)
#     --pull       pull ghcr.io/bioexcel/biobb_wf_amber_abc_setup:latest instead of building
#     --image TAG  image tag to build/use (default: biobb_wf_amber_abc_setup:test)
#     --keep       keep image + work/ dir after the run
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WF_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"
REPO_ROOT="$(dirname "$WF_DIR")"
WF_NAME="biobb_wf_amber_abc_setup"

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

# Final workflow outputs (last steps in docker/workflow.yml: the production
# MD trajectory and the solute-imaged XTC from step30_cpptraj_image).
EXPECTED_OUTPUTS=(
  "sander.md.netcdf"
  "setup.imaged_traj.xtc"
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
  # subrepo workflow: the jupyter repo is shared (biobb_wf_amber), this is
  # the abc_setup subrepo of it
  echo "--build-arg REPO=biobb_wf_amber --build-arg SUBREPO=abc_setup"
}

extra_data_mounts() {
  # inputs referenced by absolute /data/... paths in docker/workflow.yml
  # (each mounted read-only at /data/<name>)
  echo "-v $DOCKER_DIR/sequence.pdb:/data/sequence.pdb:ro"
  echo "-v $DOCKER_DIR/ABCix_config_files:/data/ABCix_config_files:ro"
}

adjust_runtime() {
  # $1 = the local copy of docker/workflow.yml. Shorten every sander step
  # with the same values the CI python flavour uses
  # (.github/workflows/python-reusable.yaml): nstlim -> 100, maxcyc -> 50.
  # (No mpi_np line exists in this yml — the docker flavour runs serial
  # sander, see the header.)
  # BSD sed (macOS) needs an empty backup suffix, GNU sed (Linux) does not
  local SED_INPLACE
  if sed --version >/dev/null 2>&1; then SED_INPLACE=(sed -i); else SED_INPLACE=(sed -i ''); fi
  "${SED_INPLACE[@]}" "s/nstlim: [0-9]*/nstlim: 100/g" "$1"
  "${SED_INPLACE[@]}" "s/maxcyc: [0-9]*/maxcyc: 50/g" "$1"
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
  # The container ran as root: hand the files back to the host user so the rm
  # below works (on GH runners the 'runner' user cannot delete root-owned
  # dirs). Reuses $IMAGE, so no extra pull.
  if [[ -d "$WORK_DIR" ]]; then
    # shellcheck disable=SC2046
    docker run --rm ${PLATFORM_FLAGS[@]+"${PLATFORM_FLAGS[@]}"} \
      -v "$WORK_DIR:/w" --entrypoint /usr/bin/chown "$IMAGE" \
      -R "$(id -u):$(id -g)" /w >/dev/null 2>&1 || true
  fi
  docker rm -f "$CONTAINER" >/dev/null 2>&1 || true
  # the image is kept on purpose (same tag as the jupyter test, overwritten on
  # next build) so both flavours share it and reruns are fast; remove it
  # manually with: docker rmi $IMAGE
  if [[ "$KEEP" -ne 1 ]]; then
    # best effort: a cleanup glitch must never mask the test result (rc)
    rm -rf "$WORK_DIR" 2>/dev/null || {
      echo "WARNING: could not remove $WORK_DIR (left in place)"
      command -v sudo >/dev/null 2>&1 && sudo rm -rf "$WORK_DIR" 2>/dev/null || true
    }
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
# (in workflow.yml), e.g. <work>/biobb_wf_amber_abc_setup/
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
