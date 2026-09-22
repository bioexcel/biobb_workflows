#!/usr/bin/env bash
#
# Regenerates every <wf>/docker/Dockerfile from the template
# common/docker/Dockerfile, applying the per-workflow patches.
#
# The patches are ANCHOR-based (insert after a known line), not line-number
# based, so editing the template does not silently break the generation.
#
# Usage:
#   bash common/docker/sync_dockerfiles.sh            # overwrite in place
#   bash common/docker/sync_dockerfiles.sh /some/dir  # mirror layout into /some/dir
#
# Used by:
#   .github/workflows/docker.yaml         (commit + push the generated files)
#   .github/workflows/publish-ghcr.yaml   (local-only, so the build always
#                                          matches the current template)
#
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/../.."   # repo root

python3 - "${1:-}" <<'PY'
import os
import sys

dest_root = sys.argv[1]

with open("common/docker/Dockerfile") as f:
    template_lines = f.read().splitlines()

OPENMP_BLOCK = [
    "# Fix OpenMP issues when running amd64 image on ARM64 via QEMU emulation",
    "ENV KMP_DUPLICATE_LIB_OK=TRUE",
    "ENV OMP_NUM_THREADS=1",
    "ENV KMP_AFFINITY=disabled",
    "",
]

VARIABLES_PY_WGET = (
    "    wget https://raw.githubusercontent.com/bioexcel/$REPOSITORY/main/"
    "$REPOSITORY/notebooks/variables.py -O /app/variables.py; \\"
)
WORKFLOW_PY_WGET_ANCHOR = (
    "    wget https://raw.githubusercontent.com/bioexcel/biobb_workflows/main/"
    "$REPOSITORY/python/workflow.py -O /app/workflow.py; \\"
)
FI = "        fi; \\"  # appears twice in the template; the CMD one is the 2nd

# Per-workflow patches: (anchor line, occurrence, lines to insert AFTER it)
PATCHES = {
    "biobb_wf_amber_abc_setup": [
        (FI, 2, ['        cp -r /data/ABCix_config_files \\"$dir/ABCix_config_files\\"; \\']),
    ],
    "biobb_wf_autoencoder": [
        ("RUN conda env create -f /app/workflow.env.yml", 1, OPENMP_BLOCK),
    ],
    "biobb_wf_cmip": [
        (FI, 2, ['        cp -r /data/Files \\"$dir/Files\\"; \\']),
    ],
    "biobb_wf_dna_helparms": [
        ("ENV MODE=python", 1, [
            "# Copy the .curvesplus folder into the Docker image",
            "COPY .curvesplus /opt/conda/envs/$REPOSITORY",
            "",
        ]),
        (FI, 2, ['        cp -r /data/TRAJ \\"$dir/TRAJ\\"; \\']),
    ],
    "biobb_wf_flexserv": [
        (FI, 2, ['        cp -r /data/Files \\"$dir/Files\\"; \\']),
    ],
    "biobb_wf_haddock": [
        ("LABEL org.opencontainers.image.source https://github.com/bioexcel/biobb_workflows", 1, [
            "# Install build tools",
            "RUN apt-get update && \\",
            "    apt-get install -y build-essential && \\",
            "    rm -rf /var/lib/apt/lists/*",
            "",
        ]),
        (WORKFLOW_PY_WGET_ANCHOR, 1, [VARIABLES_PY_WGET]),
        ("        mkdir -p /data/wf_python; \\", 1,
         ["        cp /data/antibody_actpass.txt /data/*.pdb /data/wf_python/; \\"]),
        (FI, 2, ['        cp /app/variables.py \\"$dir/variables.py\\"; \\']),
    ],
    "biobb_wf_mem": [
        (WORKFLOW_PY_WGET_ANCHOR, 1, [VARIABLES_PY_WGET]),
        ("RUN conda env create -f /app/workflow.env.yml", 1, OPENMP_BLOCK),
        (FI, 2, ['        cp /app/variables.py \\"$dir/variables.py\\"; \\']),
    ],
    "biobb_wf_pmx_tutorial": [
        (FI, 2, ['        cp -r /data/pmx_tutorial \\"$dir/pmx_tutorial\\"; \\']),
    ],
}


# Per-workflow version labels: the generated file keeps its own
# LABEL version= instead of the template's, so each workflow's image can be
# versioned independently (bump the value when that workflow's image content
# changes; the publish workflow tags with the per-workflow label).
LABEL_OVERRIDES = {
    "biobb_wf_ligand_parameterization": 'LABEL version="2026.2"',
}

ENV_YML_LINE = "RUN wget https://raw.githubusercontent.com/bioexcel/$REPOSITORY/main/conda_env/environment.yml -O /app/workflow.env.yml"
NOTEBOOK_WGET_LINE = "    wget https://raw.githubusercontent.com/bioexcel/$REPOSITORY/main/$REPOSITORY/notebooks/$REPOSITORY.ipynb -O /app/notebook.ipynb; \\"

# Workflows WITHOUT their own jupyter repo: the template's downloads would 404.
# Fix: take the env file from biobb_workflows itself and skip the notebook
# (jupyter mode still works there if the user provides USER_JN).
NO_JUPYTER_REPO = {
    "biobb_wf_md_setup_mutations",
    "biobb_wf_protein_md_analysis",
}

REPLACEMENTS = {
    wf: [
        (ENV_YML_LINE, [
            "RUN wget https://raw.githubusercontent.com/bioexcel/biobb_workflows/main/$REPOSITORY/python/workflow.env.yml -O /app/workflow.env.yml",
        ]),
        (NOTEBOOK_WGET_LINE, [
            "    # no notebook for this workflow (no jupyter repo)",
            "    : ; \\",
        ]),
    ]
    for wf in NO_JUPYTER_REPO
}


def apply_patches(lines, patches, replacements):
    for anchor, occ, new_lines in patches:
        positions = [i for i, line in enumerate(lines) if line == anchor]
        if len(positions) < occ:
            raise SystemExit(f"ERROR: anchor found {len(positions)}x, expected >= {occ}: {anchor!r}")
        pos = positions[occ - 1] + 1
        lines[pos:pos] = new_lines
    for old, new in replacements:
        if old not in lines:
            raise SystemExit(f"ERROR: replacement line not found: {old!r}")
        i = lines.index(old)
        lines[i:i + 1] = new
    return lines


workflows = sorted(
    d for d in os.listdir(".")
    if d.startswith("biobb_wf_") and os.path.isdir(os.path.join(d, "docker"))
)

for wf in workflows:
    out = apply_patches(
        list(template_lines),
        PATCHES.get(wf, []),
        REPLACEMENTS.get(wf, []),
    )
    if wf in LABEL_OVERRIDES:
        for i, line in enumerate(out):
            if line.startswith("LABEL version="):
                out[i] = LABEL_OVERRIDES[wf]
                break
        else:
            raise SystemExit(f"ERROR: no LABEL version= line found for {wf}")
    target = (
        os.path.join(dest_root, wf, "docker", "Dockerfile")
        if dest_root else os.path.join(wf, "docker", "Dockerfile")
    )
    os.makedirs(os.path.dirname(target), exist_ok=True)
    with open(target, "w") as f:
        f.write("\n".join(out) + "\n")
    kind = "patched " if wf in PATCHES else ("copied  " if wf not in REPLACEMENTS else "patched ")
    print(f"{kind} {wf}")
PY
