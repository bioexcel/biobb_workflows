import json
import os
import re
import yaml

# Use AIRFLOW_HOME env var (always set by Airflow), fallback to /opt/airflow
_AIRFLOW_HOME = os.environ.get("AIRFLOW_HOME", "/opt/airflow")

WORKFLOWS_BASE_DIR = os.environ.get("CWL_WORKFLOWS_BASE_DIR", os.path.join(_AIRFLOW_HOME, "dags"))
TMP_DIR = os.environ.get("CWL_TMP_DIR", os.path.join(_AIRFLOW_HOME, "tmp"))
PLUGINS_DIR = os.environ.get("CWL_PLUGINS_DIR", os.path.join(_AIRFLOW_HOME, "plugins"))
CWL_DOCKER_WRAPPER = os.environ.get("CWL_DOCKER_WRAPPER", os.path.join(_AIRFLOW_HOME, "plugins", "docker_wrapper.sh"))


def resolve_inputs(inputs_path, outputs_base_dir, resolved_path=None):
    """
    Reads a step inputs YAML and resolves:
    1. Cross-step references:  step2_babel_minimize/output_path
    2. Relative file paths:    ligand.pdb
    Writes resolved YAML to resolved_path (or /opt/airflow/tmp if not specified).
    """
    inputs_dir = os.path.dirname(os.path.abspath(inputs_path))

    with open(inputs_path) as f:
        inputs = yaml.safe_load(f)

    resolved = {}
    for key, value in inputs.items():
        if isinstance(value, dict) and "path" in value:
            path = value["path"]
            cross_step_match = re.match(r'^(step\w+)/(\w+)$', path)
            if cross_step_match:
                ref_step, ref_key = cross_step_match.groups()
                manifest_path = os.path.join(outputs_base_dir, ref_step, "manifest.json")
                with open(manifest_path) as mf:
                    manifest = json.load(mf)
                abs_path = manifest[ref_key]["location"].replace("file://", "")
                resolved[key] = {**value, "path": abs_path}
            elif not os.path.isabs(path):
                resolved[key] = {**value, "path": os.path.join(inputs_dir, path)}
            else:
                resolved[key] = value
        else:
            resolved[key] = value

    # Use provided path or default
    if resolved_path is None:
        basename = os.path.basename(inputs_path).replace(".yml", "_resolved.yml")
        resolved_path = os.path.join(TMP_DIR, basename)

    with open(resolved_path, "w") as f:
        yaml.dump(resolved, f)

    return resolved_path


def create_bash_command(wf_name, step, tool):
    workflows_dir = f"{WORKFLOWS_BASE_DIR}/{wf_name}"
    inputs_dir = f"{workflows_dir}/inputs"
    outputs_dir = f"{workflows_dir}/outputs"
    outdir = f"{outputs_dir}/{step}"
    inputs_file = f"{inputs_dir}/{step}.yml"
    cwl_file = f"{workflows_dir}/biobb_adapters/{tool}.cwl"

    return (
        f"mkdir -p {outdir} && "
        f"{PLUGINS_DIR}/cwl_run.sh "
        f"{inputs_file} "
        f"{outputs_dir} "
        f"{outdir} "
        f"{cwl_file}"
    )
