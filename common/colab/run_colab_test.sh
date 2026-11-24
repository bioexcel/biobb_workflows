#!/usr/bin/env bash
#
# Colab check: run a workflow's tutorial notebook the way a Google Colab user runs it.
#
# The notebook runs inside Google's public Colab CPU image (the same software as a Colab
# CPU session: Ubuntu, Python, preinstalled packages), and its own "Only executed when
# using google colab" cell does the setup exactly as for a user: git clone of the jupyter
# repo (main), Miniforge + `mamba create` of the env, PATH and sys.path changes, chdir.
# So this catches what the Docker-based jupyter test cannot: a Colab Python that no longer
# matches the env's site-packages path, Colab's preinstalled packages shadowing the env's,
# a Miniforge/mamba that no longer installs, ...
#
# Settings come from the workflow's jupyter test (tests/jupyter/run_test.sh, one source of
# truth): the notebook path (NOTEBOOK), the files that must exist at the end
# (EXPECTED_OUTPUTS) and the short-run edits of the notebook copy (adjust_runtime).
# The notebook in the jupyter repo is never changed.
#
# Differences from a real Colab session (cannot be reproduced on GitHub's machines):
#   - no browser: widgets (NGL/Mol* viewers) are created but not displayed;
#   - Google's image can lag the live Colab by a few days (docs: googlecolab/backend-info).
#
# Usage: common/colab/run_colab_test.sh <biobb_wf_folder> [--image IMAGE] [--keep] [--prepare-only]
#   --prepare-only  stop after preparing the notebook copy (no docker; it is kept)
#   env COLAB_IMAGE overrides the default image; NB_REPO_URL a fork of the jupyter repo
#   (only for the notebook file: the Colab cell itself always clones bioexcel's main).
# Needs docker and ~25 GB of free disk (the image is ~7 GB compressed).
set -euo pipefail

WF="${1:?usage: $0 <biobb_wf_folder> [--image IMAGE] [--keep]}"; shift
IMAGE="${COLAB_IMAGE:-us-docker.pkg.dev/colab-images/public/cpu-runtime:latest}"
KEEP=0
PREPARE_ONLY=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --image) IMAGE="$2"; shift 2 ;;
    --keep)  KEEP=1; shift ;;
    --prepare-only) PREPARE_ONLY=1; KEEP=1; shift ;;
    *) echo "Unknown option: $1" >&2; exit 2 ;;
  esac
done

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
WF_DIR="$REPO_ROOT/$WF"
T="$WF_DIR/tests/jupyter/run_test.sh"
[[ -f "$T" ]] || { echo "ERROR: $T not found (the Colab check reuses the jupyter test's settings)" >&2; exit 1; }

# ---- settings from the jupyter test ------------------------------------------------
if sed --version >/dev/null 2>&1; then SED_INPLACE=(sed -i); else SED_INPLACE=(sed -i ''); fi
NB_REPO_URL_OVERRIDE="${NB_REPO_URL:-}"
unset NB_REPO_URL
eval "$(grep -E '^(WF_NAME|ENV_NAME|NOTEBOOK|NB_REPO_URL)=' "$T")"
eval "$(awk '/^EXPECTED_OUTPUTS=\(/,/^\)/' "$T")"
adjust_runtime() { :; }   # wfs without one
eval "$(awk '/^adjust_runtime\(\) \{/,/^\}/' "$T")"
NB_REPO_URL="${NB_REPO_URL_OVERRIDE:-$NB_REPO_URL}"
: "${NOTEBOOK:?NOTEBOOK= not found in $T}"

WORK="$REPO_ROOT/_colab_work/$WF"
CONTAINER="biobb-colab-${WF}-$$"

PLATFORM_FLAGS=()
if [[ "$(uname -m)" == "arm64" || "$(uname -m)" == "aarch64" ]]; then
  PLATFORM_FLAGS=(--platform linux/amd64)
  echo "WARNING: ARM host: the amd64 Colab image runs under emulation (very slow)."
fi

cleanup() {
  local rc=$?
  # the container runs as root (as Colab does): give the files back before removing them
  if [[ -d "$WORK" && "$PREPARE_ONLY" -eq 0 ]]; then
    docker run --rm ${PLATFORM_FLAGS[@]+"${PLATFORM_FLAGS[@]}"} -v "$WORK:/w" --entrypoint chown \
      "$IMAGE" -R "$(id -u):$(id -g)" /w >/dev/null 2>&1 || true
  fi
  docker rm -f "$CONTAINER" >/dev/null 2>&1 || true
  if [[ "$KEEP" -ne 1 ]]; then rm -rf "$WORK" 2>/dev/null || true; else echo "Kept: $WORK"; fi
  exit "$rc"
}
trap cleanup EXIT

echo ">>> [1/5] notebook $NOTEBOOK"
rm -rf "$WORK"; mkdir -p "$WORK"
if [[ -f "$WF_DIR/jupyter/$NOTEBOOK" && -z "$NB_REPO_URL_OVERRIDE" ]]; then
  SRC="$WF_DIR/jupyter/$NOTEBOOK"; echo "  from the checked-out submodule"
