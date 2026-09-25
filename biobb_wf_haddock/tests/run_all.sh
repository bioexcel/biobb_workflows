#!/usr/bin/env bash
#
# Run the flavour e2e tests for this workflow, in sequence.
#
# biobb_wf_haddock has only the jupyter flavour e2e:
#   - docker:  opted out via tests/docker/SKIP (stale docker/workflow.yml —
#             see that file)
#   - cwl / airflow: the workflow has no cwl/ or airflow/ adapters in this
#             repo
#
# Usage:
#   ./run_all.sh            # jupyter
#   KEEP=1 ./run_all.sh     # keep scratch dirs / images for inspection
#
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

if [[ $# -gt 0 ]]; then
  FLAVOURS=("$@")
else
  FLAVOURS=(jupyter)
fi

RESULTS=()
for fl in "${FLAVOURS[@]}"; do
  case "$fl" in
    jupyter) ;;
    docker)  echo "ERROR: docker e2e is opted out (tests/docker/SKIP) — see that file" >&2; exit 2 ;;
    *) echo "ERROR: unknown flavour '$fl' (biobb_wf_haddock has: jupyter)" >&2; exit 2 ;;
  esac
  echo
  echo "================ FLAVOUR: $fl ================"
  if "$fl/run_test.sh"; then
    RESULTS+=("$fl: PASS")
  else
    RESULTS+=("$fl: FAIL")
  fi
done

echo
echo "================ SUMMARY ================"
FAIL=0
for r in "${RESULTS[@]}"; do
  echo "  $r"
  [[ "$r" == *"FAIL" ]] && FAIL=1
done
exit "$FAIL"
