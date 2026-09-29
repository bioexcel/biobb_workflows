#!/usr/bin/env bash
#
# Run the flavour e2e tests for this workflow, in sequence.
#
# This workflow has an e2e test for the docker flavour only — there is no
# cwl/, airflow/ or jupyter/ flavour for biobb_wf_protein_md_analysis (no
# such directories, no notebook repo).
#
# Usage:
#   ./run_all.sh            # docker
#   KEEP=1 ./run_all.sh     # keep scratch dirs / images for inspection
#
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

if [[ $# -gt 0 ]]; then
  FLAVOURS=("$@")
else
  FLAVOURS=(docker)
fi

RESULTS=()
for fl in "${FLAVOURS[@]}"; do
  case "$fl" in
    docker) ;;
    jupyter|cwl|airflow)
      echo "ERROR: '$fl' is not an available flavour for biobb_wf_protein_md_analysis (no such flavour directory in the workflow)" >&2
      exit 2 ;;
    *) echo "ERROR: unknown flavour '$fl' (expected docker)" >&2; exit 2 ;;
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