else
  echo "  cloning $NB_REPO_URL"
  git clone --quiet --depth 1 "$NB_REPO_URL" "$WORK/.nb_repo"
  SRC="$WORK/.nb_repo/$NOTEBOOK"
fi
[[ -f "$SRC" ]] || { echo "ERROR: notebook not found: $SRC" >&2; exit 1; }
cp "$SRC" "$WORK/notebook.ipynb"
rm -rf "$WORK/.nb_repo"

echo ">>> [2/5] prepare the copy (short runs + mark it as Colab)"
adjust_runtime "$WORK/notebook.ipynb"
python3 - "$WORK/notebook.ipynb" <<'PY'
import json, sys
p = sys.argv[1]
nb = json.load(open(p))
cells = nb["cells"]
if not any("google.colab" in "".join(c.get("source", [])) for c in cells):
    sys.exit("ERROR: this notebook has no Colab cell ('google.colab'): nothing to check")
# Colab's own kernel imports google.colab at start; nbconvert starts a plain kernel, so
# import it first: the notebook's `if 'google.colab' in sys.modules:` cells then run.
cells.insert(0, {"cell_type": "code", "execution_count": None, "metadata": {}, "outputs": [],
                 "source": ["# added by the Colab check: Colab's kernel imports this at start\n",
                            "import google.colab\n"]})
json.dump(nb, open(p, "w"), indent=1)
PY

if [[ "$PREPARE_ONLY" -eq 1 ]]; then echo "prepared: $WORK/notebook.ipynb"; exit 0; fi

echo ">>> [3/5] Colab image: $IMAGE"
docker image inspect "$IMAGE" >/dev/null 2>&1 || {
  for attempt in 1 2 3; do docker pull -q "$IMAGE" && break; [[ $attempt -eq 3 ]] && exit 1; sleep 30; done; }
docker run --rm ${PLATFORM_FLAGS[@]+"${PLATFORM_FLAGS[@]}"} --entrypoint bash "$IMAGE" -c \
  'echo "  $(. /etc/os-release; echo $PRETTY_NAME), $(python3 --version)"; python3 -c "import google.colab" && echo "  google.colab importable"'

echo ">>> [4/5] run it in the Colab image (cwd /content, as in Colab)"
set +e
docker run ${PLATFORM_FLAGS[@]+"${PLATFORM_FLAGS[@]}"} --name "$CONTAINER" -v "$WORK:/content" -w /content \
  --entrypoint bash "$IMAGE" -c \
  'python3 -m nbconvert --to notebook --execute --allow-errors \
     --ExecutePreprocessor.timeout=10800 --ExecutePreprocessor.kernel_name=python3 \
     --output executed.ipynb notebook.ipynb'
RC=$?
set -e

echo ">>> [5/5] check the result"
FAIL=0
EXECUTED="$WORK/executed.ipynb"
if [[ "$RC" -ne 0 || ! -s "$EXECUTED" ]]; then
  echo "FAIL: the notebook run did not finish (exit code $RC)"
  exit 1
fi
# --allow-errors runs every cell; report the setup cell's output and the FIRST error
# (later errors are usually consequences of the first)
python3 - "$EXECUTED" <<'PY' || FAIL=1
import json, re, sys
nb = json.load(open(sys.argv[1]))
strip = lambda s: re.sub(r"\x1b\[[0-9;]*m", "", s)
def text(o):
    t = o.get("text") or (o.get("data") or {}).get("text/plain") or ""
    return strip("".join(t) if isinstance(t, list) else t)
cells = [c for c in nb["cells"] if c.get("cell_type") == "code"]
setup = next((c for c in cells if "condabin/mamba" in "".join(c["source"])
              or "google.colab' in sys.modules" in "".join(c["source"])), None)
first = None
for i, c in enumerate(cells):
    errs = [o for o in c.get("outputs", []) if o.get("output_type") == "error"]
    if errs:
        first = (i, c, errs[0])
        break
if first is None:
    print("  PASS: no cell raised an error")
    sys.exit(0)
i, c, e = first
print("--- Colab setup cell, last lines of its output ---")
if setup:
    out = "".join(text(o) for o in setup.get("outputs", []))
    print("\n".join(out.splitlines()[-40:]))
print(f"--- FIRST failing cell (code cell {i}) ---")
print("".join(c["source"])[:1500])
print(f"--- error: {e.get('ename')}: {strip(e.get('evalue', ''))[:500]}")
print("\n".join(strip(l) for l in e.get("traceback", []))[-3000:])
n = sum(any(o.get("output_type") == "error" for o in c.get("outputs", [])) for c in cells)
print(f"FAIL: {n} cell(s) raised an error")
sys.exit(1)
PY
for out in "${EXPECTED_OUTPUTS[@]}"; do
  found="$(find "$WORK" -type f -name "$out" 2>/dev/null | head -1)"
  if [[ -n "$found" && -s "$found" ]]; then echo "  PASS: $out"; else echo "  FAIL: not found (or empty): $out"; FAIL=1; fi
done
if [[ "$FAIL" -eq 0 ]]; then
  echo "PASS: $WF works in Colab"
else
  echo "FAIL: $WF does not work in Colab"
  exit 1
fi
