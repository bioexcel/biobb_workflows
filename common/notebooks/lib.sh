# Shared by the notebook checks that run a tutorial notebook outside the Docker-based
# jupyter test: common/colab/run_colab_test.sh (Google Colab image) and
# common/macos/run_macos_test.sh (a real Mac). Source it; it defines:
#
#   load_jupyter_settings <wf_dir>
#       reads the wf's tests/jupyter/run_test.sh (the one source of truth) and sets
#       WF_NAME, ENV_NAME, NOTEBOOK, NB_REPO_URL, EXPECTED_OUTPUTS (array) and the
#       function adjust_runtime <notebook> (short runs; a no-op when the wf has none).
#       NB_REPO_URL from the caller's environment wins (forks).
#   report_executed <executed.ipynb> [setup-cell-marker]
#       prints the end of the setup cell's output (the first cell containing the marker,
#       if given) and the FIRST cell that raised (later ones are usually consequences);
#       returns 1 if any cell raised.
#   check_outputs <dir>
#       every EXPECTED_OUTPUTS file must exist (anywhere under dir) and be non-empty;
#       returns 1 otherwise.

if sed --version >/dev/null 2>&1; then SED_INPLACE=(sed -i); else SED_INPLACE=(sed -i ''); fi

load_jupyter_settings() {
  local t="$1/tests/jupyter/run_test.sh" override="${NB_REPO_URL:-}"
  [[ -f "$t" ]] || { echo "ERROR: $t not found (the settings come from the jupyter test)" >&2; return 1; }
  unset NB_REPO_URL
  eval "$(grep -E '^(WF_NAME|ENV_NAME|NOTEBOOK|NB_REPO_URL)=' "$t")"
  eval "$(awk '/^EXPECTED_OUTPUTS=\(/,/^\)/' "$t")"
  adjust_runtime() { :; }
  eval "$(awk '/^adjust_runtime\(\) \{/,/^\}/' "$t")"
  NB_REPO_URL="${override:-$NB_REPO_URL}"
  [[ -n "${NOTEBOOK:-}" ]] || { echo "ERROR: NOTEBOOK= not found in $t" >&2; return 1; }
}

report_executed() {
  python3 - "$1" "${2:-}" <<'PY'
import json, re, sys
nb = json.load(open(sys.argv[1]))
marker = sys.argv[2]
strip = lambda s: re.sub(r"\x1b\[[0-9;]*m", "", s)
def text(o):
    t = o.get("text") or (o.get("data") or {}).get("text/plain") or ""
    return strip("".join(t) if isinstance(t, list) else t)
cells = [c for c in nb["cells"] if c.get("cell_type") == "code"]
first = next(((i, c, o) for i, c in enumerate(cells) for o in c.get("outputs", [])
              if o.get("output_type") == "error"), None)
if first is None:
    print("  PASS: no cell raised an error")
    sys.exit(0)
setup = next((c for c in cells if marker and marker in "".join(c["source"])), None) if marker else None
if setup:
    print("--- setup cell, last lines of its output ---")
    out = "".join(text(o) for o in setup.get("outputs", []))
    print("\n".join(out.splitlines()[-40:]))
i, c, e = first
print(f"--- FIRST failing cell (code cell {i}) ---")
print("".join(c["source"])[:1500])
print(f"--- error: {e.get('ename')}: {strip(e.get('evalue', ''))[:500]}")
print("\n".join(strip(l) for l in e.get("traceback", []))[-3000:])
n = sum(any(o.get("output_type") == "error" for o in c.get("outputs", [])) for c in cells)
print(f"FAIL: {n} cell(s) raised an error")
sys.exit(1)
PY
}

check_outputs() {
  local rc=0 out found
  for out in "${EXPECTED_OUTPUTS[@]}"; do
    found="$(find "$1" -type f -name "$out" 2>/dev/null | head -1)"
    if [[ -n "$found" && -s "$found" ]]; then echo "  PASS: $out"; else echo "  FAIL: not found (or empty): $out"; rc=1; fi
  done
  return $rc
}
