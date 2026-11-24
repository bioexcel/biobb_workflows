#!/usr/bin/env bash
#
# macOS check: run a workflow's tutorial notebook on a Mac the way its README tells users
#
#   git clone https://github.com/bioexcel/<repo>; cd <repo>
#   conda env create -f conda_env/environment.yml
#   jupyter-notebook <notebook>
#
# Apple Silicon first: native arm64 conda. When the env has no arm64 solution (e.g. no
# osx-arm64 build of a package), it retries with the Intel conda under Rosetta 2
# (osx-64), which is what a Mac user can do, and says so. The notebook runs headless
# (nbconvert) from its own folder of the clone, with the short-run settings of the
# wf's jupyter test (tests/jupyter/run_test.sh, one source of truth: NOTEBOOK,
# EXPECTED_OUTPUTS, adjust_runtime). The Colab cell is skipped by the notebook itself.
#
# Usage: common/macos/run_macos_test.sh <biobb_wf_folder> [--keep] [--arch arm64|x86_64]
#   --arch      force one conda (default: arm64 with x86_64 fallback; x86_64 on Intel Macs)
#   env CONDA_ARM64 / CONDA_X86_64: existing conda executables to use; otherwise Miniconda
#   is installed once under ~/.biobb_macos_conda/ (same builds as the python tests:
#   26.7.1 arm64, 25.7.0 x86_64, the last Intel build). NB_REPO_URL: a fork to clone.
# Needs macOS, git, python3, curl (Rosetta 2 for the fallback on Apple Silicon).
set -euo pipefail

WF="${1:?usage: $0 <biobb_wf_folder> [--keep] [--arch arm64|x86_64]}"; shift
KEEP=0
ARCH=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --keep) KEEP=1; shift ;;
    --arch) ARCH="$2"; shift 2 ;;
    *) echo "Unknown option: $1" >&2; exit 2 ;;
  esac
done
[[ "$(uname -s)" == Darwin ]] || { echo "ERROR: this check runs on macOS" >&2; exit 1; }

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
# shellcheck source=../notebooks/lib.sh
. "$REPO_ROOT/common/notebooks/lib.sh"
load_jupyter_settings "$REPO_ROOT/$WF"

WORK="$REPO_ROOT/_macos_work/$WF"
CONDA_HOME="$HOME/.biobb_macos_conda"
cleanup() {
  local rc=$?
  if [[ "$KEEP" -ne 1 ]]; then rm -rf "$WORK" 2>/dev/null || true; else echo "Kept: $WORK"; fi
  exit "$rc"
}
trap cleanup EXIT

conda_for() {  # arm64|x86_64 -> path of a conda executable (installs Miniconda if needed)
  local arch="$1" var build
  [[ "$arch" == arm64 ]] && var="${CONDA_ARM64:-}" || var="${CONDA_X86_64:-}"
  if [[ -n "$var" ]]; then echo "$var"; return; fi
  if [[ ! -x "$CONDA_HOME/$arch/bin/conda" ]]; then
    [[ "$arch" == arm64 ]] && build=Miniconda3-py312_26.7.1-0-MacOSX-arm64 \
                           || build=Miniconda3-py312_25.7.0-2-MacOSX-x86_64
    echo "  installing $build into $CONDA_HOME/$arch" >&2
    curl -fsSL "https://repo.anaconda.com/miniconda/$build.sh" -o "/tmp/$build.sh"
    rm -rf "$CONDA_HOME/$arch"
    bash "/tmp/$build.sh" -b -p "$CONDA_HOME/$arch" >/dev/null
    # conda-forge + bioconda only, like the env files (nodefaults): drop Anaconda's
    # defaults from Miniconda's own config (see python-reusable.yaml)
    "$CONDA_HOME/$arch/bin/conda" config --show-sources | sed -n 's/^==> \(.*\) <==$/\1/p' |
      while read -r f; do
        [[ -f "$f" ]] && "$CONDA_HOME/$arch/bin/conda" config --file "$f" --remove channels defaults 2>/dev/null || true
      done
    "$CONDA_HOME/$arch/bin/conda" config --set solver libmamba
  fi
  echo "$CONDA_HOME/$arch/bin/conda"
}

echo ">>> [1/5] clone $NB_REPO_URL (as the README says)"
rm -rf "$WORK"; mkdir -p "$WORK"
git clone --quiet --depth 1 "$NB_REPO_URL" "$WORK/repo"
ENV_FILE="$WORK/repo/conda_env/environment.yml"
NB_DIR="$WORK/repo/$(dirname "$NOTEBOOK")"
[[ -f "$ENV_FILE" ]] || { echo "ERROR: $ENV_FILE not found" >&2; exit 1; }
[[ -f "$WORK/repo/$NOTEBOOK" ]] || { echo "ERROR: notebook not found: $NOTEBOOK" >&2; exit 1; }

echo ">>> [2/5] conda env create -f conda_env/environment.yml"
if [[ -z "$ARCH" ]]; then
  [[ "$(uname -m)" == arm64 ]] && TRY=(arm64 x86_64) || TRY=(x86_64)
else
  TRY=("$ARCH")
fi
CONDA=""; USED=""
for arch in "${TRY[@]}"; do
  if [[ "$arch" == x86_64 && "$(uname -m)" == arm64 ]] && ! arch -x86_64 /usr/bin/true 2>/dev/null; then
    echo "  Rosetta 2 not available: cannot try the Intel (osx-64) conda"; break
  fi
  c="$(conda_for "$arch")"
  echo "  trying $arch conda ($("$c" --version))"
  rm -rf "$WORK/env"
  if "$c" env create -q -f "$ENV_FILE" -p "$WORK/env"; then
    CONDA="$c"; USED="$arch"; break
  fi
  echo "::warning::$WF: the env does not install with the $arch conda"
done
[[ -n "$CONDA" ]] || { echo "FAIL: $WF: the env does not install on this Mac (tried: ${TRY[*]})"; exit 1; }
[[ "$USED" == x86_64 && "$(uname -m)" == arm64 ]] && \
  echo "::notice::$WF: env installed only with the Intel conda (osx-64, Rosetta 2): no Apple Silicon solution"
echo "  env installed with the $USED conda: $("$CONDA" run -p "$WORK/env" python --version)"

echo ">>> [3/5] prepare a copy next to the notebook (short runs)"
cp "$WORK/repo/$NOTEBOOK" "$NB_DIR/_macos_check.ipynb"
adjust_runtime "$NB_DIR/_macos_check.ipynb"

echo ">>> [4/5] run it (jupyter nbconvert --execute, from the notebook's folder)"
set +e
(cd "$NB_DIR" && "$CONDA" run --no-capture-output -p "$WORK/env" jupyter nbconvert --to notebook \
   --execute --allow-errors --ExecutePreprocessor.timeout=10800 --ExecutePreprocessor.kernel_name=python3 \
   --output _macos_executed.ipynb _macos_check.ipynb)
RC=$?
set -e

echo ">>> [5/5] check the result"
EXECUTED="$NB_DIR/_macos_executed.ipynb"
if [[ "$RC" -ne 0 || ! -s "$EXECUTED" ]]; then
  echo "FAIL: the notebook run did not finish (exit code $RC)"; exit 1
fi
FAIL=0
report_executed "$EXECUTED" || FAIL=1
check_outputs "$WORK/repo" || FAIL=1
if [[ "$FAIL" -eq 0 ]]; then
  echo "PASS: $WF works on macOS ($USED conda)"
else
  echo "FAIL: $WF does not work on macOS ($USED conda)"; exit 1
fi
