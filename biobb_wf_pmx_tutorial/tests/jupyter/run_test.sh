#!/usr/bin/env bash
#
# biobb_wf_pmx_tutorial — jupyter flavour e2e test
#
# Executes the workflow's tutorial notebook headlessly *inside* the workflow's
# docker image (the conda env in the image ships `jupyter`):
#
#   conda run -n biobb_wf_pmx_tutorial jupyter nbconvert --to notebook --execute notebook.ipynb
#
# `nbconvert --execute` aborts with a non-zero exit code on the first cell
# that raises, so a clean run means every step worked: frame extraction from
# the state trajectories, the hybrid-topology mutation protocol (pmx mutate,
# pdb2gmx, gentop, make_ndx), energy minimization (stateB), equilibration and
# thermodynamic integration for ONE frame of each state, and the final
# pmx_analyse (FDTI) cell that produces pmx.txt + pmx.plots.png.
#
# NOTE: the notebook reads its inputs (pmx_tutorial/state{A,B}.tpr,
# pmx_tutorial/state{A,B}_1ns.xtc) from the kernel cwd — no download, no
# variables.py — so the prepare step copies the committed input files from
# <wf>/docker/pmx_tutorial/ into the work dir. This includes the
# pre-computed pmx_tutorial/dhdl{A,B}.zip: the final pmx_analyse cell uses
# those (per the notebook comment the tutorial computes only one transition,
# so the FDTI analysis uses values from a real snase run) instead of the dhdl
# files the notebook's own TI runs just wrote.
#
# Runtime: the notebook processes ONE frame per state (cell 3). Like the
# docker flavour (and the CI python flavour), adjust_runtime below reduces
# every mdp nsteps to 50 so the equilibration (10000) and thermodynamic
# integration (5000) runs finish in seconds.
#
# NOTE: the image build fetches conda_env/environment.yml + the baked
# notebook from GitHub main at build time (published artefact), but the
# executed notebook is the one from the submodule/clone below — NOT the copy
# baked into the image — so this test validates the notebook you have
# checked out.
#
# On failure the script records $WORK_DIR in .e2e_workdir next to itself;
# flavour-test-reusable.yaml tars it and uploads it as a GitHub Actions
# artefact so the cell that failed (and its logs) can be inspected.
#
# Notebook source (first hit wins):
#   1. the git submodule <wf>/jupyter/, if checked out (local
#      `git submodule update --init`, or actions/checkout with submodules: true)
#   2. a fresh shallow clone of the notebook repo into the scratch dir —
#      https://github.com/bioexcel/biobb_wf_pmx_tutorial
#      (override with NB_REPO_URL=<url>, e.g. to test a fork/branch)
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

# The conda env inside the image is named after this workflow's own jupyter
# repo (not shared with other workflows)
ENV_NAME="biobb_wf_pmx_tutorial"
NB_REPO_URL="${NB_REPO_URL:-https://github.com/bioexcel/$ENV_NAME}"

IMAGE="${WF_NAME}:test"
DO_BUILD=1
DO_PULL=0
KEEP="${KEEP:-0}"

# Notebook location inside the jupyter repo (single-workflow repo layout:
# <repo>/<repo>/notebooks/<repo>.ipynb)
NOTEBOOK="biobb_wf_pmx_tutorial/notebooks/biobb_wf_pmx_tutorial.ipynb"

# Final notebook outputs (last biobb step: pmx_analyse -> pmx.txt +
# pmx.plots.png)
EXPECTED_OUTPUTS=(
  "pmx.txt"
  "pmx.plots.png"
)

WORK_DIR="$SCRIPT_DIR/work"
CONTAINER="biobb-jtest-${WF_NAME//\//-}-$$"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --no-build) DO_BUILD=0; shift ;;
    --pull)     DO_PULL=1; DO_BUILD=0; shift ;;
    --image)    IMAGE="$2"; shift 2 ;;
    --keep)     KEEP=1; shift ;;
    *) echo "Unknown option: $1" >&2; exit 2 ;;
  esac
done

DOCKER_DIR="$WF_DIR/docker"
if [[ ! -f "$DOCKER_DIR/Dockerfile" ]]; then
  echo "ERROR: $DOCKER_DIR/Dockerfile not found (wrong repo layout?)" >&2
  exit 1
fi

# Regenerate the per-wf Dockerfile from the common template — into a TEMP
# DIR, not in place (see tests/docker/run_test.sh for why): the in-place
# mode rewrites EVERY workflow's Dockerfile and would dirty this working
# tree whenever another workflow's committed file is stale.
SYNC_DIR="$(mktemp -d)"
bash "$REPO_ROOT/common/docker/sync_dockerfiles.sh" "$SYNC_DIR" >/dev/null
SYNCED_DF="$SYNC_DIR/$WF_NAME/docker/Dockerfile"

# ---------------- per-workflow hooks (edit when porting) ----------------
docker_build_args() {
  # own jupyter repo (no subrepo)
  echo "--build-arg REPO=$WF_NAME"
}

adjust_runtime() {
  # $1 = the local copy of the notebook. Reduce every mdp nsteps to 50 (the
  # same reduction the docker flavour / CI python flavour apply): the values
  # are single-quoted Python dict literals ('nsteps':'10000'), so a plain sed
  # over the .ipynb catches all five without touching the markdown mentions
  # of nsteps.
  "${SED_INPLACE[@]}" "s/'nsteps':'[0-9]*'/'nsteps':'50'/g" "$1"
}

