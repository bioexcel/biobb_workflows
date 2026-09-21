#!/usr/bin/env bash
#
# biobb_wf_cmip — airflow flavour e2e test
#
# Spins up a throwaway Airflow (docker, `airflow standalone` with cwltool
# installed), mounts a host scratch dir with the DAG + shared plugins at the
# SAME absolute path inside the container (so the host docker daemon can
# bind-mount the paths used by the nested cwltool runs), triggers the DAG and
# polls until success/failure.
#
# Layout created on the host:
#   <scratch>/dags/biobb_wf_cmip/        (copy of <wf>/airflow)
#   <scratch>/dags/airflow_cwl_utils.py  (common/airflow/dags)
#   <scratch>/plugins/{cwl_run,docker_wrapper}.sh (common/airflow/plugins)
#   <scratch>/tmp/                       (cwltool tmp prefix)
#
# The nested tool containers (quay.io/biocontainers/*) run on the HOST daemon
# via /var/run/docker.sock — same requirement as the cwl flavour.
#
# Usage:
#   ./run_test.sh [--keep]          keep scratch dir + airflow image
#   TIMEOUT_MIN=720 ./run_test.sh   overall DAG timeout (default 720 min)
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WF_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"
REPO_ROOT="$(dirname "$WF_DIR")"
WF_NAME="biobb_wf_cmip"

KEEP="${KEEP:-0}"
TIMEOUT_MIN="${TIMEOUT_MIN:-720}"
# Tag tracks the apache/airflow base version (see Dockerfile) so a base
# upgrade always rebuilds the image instead of reusing a stale one.
IMAGE="biobb-airflow-test:3.3.2"
CONTAINER="biobb-adag-${WF_NAME//\//-}-$$"

if [[ "${1:-}" == "--keep" ]]; then KEEP=1; fi

AIRFLOW_DIR="$WF_DIR/airflow"
COMMON_AIRFLOW="$REPO_ROOT/common/airflow"
HOST_DIR=""

if [[ ! -d "$AIRFLOW_DIR" ]]; then
  echo "ERROR: $AIRFLOW_DIR not found (this workflow has no airflow flavour?)" >&2
  exit 1
fi
if [[ ! -f "$COMMON_AIRFLOW/dags/airflow_cwl_utils.py" ]]; then
  echo "ERROR: $COMMON_AIRFLOW not found (wrong repo layout?)" >&2
  exit 1
fi

require() {
  command -v "$1" >/dev/null 2>&1 || { echo "ERROR: '$1' not found on PATH" >&2; exit 1; }
}
require docker
docker info >/dev/null 2>&1 || { echo "ERROR: docker daemon not reachable" >&2; exit 1; }

# ---------------- per-workflow hooks (edit when porting) ----------------
adjust_runtime() {
  # $1 = <scratch>/dags/<wf>/inputs — per-step yml files. Reduce runtimes, e.g.:
  #   sed -i -E 's/("nsteps": )[0-9]+/\1 10/g' "$1"/step*_mdrun.yml
  :
}
# --------------------------------------------------------------------------

cleanup() {
  local rc=$?
  docker rm -f "$CONTAINER" >/dev/null 2>&1 || true
  if [[ "$KEEP" -ne 1 ]]; then
    [[ -n "$HOST_DIR" ]] && rm -rf "$HOST_DIR"
  else
    echo "Kept: scratch=$HOST_DIR image=$IMAGE"
  fi
  exit "$rc"
}
trap cleanup EXIT

echo ">>> [1/6] airflow test image"
if ! docker image inspect "$IMAGE" >/dev/null 2>&1; then
  docker build -t "$IMAGE" -f "$SCRIPT_DIR/Dockerfile" "$SCRIPT_DIR"
fi

