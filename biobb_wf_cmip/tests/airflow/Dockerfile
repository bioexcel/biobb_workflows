# Test-only Airflow image: official image + cwltool.
# - The docker CLI is already in the official image (installed only if missing).
# - cwltool goes into a dedicated venv: the image's pip is a guard script
#   that refuses to run as root, so we use the venv's own pip instead.
# The docker CLI lets the Airflow tasks drive the HOST daemon (the socket is
# mounted by run_test.sh); tool images (quay.io/biocontainers/*) are pulled
# on the host.
FROM apache/airflow:3.3.2

USER root
RUN if ! command -v docker >/dev/null 2>&1; then \
        apt-get update \
        && (apt-get install -y --no-install-recommends docker-ce-cli \
            || apt-get install -y --no-install-recommends docker.io \
            || apt-get install -y --no-install-recommends docker-cli) \
        && rm -rf /var/lib/apt/lists/*; \
    fi \
    && python3 -m venv /opt/cwl \
    && /opt/cwl/bin/pip install --no-cache-dir cwltool \
    && ln -sf /opt/cwl/bin/cwltool /usr/local/bin/cwltool
USER airflow
