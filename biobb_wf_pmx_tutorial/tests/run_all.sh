#!/usr/bin/env bash
#
# Run the flavour e2e tests for this workflow, in sequence.
#
# This workflow has e2e tests for the docker and jupyter flavours only —
# there is no cwl/ or airflow/ flavour directory for biobb_wf_pmx_tutorial.
#
# Usage:
#   ./run_all.sh              # docker, jupyter
#   ./run_all.sh docker       # selected flavours
#   KEEP=1 ./run_all.sh       # keep scratch dirs / images for inspection
#
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

if [[ $# -gt 0 ]]; then
  FLAVOURS=("$@")
else
  FLAVOURS=(docker jupyter)
fi

RESULTS=()
for fl in "${FLAVOURS[@]}"; do
  case "$fl" in
    docker|jupyter) ;;
    cwl|airflow)
      echo "ERROR: '$fl' is not an available flavour for biobb_wf_pmx_tutorial (no cwl/ or airflow/ directory in the workflow)" >&2
      exit 2 ;;
    *) echo "ERROR: unknown flavour '$fl' (expected docker|jupyter)" >&2; exit 2 ;;
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