echo ">>> [2/6] host scratch dir"
HOST_DIR="$(mktemp -d "${TMPDIR:-/tmp}/biobb_airflow_${WF_NAME//\//-}_XXXXXX")"
mkdir -p "$HOST_DIR/dags" "$HOST_DIR/plugins" "$HOST_DIR/tmp"
cp -R "$AIRFLOW_DIR" "$HOST_DIR/dags/$WF_NAME"
rm -rf "$HOST_DIR/dags/$WF_NAME/outputs"   # never reuse stale outputs
cp "$COMMON_AIRFLOW/dags/airflow_cwl_utils.py" "$HOST_DIR/dags/"
cp "$COMMON_AIRFLOW/plugins/cwl_run.sh" "$COMMON_AIRFLOW/plugins/docker_wrapper.sh" "$HOST_DIR/plugins/"
chmod +x "$HOST_DIR/plugins/"*.sh
adjust_runtime "$HOST_DIR/dags/$WF_NAME/inputs"

echo ">>> [3/6] start airflow (standalone)"
docker run -d --name "$CONTAINER" \
  -v "$HOST_DIR:$HOST_DIR" \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -e AIRFLOW__CORE__DAGS_FOLDER="$HOST_DIR/dags" \
  -e PYTHONPATH="$HOST_DIR/dags" \
  -e CWL_WORKFLOWS_BASE_DIR="$HOST_DIR/dags" \
  -e CWL_TMP_DIR="$HOST_DIR/tmp" \
  -e CWL_PLUGINS_DIR="$HOST_DIR/plugins" \
  -e CWL_DOCKER_WRAPPER="$HOST_DIR/plugins/docker_wrapper.sh" \
  "$IMAGE" airflow standalone >/dev/null

echo "    waiting for airflow to be ready (up to 15 min)..."
# Do NOT probe with `airflow dags list`: every call restarts the whole CLI,
# re-parses all DAG files and grabs a write-lock on the metadata DB — on slow
# or emulated hosts those overlapping calls starve the scheduler's own parser
# (livelock, observed). Instead: a cheap, READ-ONLY query of the metadata DB;
# the DAG row only exists once the scheduler parsed the file successfully.
READY=0
for _ in $(seq 1 60); do
  if ! docker ps --format '{{.Names}}' | grep -q "^$CONTAINER$"; then
    echo "FAIL: airflow container exited during startup — log tail:"
    docker logs "$CONTAINER" 2>&1 | tail -50
    exit 1
  fi
  N="$(docker exec -e PROBE_DAG="$WF_NAME" "$CONTAINER" python3 -c '
import os, sqlite3
db = os.path.join(os.environ.get("AIRFLOW_HOME", "/opt/airflow"), "airflow.db")
try:
    c = sqlite3.connect("file:" + db + "?mode=ro", uri=True)
    print(c.execute("select count(*) from dag where dag_id=?",
                    (os.environ["PROBE_DAG"],)).fetchone()[0])
except Exception:
    print(0)
' 2>/dev/null || echo 0)"
  if [[ "$N" == "1" ]]; then
    READY=1
    break
  fi
  sleep 15
done
if [[ "$READY" -ne 1 ]]; then
  echo "FAIL: airflow did not register the DAG in 15 min — container log tail:"
  docker logs "$CONTAINER" 2>&1 | tail -50
  exit 1
fi

# Now that it is up: real import errors (if any) must not involve our DAG.
# -o json: in table mode the wide 'filepath' cell wraps, which could split
# our DAG name across lines and slip past the grep below. Empty = [].
IMPORT_ERRORS="$(docker exec "$CONTAINER" airflow dags list-import-errors -o json 2>&1 \
  | grep -vE '^(\[\]|No data found[[:space:]]*$|[[:space:]]*$)' || true)"
if [[ -n "$IMPORT_ERRORS" ]] && printf '%s' "$IMPORT_ERRORS" | grep -q "$WF_NAME"; then
  echo "FAIL: DAG import errors:"
  echo "$IMPORT_ERRORS"
  exit 1
fi

echo ">>> [4/6] trigger dag $WF_NAME"
# Airflow 3 creates new DAGs paused by default, and a manual trigger on a
# paused DAG stays in state 'queued' forever (tasks never start). Unpause.
docker exec "$CONTAINER" airflow dags unpause "$WF_NAME" >/dev/null
# -o json: the default 'table' output is a rich table that, when not on a TTY
# (docker exec), is squeezed to 200 cols and WRAPS long cells — the run id
# gets split across two lines and the grep below would capture a truncated
# id, so the state poll below would never match it. JSON is single-line.
TRIGGER_OUT="$(docker exec "$CONTAINER" airflow dags trigger "$WF_NAME" -o json 2>&1)"
echo "$TRIGGER_OUT"
RUN_ID="$(printf '%s\n' "$TRIGGER_OUT" | grep -oE 'manual__[-A-Za-z0-9.T:+_]+' | tail -1 || true)"
if [[ -z "${RUN_ID:-}" ]]; then
  # 'list-runs' takes dag_id positionally (no -d flag); -o plain (tabulate)
  # never wraps, so $2 is the full run id.
  RUN_ID="$(docker exec "$CONTAINER" airflow dags list-runs "$WF_NAME" -o plain 2>/dev/null \
    | awk 'NR>1 && $2 ~ /^manual__/{print $2}' | tail -1 || true)"
fi
if [[ -z "${RUN_ID:-}" ]]; then
  echo "FAIL: could not determine the dag run id"
  exit 1
fi
echo "    dag run id: $RUN_ID"

echo ">>> [5/6] poll state (timeout ${TIMEOUT_MIN} min)"
# Same reasoning as the readiness wait: read the state straight from the
# metadata DB (read-only) instead of starting the Airflow CLI every 30 s.
STATE=""
DEADLINE=$(( $(date +%s) + TIMEOUT_MIN * 60 ))
while (( $(date +%s) < DEADLINE )); do
  STATE="$(docker exec -e PROBE_DAG="$WF_NAME" -e PROBE_RUN="$RUN_ID" "$CONTAINER" python3 -c '
import os, sqlite3
db = os.path.join(os.environ.get("AIRFLOW_HOME", "/opt/airflow"), "airflow.db")
try:
    c = sqlite3.connect("file:" + db + "?mode=ro", uri=True)
    r = c.execute("select state from dag_run where dag_id=? and run_id=?",
                  (os.environ["PROBE_DAG"], os.environ["PROBE_RUN"])).fetchone()
    print(r[0] if r else "")
except Exception:
    print("")
' 2>/dev/null || echo "")"
  case "$STATE" in
    success|failed) break ;;
  esac
  sleep 30
