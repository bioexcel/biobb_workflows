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

# --- docker: run the container as the invoking (host) user --------------------
# biobb's docker run has no --user by default, so the container runs as the image
# user and owns the output files it writes into the sandbox. biobb then
# post-processes those files on the host (e.g. acpype's gro/itp/top via fileinput),
# which fails with a PermissionError because the host user can't modify files it
# doesn't own. Injecting container_user_id into global_properties (biobb merges it
# into every step) makes it add `--user <uid>:<gid>`, so the container runs as the
# host user — the same default singularity already uses.
if [ "$VARIANT" = "docker" ]; then
  _UGID="$(id -u):$(id -g)"
  awk -v ins="  container_user_id: \"${_UGID}\"" \
    '{ print } /^global_properties:/ && !done { print ins; done = 1 }' \
    "$CONFIG" > "$CONFIG.tmp" && mv "$CONFIG.tmp" "$CONFIG"
  echo "==> docker: injecting container_user_id ${_UGID} (run container as host user)"
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
  | sed -E 's/^[[:space:]]*-[[:space:]]*//' \
  | sed -E 's/==([^=]+)=[A-Za-z0-9_]+$/==\1/' > "$REQS"
# (the last sed strips conda build pins like '==5.3.0=pyhdfd78af_1', which
# pip cannot parse; they only select conda builds)
echo "pytest" >> "$REQS"
echo "imagehash" >> "$REQS"
# biobb plotting tools write .jpg outputs with matplotlib; conda supplies it, but
# pip-installing the biobb_* packages omits it, so add it to the test venv.
echo "matplotlib" >> "$REQS"
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
  # Pre-pull each UNIQUE image to a local .sif (absolute path under $SCRATCH) and
  # rewrite the scratch config's container_image to that local path. biobb's
  # create_cmd_line re-issues 'singularity pull' for any container_image that is a
  # URL (a URL never Path().exists()), naming the target with a ':' taken from the
  # tag (e.g. biobb_dna:5.3.sif) which the registry rejects -> FileNotFoundError.
  # Pointing container_image at a pre-fetched local .sif makes Path(...).exists()
  # True, so biobb skips its own (failing) re-pull and execs the .sif directly.
  echo "==> pre-pulling unique singularity images to local .sif + rewriting config"
  "$VENV/bin/python" - "$CONFIG" "$SCRATCH" <<'PY'
import os, re, subprocess, sys
config, scratch = sys.argv[1], sys.argv[2]
text = open(config).read()
urls = sorted(set(re.findall(r'container_image:\s*(\S+)', text)))
if not urls:
    print("==> no container_image found; nothing to pre-pull")
    raise SystemExit(0)
for url in urls:
    name = os.path.basename(url).replace(':', '_').replace('/', '_') + '.sif'
    sif = os.path.join(scratch, name)
    if not os.path.exists(sif):
        print(f"   pull: {url} -> {sif}")
        subprocess.run(['singularity', 'pull', '--name', name, url],
                       cwd=scratch, check=True)
    text = text.replace(f'container_image: {url}', f'container_image: {sif}')
open(config, 'w').write(text)
print(f"==> {len(urls)} unique image(s) -> local .sif; config rewritten")
PY
fi

# --- ensure a host /data exists ------------------------------------------------
# biobb_curves / biobb_canal chdir the host to container_working_dir (/data, the
# container mount point) before launching. The real files live in biobb's sandbox
# (tests/python/sandbox_<uuid>), mounted at /data only *inside* the container, so
# the host has no /data and that chdir fails. Create an empty host /data so the
# chdir succeeds; the container uses its own /data (the sandbox mount) for the work.
if [ ! -d /data ]; then
  sudo mkdir -p /data 2>/dev/null || mkdir -p /data 2>/dev/null || true
  echo "==> host /data created (stub for the container chdir)"
fi

# --- concoord data files (host side) -------------------------------------------
# concoord_dist / concoord_disco copy the concoord data files (HBONDS.DAT,
# ATOMS_*.DAT, MARGINS_*.DAT, BONDS*.DAT) from $CONCOORDLIB on the HOST into the
# (container-mounted) working dir before launching the binary, so a copy of the
# concoord package must exist on the host. Fetch the exact build the
# biobb_flexdyn image pins (concoord ==2.1.2=h9ee0642_4) from bioconda into a
# scratch prefix and point CONCOORDLIB at it.
CONCOORD_TAR="linux-64/concoord-2.1.2-h9ee0642_4.tar.bz2"
CONCOORD_PREFIX="$SCRATCH/concoord"
if [ ! -f "$CONCOORD_PREFIX/share/concoord/lib/HBONDS.DAT" ]; then
  mkdir -p "$CONCOORD_PREFIX"
  echo "==> fetching concoord data files (bioconda $CONCOORD_TAR)"
  curl -fsSL -o "$SCRATCH/$CONCOORD_TAR" "https://conda.anaconda.org/bioconda/$CONCOORD_TAR"
  tar -xjf "$SCRATCH/$CONCOORD_TAR" -C "$CONCOORD_PREFIX"
  rm -f "$SCRATCH/$CONCOORD_TAR"
fi
export CONCOORDLIB="$CONCOORD_PREFIX/share/concoord/lib"
# The test builds the container-side CONCOORDLIB from $CONDA_PREFIX (biobb passes
# the step's env_vars_dict into the container); the biobb_flexdyn image keeps its
# conda env at /opt/conda. biobb itself never reads CONDA_PREFIX, so exporting it
# on the host is safe.
export CONDA_PREFIX=/opt/conda

# --- run the step-by-step test (CWD = tests/python: file: inputs + work dir) --
cd "$SCRIPT_DIR"
# Host-mode tools that shell out to a pip-installed console_script (e.g.
# extract_molecule -> check_structure from biobb_structure_checking) need the venv
# bin dir on PATH: run_biobb() spawns a shell that inherits this environment, and
# invoking "$VENV/bin/python" directly does not add "$VENV/bin" to PATH.
export PATH="$VENV/bin:$PATH"
echo "==> pytest $TEST_FILE --config $CONFIG --remove"
"$VENV/bin/python" -m pytest "$TEST_FILE" --config "$CONFIG" --remove
