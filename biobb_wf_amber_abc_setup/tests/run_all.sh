#!/usr/bin/env bash
#
# Run the flavour e2e tests for this workflow, in sequence.
#
# Usage:
#   ./run_all.sh                 # docker, cwl, airflow, jupyter
#   ./run_all.sh docker cwl      # selected flavours
#   KEEP=1 ./run_all.sh docker   # keep scratch dirs / images for inspection
#
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

if [[ $# -gt 0 ]]; then
  FLAVOURS=("$@")
else
  FLAVOURS=(docker cwl airflow jupyter)
fi

RESULTS=()
for fl in "${FLAVOURS[@]}"; do
  case "$fl" in
    docker|cwl|airflow|jupyter) ;;
    *) echo "ERROR: unknown flavour '$fl' (expected docker|cwl|airflow|jupyter)" >&2; exit 2 ;;
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
