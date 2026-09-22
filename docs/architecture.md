# Repository Architecture

## 1. Top-level layout

```
biobb_workflows/
├── biobb_wf_<name>/            # 19 workflows (see matrix below)
│   ├── README.md               # Workflow description (science + usage)
│   ├── NOTES.md                # Maintenance notes (git-ignored!)
│   ├── python/                 # Pure-python flavour (reference implementation)
│   │   ├── workflow.py         # Sequential execution of all steps
│   │   ├── workflow.yml        # Step config: tool, paths (incl. dependency/ refs), properties
│   │   ├── workflow.env.yml    # Conda env (channels + pinned biobb_* packages)
│   │   └── <input files>       # Committed input structures (pdb/top/...)
│   ├── airflow/                # Airflow flavour
│   │   ├── biobb_wf_<name>.py  # DAG: one BashOperator per step
│   │   ├── inputs/             # Per-step input-description YAML + raw input files
│   │   └── biobb_adapters/     # Per-tool CWL adapters (DockerRequirement)
│   ├── cwl/                    # CWL flavour
│   │   ├── workflow.cwl        # CWL v1.0 Workflow over the adapters
│   │   ├── workflow_input_descriptions.yml  # Flat input description (files + JSON config strings)
│   │   ├── biobb_adapters/     # Per-tool CWL CommandLineTool adapters
│   │   └── <input files>
│   ├── docker/                 # Docker flavour
│   │   ├── Dockerfile          # Generated from common/docker/Dockerfile + sed patches
│   │   ├── workflow.yml        # Copy of python/workflow.yml with /data/ absolute paths
│   │   └── <input files>
│   ├── galaxy/                 # Galaxy flavour (where present)
│   │   └── biobb_wf_<name>.ga  # Galaxy workflow export (JSON)
│   ├── jupyter/                # GIT SUBMODULE → separate bioexcel/biobb_wf_* repo
│   └── tests/
│       ├── python/             # pytest step-by-step tests (the only CI-tested flavour)
│       │   ├── biobb_wf_<name>.py
│       │   ├── conftest.py     # --config / --remove options
│       │   ├── reference/      # Golden outputs for compare_size assertions
│       │   └── <input files>
│       ├── docker/             # (new, phase 1) container e2e test
│       ├── cwl/                # (new, phase 1) cwltool e2e test
│       └── airflow/            # (new, phase 1) Airflow DAG e2e test
├── common/                     # Shared templates & code used by the CI code-generation
│   ├── docker/Dockerfile       # The single Dockerfile template
│   ├── docker/README_*.md      # README templates (common/subrepo/python variants)
│   ├── python/README_*.md      # README templates
│   ├── cwl/README.md
│   ├── galaxy/README.md
│   ├── airflow/README.md
│   ├── airflow/dags/airflow_cwl_utils.py  # Shared DAG helper (bash command builder, input resolver)
│   ├── airflow/plugins/cwl_run.sh         # cwltool wrapper used by every Airflow task
│   ├── airflow/plugins/docker_wrapper.sh  # Docker path-remap wrapper (Mac-focused)
│   └── images/                 # README images
├── .github/workflows/          # 12 workflows (see ci.md)
└── docs/                       # This documentation
```

## 2. Workflow × flavour matrix

19 workflows. `jupyter` is always a git submodule (except where absent).

| Workflow | airflow | cwl | docker | galaxy | jupyter | python |
| --- | :-: | :-: | :-: | :-: | :-: | :-: |
| biobb_wf_amber_abc_setup | ✓ | ✓ | ✓ | ✓ | ✓¹ | ✓ |
| biobb_wf_amber_md_setup | ✓ | ✓ | ✓ | ✓ | ✓¹ | ✓ |
| biobb_wf_amber_md_setup_lig | ✓ | ✓ | ✓ | ✓ | ✓¹ | ✓ |
| biobb_wf_autoencoder | ✓ | ✓ | ✓ |  | ✓ | ✓ |
| biobb_wf_cmip | ✓ | ✓ | ✓ | ² | ✓ | ✓ |
| biobb_wf_dna_helparms |  |  | ✓ |  | ✓ | ✓ |
| biobb_wf_flexdyn | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| biobb_wf_flexserv | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| biobb_wf_godmd | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| biobb_wf_haddock |  |  | ✓ |  | ✓ | ✓ |
| biobb_wf_ligand_parameterization | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| biobb_wf_md_setup | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| biobb_wf_md_setup_mutations | ✓ | ✓ | ✓ |  |  | ✓ |
| biobb_wf_mem | ✓ | ✓ | ✓ |  | ✓ | ✓ |
| biobb_wf_pmx_tutorial |  |  | ✓ |  | ✓ | ✓ |
| biobb_wf_protein-complex_md_setup | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| biobb_wf_protein_md_analysis |  |  | ✓ |  |  | ✓ |
| biobb_wf_structure_checking | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| biobb_wf_virtual-screening_fpocket | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |

