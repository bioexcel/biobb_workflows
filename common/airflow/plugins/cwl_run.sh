#!/bin/bash
set -euo pipefail

# Use AIRFLOW_HOME env var (always set by Airflow), fallback to /opt/airflow
AIRFLOW_HOME="${AIRFLOW_HOME:-/opt/airflow}"
CWL_WORKFLOWS_BASE_DIR="${AIRFLOW_HOME}/dags"
CWL_TMP_DIR="${AIRFLOW_HOME}/tmp"
CWL_PLUGINS_DIR="${AIRFLOW_HOME}/plugins"
CWL_DOCKER_WRAPPER="${CWL_PLUGINS_DIR}/docker_wrapper.sh"

INPUTS_FILE=$1
OUTPUTS_BASE_DIR=$2
OUTDIR=$3
CWL_FILE=$4
MANIFEST="${OUTDIR}/manifest.json"

# Create a unique run folder
RUN_DIR=$(mktemp -d "${CWL_TMP_DIR}/run_XXXXXX")
BASENAME=$(basename "${INPUTS_FILE}" .yml)
RESOLVED_INPUTS="${RUN_DIR}/${BASENAME}_resolved.yml"

echo "Run tmp dir: ${RUN_DIR}" >&2

# 1. Resolve cross-step input references and relative paths
python3 << EOF
import sys
sys.path.insert(0, '${CWL_WORKFLOWS_BASE_DIR}')
from airflow_cwl_utils import resolve_inputs
resolve_inputs('${INPUTS_FILE}', '${OUTPUTS_BASE_DIR}', '${RESOLVED_INPUTS}')
EOF

# 2. Check resolved file exists
if [ ! -f "${RESOLVED_INPUTS}" ]; then
    echo "ERROR: resolved inputs file not found: ${RESOLVED_INPUTS}" >&2
    exit 1
fi

# 3. Run cwltool, redirect stdout JSON → manifest.json
cwltool \
    --tmpdir-prefix "${RUN_DIR}/" \
    --tmp-outdir-prefix "${RUN_DIR}/" \
    --user-space-docker-cmd "${CWL_DOCKER_WRAPPER}" \
    --outdir "${OUTDIR}" \
    "${CWL_FILE}" \
    "${RESOLVED_INPUTS}" \
    > "${MANIFEST}"