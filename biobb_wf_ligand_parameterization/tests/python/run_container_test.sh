#!/usr/bin/env bash
#
# Run the DOCKER or SINGULARITY flavour of a python workflow's step-by-step test
# WITHOUT conda. The biobb python packages are pip-installed (from the workflow's
# workflow.env.yml) and every step's executables run inside a docker or singularity
# container, as declared by the container_image / container_path properties in
# workflow.<variant>.yml.
#
# The script is workflow-agnostic: it derives the workflow dir from its own
# location (<wf>/tests/python/run_container_test.sh) unless one is given as $2.
#
# Usage:
#   run_container_test.sh <docker|singularity> [workflow_name]
#
#     <docker|singularity>  flavour -> selects workflow.<variant>.yml + runtime
#     [workflow_name]       biobb workflow dir (default: this script's workflow)
#
# Environment:
#   VENV_DIR      reuse an existing venv instead of a throwaway one
#   FULL_STEPS=1  do NOT shorten nsteps (run the full-length MD steps)
#   KEEP=1        keep the venv / scratch config / working dirs after the run
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WF_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"          # .../biobb_wf_<name>

VARIANT="${1:-}"
WF_NAME="${2:-$(basename "$WF_DIR")}"

case "$VARIANT" in
  docker | singularity) ;;
  *)
    echo "usage: $0 <docker|singularity> [workflow_name]" >&2
    exit 2
    ;;
esac

PY_DIR="$WF_DIR/python"
CONFIG_SRC="$PY_DIR/workflow.${VARIANT}.yml"
ENV_FILE="$PY_DIR/workflow.env.yml"
TEST_FILE="${WF_NAME}_${VARIANT}.py"

for f in "$CONFIG_SRC" "$ENV_FILE" "$SCRIPT_DIR/$TEST_FILE"; do
  [ -f "$f" ] || { echo "ERROR: missing $f" >&2; exit 1; }
done

# --- scratch config: shorten nsteps for a fast end-to-end MD pipeline test -----
SCRATCH="$(mktemp -d "${TMPDIR:-/tmp}/biobb_container_cfg.XXXXXX")"
CONFIG="$SCRATCH/workflow.${VARIANT}.yml"
cp "$CONFIG_SRC" "$CONFIG"
WORKDIR="$(sed -nE 's/^[[:space:]]*working_dir_path:[[:space:]]*//p' "$CONFIG" | head -n1)"
if [ -z "${FULL_STEPS:-}" ] && grep -qE '^[[:space:]]*nsteps:' "$CONFIG"; then
  sed -i.bak -E 's/^([[:space:]]*nsteps:[[:space:]]*)[0-9]+/\110/' "$CONFIG"
  rm -f "$CONFIG.bak"
  echo "==> nsteps shortened to 10 (set FULL_STEPS=1 to run full lengths)"
fi

# --- venv + pip install the biobb packages from workflow.env.yml --------------
if [ -n "${VENV_DIR:-}" ]; then
  VENV="$VENV_DIR"; VENV_OWNED=0
else
  VENV="$(mktemp -d "${TMPDIR:-/tmp}/biobb_container_venv.XXXXXX")"; VENV_OWNED=1
fi

cleanup() {
  rc=$?
  # best-effort removal of the workflow work dir (a failed step skips --remove)
  if [ -z "${KEEP:-}" ] && [ -n "${WORKDIR:-}" ]; then
    rm -rf "$SCRIPT_DIR/$WORKDIR"
    rm -f "$SCRIPT_DIR"/*.sif
  fi
  if [ "$VENV_OWNED" = "1" ] && [ -z "${KEEP:-}" ]; then
    rm -rf "$VENV"
  fi
  rm -rf "$SCRATCH"
  return $rc
}
trap cleanup EXIT

echo "==> venv at $VENV"
python3 -m venv "$VENV"
"$VENV/bin/pip" install --quiet --upgrade pip

REQS="$SCRATCH/requirements.txt"
grep -E '^[[:space:]]*-[[:space:]]*biobb_[a-z0-9_]+==' "$ENV_FILE" \
  | sed -E 's/^[[:space:]]*-[[:space:]]*//' > "$REQS"
echo "pytest" >> "$REQS"
echo "imagehash" >> "$REQS"
echo "==> pip installing:"; sed 's/^/    /' "$REQS"
"$VENV/bin/pip" install -r "$REQS"
# fail fast if any pip-installed biobb package is missing (import name == pip name)
"$VENV/bin/python" -c "import importlib; [importlib.import_module(l.split('==')[0].strip()) for l in open('$REQS') if l.startswith('biobb_')]; print('==> biobb import OK')"

# --- container runtime --------------------------------------------------------
export SINGULARITY_CACHE="${SINGULARITY_CACHE:-$SCRATCH/singularity_cache}"
mkdir -p "$SINGULARITY_CACHE"

if [ "$VARIANT" = "docker" ]; then
  command -v docker >/dev/null 2>&1 || { echo "ERROR: 'docker' not on PATH." >&2; exit 1; }
  if ! docker info >/dev/null 2>&1; then
    echo "ERROR: docker daemon not running (start Docker Desktop / 'sudo service docker start')." >&2
    exit 1
  fi
  echo "==> docker daemon OK (images pulled lazily, cached by docker)"
else
  if ! command -v singularity >/dev/null 2>&1; then
    echo "==> singularity not found, attempting install (needs sudo)..."
    if command -v apt-get >/dev/null 2>&1; then
      sudo apt-get update -y && sudo apt-get install -y singularity-container
    else
      echo "ERROR: cannot auto-install singularity on this platform." >&2; exit 1
    fi
  fi
  command -v singularity >/dev/null 2>&1 || { echo "ERROR: 'singularity' not available." >&2; exit 1; }
  echo "==> singularity: $(singularity --version 2>&1 | head -n1)"
  # Pre-pull the UNIQUE images so each package is downloaded ONCE (a workflow may
  # have many steps that all map to the same image). biobb re-issues
  # 'singularity pull' per step (a URL never 'exists'), so those only stay cheap
  # because they share this SINGULARITY_CACHE.
  echo "==> pre-pulling unique singularity images into $SINGULARITY_CACHE"
  grep -oE 'container_image:[[:space:]]*[^ ]+' "$CONFIG_SRC" \
    | sed -E 's/^container_image:[[:space:]]*//' | sort -u \
    | while read -r url; do
        echo "   pull: $url"
        ( cd "$SCRATCH" && singularity pull "$url" )
      done
fi

# --- run the step-by-step test (CWD = tests/python: file: inputs + work dir) --
cd "$SCRIPT_DIR"
echo "==> pytest $TEST_FILE --config $CONFIG --remove"
"$VENV/bin/python" -m pytest "$TEST_FILE" --config "$CONFIG" --remove
