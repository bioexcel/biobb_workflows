#!/bin/bash
# Docker wrapper for cwltool on macOS Docker Desktop.
# Rewrites container-internal bind-mount paths to their Mac host equivalents
# before passing arguments to the real Docker CLI.
#
# Mapping: /opt/airflow/tmp  →  $CWL_DOCKER_TMPDIR_PREFIX (Mac host path)
#
# Usage: set --user-space-docker-cmd /opt/airflow/plugins/docker_wrapper.sh in cwltool

HOST_BASE="${CWL_DOCKER_TMPDIR_PREFIX:-.}"
HOST_BASE="${HOST_BASE%/}"          # /Users/.../docker/tmp
PROJECT_DIR="${HOST_BASE%/tmp}"     # /Users/.../docker

# Map every container-internal /opt/airflow/* path to the host equivalent.
# Container mount point  →  Mac host path
#   /opt/airflow/tmp     →  $PROJECT_DIR/tmp
#   /opt/airflow/dags    →  $PROJECT_DIR/dags
#   /opt/airflow/logs    →  $PROJECT_DIR/logs
#   /opt/airflow/plugins →  $PROJECT_DIR/plugins
#   /opt/airflow/config  →  $PROJECT_DIR/config

args=()
for arg in "$@"; do
    arg="${arg//\/opt\/airflow\/tmp/${PROJECT_DIR}/tmp}"
    arg="${arg//\/opt\/airflow\/dags/${PROJECT_DIR}/dags}"
    arg="${arg//\/opt\/airflow\/logs/${PROJECT_DIR}/logs}"
    arg="${arg//\/opt\/airflow\/plugins/${PROJECT_DIR}/plugins}"
    arg="${arg//\/opt\/airflow\/config/${PROJECT_DIR}/config}"
    args+=("$arg")
done

exec docker "${args[@]}"
