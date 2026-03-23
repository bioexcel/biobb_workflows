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
extra_env_injected=false
# Detect if we're on ARM (Apple Silicon) running amd64 images under emulation
HOST_ARCH=$(uname -m)

# Images known to crash under QEMU due to Intel KMP affinity assertions
QEMU_BROKEN_IMAGES=(
    "quay.io/biocontainers/biobb_amber"
    "quay.io/biocontainers/biobb_pytorch"
    "quay.io/biocontainers/biobb_mem"
)

# Check if any argument matches a known broken image
needs_omp_fix=false
if [[ "$HOST_ARCH" == "arm64" || "$HOST_ARCH" == "aarch64" ]]; then
    for arg in "$@"; do
        for broken in "${QEMU_BROKEN_IMAGES[@]}"; do
            if [[ "$arg" == ${broken}* ]]; then
                needs_omp_fix=true
                break 2
            fi
        done
    done
fi

for arg in "$@"; do
    arg="${arg//\/opt\/airflow\/tmp/${PROJECT_DIR}/tmp}"
    arg="${arg//\/opt\/airflow\/dags/${PROJECT_DIR}/dags}"
    arg="${arg//\/opt\/airflow\/logs/${PROJECT_DIR}/logs}"
    arg="${arg//\/opt\/airflow\/plugins/${PROJECT_DIR}/plugins}"
    arg="${arg//\/opt\/airflow\/config/${PROJECT_DIR}/config}"
    # Inject OMP env vars and platform flag right before the image name (after --env=HOME=...)
    if [[ "$extra_env_injected" == "false" && "$arg" == --env=HOME=* ]]; then
        args+=("$arg")
        if [[ "$needs_omp_fix" == "true" ]]; then
            # Disable OpenMP thread affinity to prevent kmp_affinity.cpp assertion failures under QEMU
            args+=("--platform=linux/amd64")
            args+=("--env=OMP_NUM_THREADS=1")
            args+=("--env=OMP_PROC_BIND=false")
            args+=("--env=KMP_AFFINITY=disabled")
            args+=("--env=GOMP_SPINCOUNT=0")
            args+=("--env=KMP_HW_SUBSET=1T")
        fi
        extra_env_injected=true
        continue
    fi
    args+=("$arg")
done

exec docker "${args[@]}"