¹ The three amber sub-workflows are submodules of the **same** repo `bioexcel/biobb_wf_amber`
(pinned to the same commit), each exposing a different notebook subfolder.
² `biobb_wf_cmip/galaxy/` exists locally but is git-ignored (no Galaxy workflow for cmip).

Counts: docker 19/19, python 19/19, jupyter 17/19, airflow 15/19, cwl 15/19, galaxy 11/19.

## 3. Flavour anatomy & provenance

The **step sequence** is identical across flavours (same tools, same order). Only the
execution substrate differs.

### 3.1 python (reference)
- `workflow.py`: `main(config, system)` reads `workflow.yml` with
  `biobb_common.configuration.settings.ConfReader`, then calls each step's python function
  with `**paths, properties=...`. Paths use `file:` (relative input) and
  `dependency/<step>/<output>` (cross-step) syntax, resolved by ConfReader.
- `workflow.env.yml`: conda env name + channels (`conda-forge`, `bioconda`, `nodefaults`)
  + **pinned** `biobb_*` versions (e.g. `biobb_cmip==5.2.3`). This file is what a
  "biobb version update" touches.
- Run: `python workflow.py --config workflow.yml [--system SYSTEM]`.

### 3.2 cwl
- `biobb_adapters/<tool>.cwl`: one `CommandLineTool` per biobb tool, `baseCommand` = tool
  CLI, `DockerRequirement: quay.io/biocontainers/<tool_image>:<build>` (biocontainers images,
  **not** GHCR), `--flag` input bindings, `config` input carrying JSON properties.
- `workflow.cwl`: `cwlVersion v1.0`, `class: Workflow`; one `steps/<step>` per step running
  the adapter with relative `run: biobb_adapters/<tool>.cwl` (run from the `cwl/` folder);
  workflow-level `outputs:` expose each step output.
- `workflow_input_descriptions.yml`: flat file: real inputs as `class: File, path: ...`,
  step outputs as plain strings (filenames), per-step `config` as JSON-quoted strings.
- Run: `cwltool --outdir out workflow.cwl workflow_input_descriptions.yml` (cwltool + docker).
- Provenance: generated with the biobb `cwl_wf_generator.py` utility, then manually
  corrected (see per-workflow `NOTES.md`: read-only file workarounds, removed MPI props, ...).
  **Manual re-sync required on every biobb version bump.**

### 3.3 airflow
- `biobb_wf_<name>.py`: DAG with one `BashOperator` per step; commands built by
  `create_bash_command(wf, step, tool)` from `common/airflow/dags/airflow_cwl_utils.py`.
  Explicit `>>` dependencies mirror the python step graph.
- `inputs/stepN_<tool>.yml`: per-step input description (same content as the CWL one, split
  per step) + the raw input files.
- Execution model: each task runs `plugins/cwl_run.sh` → resolves cross-step references by
  reading the previous step's `manifest.json` (cwltool stdout JSON) → runs
  `cwltool --user-space-docker-cmd plugins/docker_wrapper.sh <adapter>.cwl <resolved>.yml`
  → writes `outputs/stepN/manifest.json`. i.e. **Airflow flavour = CWL flavour orchestrated
  by Airflow**, with a manifest.json chain in place of CWL data objects.
- Env-overridable dirs: `CWL_WORKFLOWS_BASE_DIR`, `CWL_TMP_DIR`, `CWL_PLUGINS_DIR`,
  `CWL_DOCKER_WRAPPER` (defaults under `$AIRFLOW_HOME`).
- Run: any Airflow instance with `cwltool` + docker available inside the worker; trigger the
  DAG by name. (Official docs describe a docker-airflow stack.)

### 3.4 docker
- `Dockerfile`: generated artifact. `common/docker/Dockerfile` is the template; CI copies it
  into each `docker/` folder and injects per-workflow `sed` patches (extra `COPY` lines for
  input folders, OpenMP workarounds for QEMU, build tools, `variables.py` fetch, ...).