done

if [[ "$STATE" != "success" ]]; then
  echo "FAIL: dag run ended in state: '${STATE:-<timeout>}'"
  echo "---- task states ----"
  docker exec "$CONTAINER" airflow tasks states-for-dag-run "$WF_NAME" "$RUN_ID" -o plain 2>&1 || true
  echo "---- logs of failed tasks (max 3) ----"
  # -o json: the table output wraps long cells when not on a TTY, which
  # shifts the awk columns; parse the single-line JSON instead.
  docker exec "$CONTAINER" airflow tasks states-for-dag-run "$WF_NAME" "$RUN_ID" -o json 2>/dev/null \
    | python3 -c '
import json, sys
try:
    rows = json.load(sys.stdin)
except Exception:
    rows = []
for r in rows:
    if r.get("state") == "failed":
        print(r.get("task_id", ""))
' | head -3 \
    | while IFS= read -r t; do
        echo "== task: $t"
        # Airflow 3: no `airflow tasks logs`; logs are structured files
        # under $AIRFLOW_HOME/logs (default /opt/airflow/logs).
        docker exec "$CONTAINER" sh -c \
          "tail -n 40 \"/opt/airflow/logs/dag_id=$WF_NAME/run_id=$RUN_ID/task_id=$t/attempt=\"*.log 2>/dev/null || echo '(no log file)'"
      done
  exit 1
fi

echo ">>> [6/6] assert per-step manifests"
FAIL=0
for d in "$HOST_DIR/dags/$WF_NAME"/outputs/step*/; do
  if [[ -f "$d/manifest.json" ]]; then
    echo "  PASS: $(basename "$d")"
  else
    echo "  FAIL: no manifest.json in $d"
    FAIL=1
  fi
done

if [[ "$FAIL" -eq 0 ]]; then
  echo "PASS: $WF_NAME airflow flavour e2e test"
else
  echo "FAIL: $WF_NAME airflow flavour e2e test (see missing manifests above)"
  exit 1
fi
