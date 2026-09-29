#!/usr/bin/env bash
#
# biobb_wf_structure_checking — docker flavour e2e test
#
# Builds the workflow docker image from <wf>/docker/Dockerfile and runs the
# SAME pytest suite the CI python flavour runs — inside the image's conda
# env — keeping all outputs inside this test folder (tests/docker/work/).
#
# The workflow is the 18-step structure quality check on the committed
# structure.pdb (1Z83): model/chain extraction, altloc/ssbond fixes, ion and
# ligand removal, hydrogen/water stripping, amide/chirality/side-chain/
# backbone fixes (the backbone is renumbered against the committed canonical
# sequence.fasta), LEAP topology, a short serial sander minimization
# (500 cycles), and the final structure_check report (step17), which the
# suite compares against the committed reference/ golden file.
#
# Runtime: no step reduction (the sander step is a short minimization), but
# the MPI sander lines are stripped from the local config copy — the image
# conda env resolves the unpinned ambertools dep to the latest nompi build
# (no sander.MPI/mpirun), exactly as the CI python flavour
# (python-reusable.yaml) does.
#
# Layout inside the container mirrors the python CI (CWD = tests/python,
# config at ../../python/workflow.yml):
#   tests/python/{biobb_wf_structure_checking.py, conftest.py,
#                 structure.pdb, sequence.fasta, reference/}
#   python/workflow.yml          (MPI sander lines stripped, see above)
# pytest is installed into the image env at run time (the env does not ship
# it; it is the only package the suite needs on top of the env). The run is
# invoked WITHOUT --remove so the final outputs stay on disk for the
# post-run file assertions.
#
# NOTE: the Dockerfile fetches conda_env/environment.yml (from the jupyter
# repo), the notebook and python/workflow.py from GitHub *main* at build
# time — this test therefore validates the published artefact + the local
# Dockerfile, not unpushed edits.
#
# On failure the script keeps the work dir + the container log
# (work/docker.log) and records the work dir in .e2e_workdir:
# flavour-test-reusable.yaml tars it and uploads it as the
# `e2e-workdir-biobb_wf_structure_checking-docker` GitHub artefact.
#
# Usage:
#   ./run_test.sh [--no-build] [--pull] [--image TAG] [--keep]
#     --no-build   do not build the image (it must already exist locally)
#     --pull       pull ghcr.io/bioexcel/biobb_wf_structure_checking:latest instead of building
#     --image TAG  image tag to build/use (default: biobb_wf_structure_checking:test)
#     --keep       keep image + work/ dir after the run
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WF_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"
REPO_ROOT="$(dirname "$WF_DIR")"
WF_NAME="biobb_wf_structure_checking"

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

# Final workflow output (step17_structure_check), written by the suite into
# the working dir (tests/python/biobb_wf_structure_checking/step17_.../)
EXPECTED_OUTPUTS=(
  "structure.report_final.json"
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

run_cmd() {
  # Shell command run *inside* the container (the image ENTRYPOINT is
  # ["bash","-c"]). Mirrors the CI python flavour invocation
  # (python-reusable.yaml): the same suite, the same config path — plus
  # `pip install pytest` (not shipped in the image env) and WITHOUT
  # --remove (keep the outputs for the assertions).
  cat <<'EOF'
cd /data/wf_python/tests/python \
  && conda run --no-capture-output -n biobb_wf_structure_checking python -m pip install --quiet pytest \
  && conda run --no-capture-output -n biobb_wf_structure_checking pytest biobb_wf_structure_checking.py --config ../../python/workflow.yml
EOF
}

adjust_runtime() {
  # $1 = the local copy of python/workflow.yml. Strip the MPI sander lines
  # (same as the CI python flavour): the image conda env has no
  # sander.MPI/mpirun (latest ambertools build is nompi), so the sander
  # minimization runs serially. No step reduction — it is a short
  # (500-cycle) minimization.
  local SED_INPLACE
  if sed --version >/dev/null 2>&1; then SED_INPLACE=(sed -i); else SED_INPLACE=(sed -i ''); fi
  "${SED_INPLACE[@]}" "/binary_path: sander.MPI/d" "$1"
  "${SED_INPLACE[@]}" "/^[[:space:]]*mpi_np: [0-9]*$/d" "$1"
  "${SED_INPLACE[@]}" "/^[[:space:]]*mpi_bin: mpirun$/d" "$1"
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

echo ">>> [2/4] prepare local work dir (python-CI layout)"
rm -rf "$WORK_DIR"
mkdir -p "$WORK_DIR/tests/python" "$WORK_DIR/python"
# the pytest suite + its committed inputs (the suite resolves structure.pdb /
# sequence.fasta relative to its own dir, exactly as in the CI python
# flavour), incl. the reference/ golden file step17 compares against
cp "$WF_DIR/tests/python/biobb_wf_structure_checking.py" "$WORK_DIR/tests/python/"
cp "$WF_DIR/tests/python/conftest.py"              "$WORK_DIR/tests/python/"
cp "$WF_DIR/tests/python/structure.pdb"            "$WORK_DIR/tests/python/"
cp "$WF_DIR/tests/python/sequence.fasta"           "$WORK_DIR/tests/python/"
cp -R "$WF_DIR/tests/python/reference"             "$WORK_DIR/tests/python/"
# the same config the CI python flavour uses, minus the MPI sander lines
# (see adjust_runtime)
cp "$WF_DIR/python/workflow.yml" "$WORK_DIR/python/workflow.yml"
adjust_runtime "$WORK_DIR/python/workflow.yml"

# A stuck suite step would otherwise hold the lane for hours; the container
# is removed by the cleanup trap if `timeout` kills the docker client.
TEST_TIMEOUT_MIN="${TEST_TIMEOUT_MIN:-120}"
echo ">>> [3/4] run the pytest suite in the container (env: $WF_NAME, timeout ${TEST_TIMEOUT_MIN} min)"
set +e
# shellcheck disable=SC2046
if command -v timeout >/dev/null 2>&1; then
  timeout --kill-after=60 "${TEST_TIMEOUT_MIN}m" \
    docker run ${PLATFORM_FLAGS[@]+"${PLATFORM_FLAGS[@]}"} \
    --name "$CONTAINER" \
    -v "$WORK_DIR:/data/wf_python" \
    "$IMAGE" \
    "$(run_cmd)"
else
  docker run ${PLATFORM_FLAGS[@]+"${PLATFORM_FLAGS[@]}"} \
    --name "$CONTAINER" \
    -v "$WORK_DIR:/data/wf_python" \
    "$IMAGE" \
    "$(run_cmd)"
fi
RC=$?
set -e

if [[ "$RC" -eq 124 || "$RC" -eq 137 ]]; then
  echo "FAIL: suite HUNG (killed after ${TEST_TIMEOUT_MIN} min) — last 50 log lines (stuck step = last step in the log):"
  docker logs "$CONTAINER" 2>&1 | tail -50
  exit "$RC"
fi
if [[ "$RC" -ne 0 ]]; then
  echo "FAIL: pytest in container exited with code $RC — last 50 log lines:"
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
  find "$WORK_DIR" -maxdepth 4 -type f 2>/dev/null | sed 's/^/    /' | head -40
fi

if [[ "$FAIL" -eq 0 ]]; then
  echo "PASS: $WF_NAME docker flavour e2e test"
else
  echo "FAIL: $WF_NAME docker flavour e2e test (see missing outputs above)"
  exit 1
fi
