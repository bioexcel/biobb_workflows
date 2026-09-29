#!/usr/bin/env bash
#
# biobb_wf_pmx_tutorial — docker flavour e2e test
#
# Builds the workflow docker image from <wf>/docker/Dockerfile and runs it in
# MODE=python (default), keeping all outputs inside this test folder
# (tests/docker/work/). The committed inputs (docker/pmx_tutorial/*.tpr|xtc)
# are copied into the work dir because the workflow references them with
# RELATIVE paths (pmx_tutorial/stateA.tpr, ...) resolved against the
# container CWD (/data/wf_python).
#
# The workflow is the PMX alchemical-mutation tutorial (10Ala->10Ile):
# for each state (stateA/stateB) and each extracted trajectory frame it
# runs the hybrid-topology protocol (pmx mutate, pdb2gmx, gentop, make_ndx,
# energy minimization (stateB only), equilibration and thermodynamic
# integration), then pmx_analyse (FDTI) over the collected dhdl files.
#
# Runtime: adjust_runtime below (a) reduces every mdp nsteps to 50 — the
# same reduction the CI python flavour applies (python-reusable.yaml) — and
# (b) caps the frame extraction by setting step0 skip: 50 (end stays 1000),
# leaving ~4 frames per state. The unreduced workflow extracts ~100 frames
# per state and would take hours.
# NOTE on the cap: the committed 1 ns trajectories have ~200 frames at ~5 ps
# spacing (the reference dhdl zips hold frame0-frame99 from the original
# skip: 2 run), so capping by TIME (e.g. end: 3) is a trap — gmx trjconv
# -b 1 -e 3 matches no frame at all and exits 1, which silently produced an
# empty zip and no final outputs. Capping by skip is spacing-agnostic.
#
# NOTE: the Dockerfile fetches conda_env/environment.yml, the notebook and
# python/workflow.py from GitHub *main* at build time — this test therefore
# validates the published artefact + the local Dockerfile, not unpushed
# edits. workflow.py hardcodes the pmx force-field lib under
# $CONDA_PREFIX/lib/python3.12/..., so the image env must resolve to python
# 3.12 (as the CI env does).
#
# On failure the script keeps the work dir + the container log
# (work/docker.log) and records the work dir in .e2e_workdir:
# flavour-test-reusable.yaml tars it and uploads it as the
# `e2e-workdir-biobb_wf_pmx_tutorial-docker` GitHub artefact.
#
# Usage:
#   ./run_test.sh [--no-build] [--pull] [--image TAG] [--keep]
#     --no-build   do not build the image (it must already exist locally)
#     --pull       pull ghcr.io/bioexcel/biobb_wf_pmx_tutorial:latest instead of building
#     --image TAG  image tag to build/use (default: biobb_wf_pmx_tutorial:test)
#     --keep       keep image + work/ dir after the run
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WF_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"
REPO_ROOT="$(dirname "$WF_DIR")"
WF_NAME="biobb_wf_pmx_tutorial"

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

# Final workflow outputs (step11_pmx_analyse in python/workflow.yml)
EXPECTED_OUTPUTS=(
  "pmx.txt"
  "pmx.plots.png"
)

# BSD sed (macOS) needs an empty backup suffix, GNU sed (Linux) does not
if sed --version >/dev/null 2>&1; then SED_INPLACE=(sed -i); else SED_INPLACE=(sed -i ''); fi

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
# file is stale. Same content the publish job builds locally before
# publishing, so the test builds exactly what the publish job will build.
SYNC_DIR="$(mktemp -d)"
bash "$REPO_ROOT/common/docker/sync_dockerfiles.sh" "$SYNC_DIR" >/dev/null
SYNCED_DF="$SYNC_DIR/$WF_NAME/docker/Dockerfile"

# ---------------- per-workflow hooks (edit when porting) ----------------
docker_build_args() {
  # own jupyter repo (no subrepo)
  echo "--build-arg REPO=$WF_NAME"
}

extra_data_mounts() {
  # No mounts: the workflow references its inputs with relative paths
  # (pmx_tutorial/state*.tpr|xtc) against the container CWD, so the prepare
  # step copies them into $WORK_DIR instead.
  :
}

adjust_runtime() {
  # $1 = local workflow.yml used for the run.
  # (a) same MD run reduction as the CI python flavour (python-reusable.yaml)
  "${SED_INPLACE[@]}" "s/nsteps: [0-9]*/nsteps: 50/g" "$1"
  # (b) frame cap: the unreduced step0 extracts ~100 frames per state from
  # the 1 ns trajectories (end: 1000, skip: 2). skip: 50 leaves ~4 frames —
  # a spacing-agnostic cap (the frames are ~5 ps apart, so a time-based cap
  # like end: 3 would match nothing: gmx trjconv -b 1 -e 3 exits 1). Scoped
  # to the step0 block so no other property is touched. awk (not sed)
  # because BSD sed (macOS) rejects the range+{...} block form that GNU sed
  # accepts.
  awk '
    /^step0_trjconv:/ {inblk=1}
    /^step1_pmx_mutate:/ {inblk=0}
    inblk && /^    skip: [0-9]+/ {sub(/skip: [0-9]+/, "skip: 50")}
    {print}
  ' "$1" > "$1.tmp" && mv "$1.tmp" "$1"
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
  # write into / remove $WORK_DIR (a non-root user cannot delete root-owned
  # dirs). Reuses $IMAGE, so no extra pull.
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
  # the image is kept on purpose (same tag, overwritten on next build) so
  # reruns are fast; remove it manually with: docker rmi $IMAGE
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
  # conda repodata downloads from the CDN occasionally fail transiently (5xx
  # from the conda-forge/bioconda CDN) — retry the build
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
mkdir -p "$WORK_DIR/pmx_tutorial"
cp "$DOCKER_DIR/workflow.yml" "$WORK_DIR/workflow.yml"
# relative-path inputs (see extra_data_mounts)
for f in stateA.tpr stateA_1ns.xtc stateB.tpr stateB_1ns.xtc; do
  cp "$DOCKER_DIR/pmx_tutorial/$f" "$WORK_DIR/pmx_tutorial/$f"
done
adjust_runtime "$WORK_DIR/workflow.yml"

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
