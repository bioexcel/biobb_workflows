#!/usr/bin/env bash
#
# biobb_wf_virtual-screening_fpocket — galaxy flavour test
#
# The .ga workflow runs on the BioBB Galaxy server (https://biobb.usegalaxy.es).
#  1. check: every tool the workflow uses is installed on the server (no account
#     needed). Fails if a tool is missing; versions where the server is behind or
#     newer are listed (see common/galaxy/galaxy_wf.py).
#  2. run: only when GALAXY_API_KEY is set (repository secret): imports the workflow
#     on the server, runs it, waits for every job, then cleans up.
#
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$(dirname "$(dirname "$SCRIPT_DIR")")")"
WF_NAME="biobb_wf_virtual-screening_fpocket"

python3 "$REPO_ROOT/common/galaxy/galaxy_wf.py" check "$WF_NAME"
python3 "$REPO_ROOT/common/galaxy/galaxy_wf.py" run "$WF_NAME" --timeout "${GALAXY_TIMEOUT_MIN:-600}"