execute_notebook_cmd() {
  # Shell command run *inside* the container (the image ENTRYPOINT is
  # ["bash","-c"]). The kernel cwd is /data/wf_notebook (the notebook's own
  # dir), so the relative outputs (state*_frames.zip, tpr files, dhdl*.zip,
  # pmx.txt, pmx.plots.png) land in the mounted work dir.
  echo "cd /data/wf_notebook && conda run --no-capture-output -n $ENV_NAME \
    jupyter nbconvert --to notebook --execute --output executed.ipynb notebook.ipynb"
}
# --------------------------------------------------------------------------

# BSD sed (macOS) needs an empty backup suffix, GNU sed (Linux) does not
if sed --version >/dev/null 2>&1; then SED_INPLACE=(sed -i); else SED_INPLACE=(sed -i ''); fi

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
  # the image is kept on purpose (same tag as the docker test, overwritten on
  # next build) so both flavours share it and reruns are fast; remove it
  # manually with: docker rmi $IMAGE
  if [[ "$rc" -ne 0 ]]; then
    echo "Kept (failed): work=$WORK_DIR (executed notebook + outputs inside)"
  else
    rm -f "$SCRIPT_DIR/.e2e_workdir"
    if [[ "$KEEP" -ne 1 && -z "${GITHUB_ACTIONS:-}" ]]; then
      # best effort: a cleanup glitch must never mask the test result (rc)
      rm -rf "$WORK_DIR" 2>/dev/null || {
        echo "WARNING: could not remove $WORK_DIR (left in place)"
        command -v sudo >/dev/null 2>&1 && sudo rm -rf "$WORK_DIR" 2>/dev/null || true
      }
    else
      echo "Kept: image=$IMAGE work=$WORK_DIR"
    fi
  fi
  exit "$rc"
}
trap cleanup EXIT

echo ">>> [1/5] build stage (image=$IMAGE)"
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

echo ">>> [2/5] locate notebook"
rm -rf "$WORK_DIR"
mkdir -p "$WORK_DIR"
SUBMODULE_NB="$WF_DIR/jupyter/$NOTEBOOK"
if [[ -f "$SUBMODULE_NB" ]]; then
  NOTEBOOK_SRC="$SUBMODULE_NB"
  echo "  using checked-out submodule: $SUBMODULE_NB"
else
  require git
  echo "  submodule <wf>/jupyter/ not checked out — shallow-cloning $NB_REPO_URL"
  git clone --quiet --depth 1 "$NB_REPO_URL" "$WORK_DIR/nb_repo"
  NOTEBOOK_SRC="$WORK_DIR/nb_repo/$NOTEBOOK"
fi
[[ -f "$NOTEBOOK_SRC" ]] || { echo "ERROR: notebook not found: $NOTEBOOK_SRC" >&2; exit 1; }

echo ">>> [3/5] prepare work dir"
cp "$NOTEBOOK_SRC" "$WORK_DIR/notebook.ipynb"
# no variables.py for this workflow — but the notebook reads
# <cwd>/pmx_tutorial/state{A,B}.tpr|xtc (MD inputs) and
# <cwd>/pmx_tutorial/dhdl{A,B}.zip (pre-computed FDTI inputs for the final
# pmx_analyse cell), so copy all the committed inputs
mkdir -p "$WORK_DIR/pmx_tutorial"
for f in stateA.tpr stateA_1ns.xtc stateB.tpr stateB_1ns.xtc dhdlA.zip dhdlB.zip; do
  cp "$WF_DIR/docker/pmx_tutorial/$f" "$WORK_DIR/pmx_tutorial/$f"
done
adjust_runtime "$WORK_DIR/notebook.ipynb"
# record the work dir for the on-failure artefact (flavour-test-reusable.yaml
# tars + uploads it when this job fails)
echo "$WORK_DIR" > "$SCRIPT_DIR/.e2e_workdir"

echo ">>> [4/5] execute notebook in container (jupyter nbconvert --execute)"
set +e
# shellcheck disable=SC2046
docker run ${PLATFORM_FLAGS[@]+"${PLATFORM_FLAGS[@]}"} \
  --name "$CONTAINER" \
  -v "$WORK_DIR:/data/wf_notebook" \
  "$IMAGE" \
  "$(execute_notebook_cmd)"
RC=$?
set -e

if [[ "$RC" -ne 0 ]]; then
  echo "FAIL: nbconvert exited with code $RC — last 80 log lines:"
  docker logs "$CONTAINER" 2>&1 | tail -80
  exit "$RC"
fi

echo ">>> [5/5] assert outputs (searched under $WORK_DIR)"
FAIL=0

EXECUTED="$WORK_DIR/executed.ipynb"
if [[ -s "$EXECUTED" ]]; then
  echo "  PASS: executed.ipynb"
else
  echo "  FAIL: executed notebook missing or empty: $EXECUTED"
  FAIL=1
fi

# belt-and-braces: --execute already aborts on a raising cell; make sure no
# cell left an error output anyway (e.g. a kernel crash recorded by nbconvert)
if [[ -s "$EXECUTED" ]] && grep -q '"output_type"[[:space:]]*:[[:space:]]*"error"' "$EXECUTED"; then
  echo "  FAIL: executed notebook contains error outputs:"
  grep -B2 -A10 '"output_type"[[:space:]]*:[[:space:]]*"error"' "$EXECUTED" | head -40
  FAIL=1
fi

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
  echo "PASS: $WF_NAME jupyter flavour e2e test"
else
  echo "FAIL: $WF_NAME jupyter flavour e2e test (see missing outputs above)"
  exit 1
fi
