#!/usr/bin/env bash
#
# biobb_wf_haddock — jupyter flavour e2e test
#
# Executes the workflow's tutorial notebook headlessly *inside* the workflow's
# docker image (the conda env in the image ships `jupyter` + `nglview`):
#
#   conda run -n <env> jupyter nbconvert --to notebook --execute notebook.ipynb
#
# `nbconvert --execute` aborts with a non-zero exit code on the first cell that
# raises, so a clean run means every step worked (fetch 4G6K/4I1B/4G6M from
# RCSB, pdb_tools preparation, HADDOCK3 restraints, then the full docking:
# topology -> rigid_body -> capri_eval -> sele_top -> flex_ref -> capri_eval2
# -> em_ref -> capri_eval3 -> clust_fcc -> sele_top_clusts -> capri_eval4 ->
# contact_map). The script additionally asserts that the executed notebook
# contains no `error` outputs and that the final files exist and are
# non-empty.
#
# Runtime reduction: the notebook already ships the reduced docking settings
# (rigid_body sampling 10 instead of the default 1000, sele_top select 8,
# sele_top_clusts top_models 4) — the same values the CI python flavour runs
# (python/workflow.yml) — so no sampling edit is needed. adjust_runtime only
# disables the four `open_results_mod(...)` browser-open calls, which raise
# IndexError in a headless run (no jupyter server is registered, so
# list_running_servers() is empty and the servers[0] lookup fails) — local
# COPY only, the notebook in the jupyter repo is never touched.
#
# Notebook source (first hit wins):
#   1. the git submodule <wf>/jupyter/, if checked out (local
#      `git submodule update --init`, or actions/checkout with submodules: true)
#   2. a fresh shallow clone of the notebook repo into the scratch dir —
#      all jupyter repos follow the pattern https://github.com/bioexcel/<WF NAME>
#      (override with NB_REPO_URL=<url>, e.g. to test a fork/branch)
#
# NOTE: the image build fetches environment.yml + workflow.py from GitHub main
# at build time (published artefact), but the executed notebook is the one from
# the submodule/clone above — NOT the copy baked into the image at
# /app/notebook.ipynb — so this test validates the notebook you have checked out.
#
# Needs: a running docker daemon, plus network access at run time (the notebook
# fetches the 4G6K/4I1B/4G6M structures from the RCSB PDB database).
#
# Usage:
#   ./run_test.sh [--no-build] [--pull] [--image TAG] [--keep]
#     --no-build   do not build the image (it must already exist locally)
#     --pull       pull ghcr.io/bioexcel/biobb_wf_haddock:latest instead of building
#     --image TAG  image tag to build/use (default: biobb_wf_haddock:test)
#     --keep       keep image + work/ dir after the run
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WF_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"
REPO_ROOT="$(dirname "$WF_DIR")"
WF_NAME="biobb_wf_haddock"

IMAGE="${WF_NAME}:test"
DO_BUILD=1
DO_PULL=0
KEEP="${KEEP:-0}"
NB_REPO_URL="${NB_REPO_URL:-https://github.com/bioexcel/$WF_NAME}"

# Notebook location inside the jupyter repo (same pattern for every workflow:
# <wf>/notebooks/<wf>.ipynb) — workflow-specific line #1
NOTEBOOK="biobb_wf_haddock/notebooks/biobb_wf_haddock.ipynb"

# Final notebook outputs (the notebook writes them to
# data/antibody/docking/step_outputs/<step>_<name>.zip, last two steps)
# — workflow-specific line #2
EXPECTED_OUTPUTS=(
  "11_caprieval4.zip"
  "12_contact_map.zip"
)

WORK_DIR="$SCRIPT_DIR/work"
CONTAINER="biobb-jtest-${WF_NAME//\//-}-$$"

# BSD sed (macOS) needs an empty backup suffix, GNU sed (Linux) does not
if sed --version >/dev/null 2>&1; then SED_INPLACE=(sed -i); else SED_INPLACE=(sed -i ''); fi

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

# Keep the per-wf Dockerfile in sync with the common template (LOCAL ONLY,
# never committed) — see the docker flavour test.
bash "$REPO_ROOT/common/docker/sync_dockerfiles.sh" >/dev/null

# ---------------- per-workflow hooks (edit when porting) ----------------
docker_build_args() {
  # plain repo: no SUBREPO. Subrepo workflows add e.g.:
  #   echo "--build-arg REPO=biobb_wf_amber --build-arg SUBREPO=abc_setup"
  echo "--build-arg REPO=$WF_NAME"
}

adjust_runtime() {
  # $1 = the local copy of the notebook. Disables the four
  # open_results_mod(...) browser-open calls (IndexError headless — see the
  # header). No sampling edit: the notebook already ships the reduced values
  # (sampling 10 / select 8 / top_models 4), same as the CI python flavour.
  "${SED_INPLACE[@]}" "s/^open_results_mod(/# open_results_mod (headless: no jupyter server, call skipped)/" "$1"
}

execute_notebook_cmd() {
  # Shell command run *inside* the container (the image ENTRYPOINT is
  # ["bash","-c"]). The kernel cwd is /data/wf_notebook (the notebook's own
  # dir), so the relative outputs (data/antibody/...) land in the mounted
  # work dir.
  echo "cd /data/wf_notebook && conda run --no-capture-output -n $WF_NAME \
    jupyter nbconvert --to notebook --execute --output executed.ipynb notebook.ipynb"
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

echo ">>> [1/5] build stage (image=$IMAGE)"
if [[ "$DO_PULL" -eq 1 ]]; then
  IMAGE="ghcr.io/bioexcel/$WF_NAME:latest"
  docker pull "$IMAGE"
elif [[ "$DO_BUILD" -eq 1 ]]; then
  # conda repodata downloads from the CDN occasionally fail transiently on
  # GH runners (5xx from the conda-forge/bioconda CDN) — retry the build
  BUILD_OK=0
  for attempt in 1 2 3; do
    if # shellcheck disable=SC2046
    docker build ${PLATFORM_FLAGS[@]+"${PLATFORM_FLAGS[@]}"} $(docker_build_args) -t "$IMAGE" "$DOCKER_DIR"; then
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
# the notebook does `from variables import *` — ship the companion file too
cp "$(dirname "$NOTEBOOK_SRC")/variables.py" "$WORK_DIR/variables.py"
adjust_runtime "$WORK_DIR/notebook.ipynb"

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