- The image **fetches at build time from GitHub `main`**: `conda_env/environment.yml` and the
  notebook from the jupyter repo (`bioexcel/<REPO>`), and `python/workflow.py` from
  `biobb_workflows`. Build args: `REPO` (required), `SUBREPO` (for amber sub-wfs and
  `biobb_wf_virtual-screening`/`fpocket`).
- Runtime contract: `VOLUME /data`; `MODE=python` (default) runs
  `python /app/workflow.py --config /data/workflow.yml` inside `/data/wf_python`;
  `MODE=jupyter` serves the notebook on :8888; optional `USER_PY` / `USER_JN` overrides.
- The per-workflow `docker/workflow.yml` is the python one with `/data/` absolute input paths
  (and, e.g., MPI props removed for cmip).
- Published to GHCR: `ghcr.io/bioexcel/<wf>:<version>` + `:latest`
  (version = `LABEL version=` in `<wf>/docker/Dockerfile`; may differ per workflow via
  `LABEL_OVERRIDES` in `common/docker/sync_dockerfiles.sh`).
- Run: `docker run -v <inputs>:/data ghcr.io/bioexcel/<wf>`.

### 3.5 galaxy
- Single exported workflow file `biobb_wf_<name>.ga` (JSON, `format-version 0.1`), steps
  referencing BioBB Galaxy tools by `content_id` (e.g. `biobb_io_pdb_ext`), with
  `input_connections` wiring. Target server: INB's Galaxy (biobb.usegalaxy.es).

### 3.6 jupyter (submodule)
- Separate repos `bioexcel/biobb_wf_<name>` mounted at `<wf>/jupyter`; layout:
  `biobb_wf_<name>/notebooks/*.ipynb` (+`html`, `docs`), `conda_env/environment.yml`
  (the **same** env file the Docker image installs), `binder/` (myBinder),
  `.readthedocs.yaml` (docs), `CITATION.cff`.
- The notebook mirrors the python steps interactively.

## 4. `common/` and the CI code-generation loop

CI *commits generated files back to the repo* (via a GitHub App token, actor
`github-actions[bot]`):

| Template in `common/` | Generated artefacts | CI workflow |
| --- | --- | --- |
| `docker/Dockerfile` | `<wf>/docker/Dockerfile` (anchor-patched per wf by `sync_dockerfiles.sh`, incl. label overrides) | `docker.yaml` |
| `python/README_common.md`, `README_subrepo.md` | `<wf>/python/README.md` (placeholder `s/<repository>/.../`) | `python_readme.yaml` |
| `docker/README_*.md` | `<wf>/docker/README.md` | `docker_readme.yaml` |
| `cwl/README.md` | `<wf>/cwl/README.md` (few per-wf sed notes) | `cwl_readme.yaml` |
| `galaxy/README.md` | `<wf>/galaxy/README.md` | `galaxy_readme.yaml` |
| `airflow/README.md` | `<wf>/airflow/README.md` (`++repository++` placeholder) | `airflow_readme.yaml` |

Consequences:
- Editing a `common/` template triggers regeneration + bot commit on **all** affected
  workflow folders (this is why test path-filtering must ignore bot commits — see ci.md).
- The per-workflow generated files must not be hand-edited (they get overwritten).
- The `sed` patches are **line-number based** against `common/docker/Dockerfile`
  (e.g. `sed -i '83a\...'`): a one-line change in the template silently shifts every patch.

## 5. Submodules

- Every jupyter flavour is a submodule (`.gitmodules`), all on `branch = main` of their
  respective bioexcel repos. The 3 amber entries point to the same repo/commit.
- The Docker image build and the (future) jupyter tests depend on the *published* submodule
  content on `main`, while the repo pins a commit — a bump of the submodule pointer does not
  change what `docker build` installs until the jupyter repo's `main` matches.
- Clone requires `git clone --recursive` (or `git submodule update --init --recursive`).

## 6. Testing data

- `tests/python/` contains the committed inputs (pdb/top/nc/xtc/zip, ...) and a
  `reference/` tree with golden outputs used by `fx.compare_size` (size-within-N-bytes)
  assertions in the final step(s). 18/19 workflows have reference data.
- Each flavour folder also carries its own copy of the raw inputs (they are *not* shared
  across flavours).
- `NOTES.md` (per wf) documents the manual fixes applied to the generated CWL/Airflow files —
  it is git-ignored, so this knowledge is currently not shared with the rest of the org.
