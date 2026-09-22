# CI / CD — GitHub Actions & Runner Infrastructure

## 1. Workflow inventory (`.github/workflows/`)

### Test workflows

| File | Trigger | Runner | Purpose |
| --- | --- | --- | --- |
| `detect.yaml` | `workflow_call` (inputs: `wf_names`, `all_on_paths`, `require_path`, `flavour`) | `ubuntu-latest` | **Shared brain**: decides *which* workflows a test run must cover and emits a JSON matrix `[{wf, runs_on}]`. Rules: push → folders changed in the push (all, if a CI file matched by `all_on_paths` changed); manual → `wf_names` (empty = all); scheduled → all. `require_path` restricts to workflows that contain a given file (used by the flavour tests) |
| `python-tests.yaml` | `push` + weekly `schedule` (Mon 04:00 UTC) + `workflow_dispatch` (input `wf_names`) | `ubuntu-latest` (per job) | The python step-by-step pytest pipeline: `detect` → one call of `python-reusable.yaml` per selected workflow. Skips pushes made by `github-actions[bot]` (the sync bot) |
| `python-reusable.yaml` | `workflow_call` (`wf_name`, optional `runs_on`) | input-driven | Per-workflow python test: checkout → per-wf `sed` runtime reductions → micromamba env from `<wf>/python/workflow.env.yml` (+`pytest`, `imagehash`) → `pytest <wf>.py --config ../../python/workflow.yml --remove`. `timeout-minutes: 720` |
| `flavour-tests.yaml` | `workflow_dispatch` only (inputs: `flavour` = docker/cwl/airflow/jupyter/python, `wf_names`) | `ubuntu-latest` (per job) | Phase-1 e2e tests for the other flavours: `detect` (only workflows that have `tests/<flavour>/run_test.sh`; for python, the `tests/python/` dir = every wf) → one call of `flavour-test-reusable.yaml` each. Manual on purpose — see phase 2 to add a push trigger. Concurrency group includes the flavour, so the 5 flavours can run in parallel |
| `flavour-test-reusable.yaml` | `workflow_call` (`wf_name`, `flavour`, optional `runs_on`) | input-driven | Runs `<wf>/tests/<flavour>/run_test.sh` (installs `cwltool` via micromamba for the cwl flavour). `timeout-minutes: 720`. The **python** flavour has no script: the job delegates to `python-reusable.yaml` (the CI python pipeline, so manual and automatic runs can never drift) |

### Code-generation & publishing workflows (they commit/publish, they do not test)

| File | Trigger | Runner | Purpose |
| --- | --- | --- | --- |
| `docker.yaml` | push to `common/docker/Dockerfile` or `common/docker/sync_dockerfiles.sh` + dispatch | `ubuntu-latest` | **Code generation**: runs `common/docker/sync_dockerfiles.sh` (regenerates all 19 per-wf Dockerfiles from the template with anchor-based patches, keeping per-wf `LABEL version=` overrides — see §1.2), commits + pushes if anything changed (`github-actions[bot]`). A push of per-wf Dockerfiles triggers **no** publish |
| `publish-ghcr.yaml` | push to `main` touching `common/docker/Dockerfile` (all images) + `workflow_dispatch` (input `wf`: one workflow or `all`) | `ubuntu-latest` (per image) | Builds + pushes GHCR images, **one job per workflow** (matrix filled by a `select` job from the `wf` input; `fail-fast: false`). Each image is tagged with **its own** `LABEL version=` from `<wf>/docker/Dockerfile` + `latest`. Runs the sync script **locally first** (not committed), so a build can never use stale per-wf Dockerfiles. See §1.2 for the update flow |
| `retag-ghcr.yaml` | `workflow_dispatch` (inputs: `wf`, `source` = tag or `sha256:` digest, `tag`) | `ubuntu-latest` | **Tag surgery without rebuilding**: pulls an existing image from GHCR (by digest or tag) and pushes it under a new tag. Use it to restore an overwritten version tag or assign a proper tag — the old digest of an overwritten tag is visible on the package *versions* page (`github.com/orgs/bioexcel/packages/container/<wf>/versions`) even though it has no tag |
| `python_readme.yaml` | push to `common/python/README_*.md` + dispatch | `ubuntu-latest` | Regenerates `<wf>/python/README.md` (cp + `sed` placeholders), bot commit |
| `docker_readme.yaml` | push to `common/docker/README_*.md` + dispatch | `ubuntu-latest` | Same for `docker/README.md` |
| `cwl_readme.yaml` | push to `common/cwl/README.md` + dispatch | **`self-hosted`** | Same for `cwl/README.md` |
| `galaxy_readme.yaml` | push to `common/galaxy/README.md` + dispatch | **`self-hosted`** | Same for `galaxy/README.md` |
| `airflow_readme.yaml` | push to `common/airflow/README.md` + dispatch | `ubuntu-latest` | Same for `airflow/README.md` |
| `citation.yaml` | weekly cron (Mon 00:00) + push to `main` | `ubuntu-latest` | Syncs `CITATION.cff` from `bioexcel/biobb` main; bot commit if changed |
| `inactive_issues.yml` | daily cron | **`self-hosted`** | `actions/stale@v5`: stale after 30d, close after 14d more |

Secrets / vars used: `vars.GHAPUSH` (GitHub App ID) + `secrets.GHAPUSH` (app private key)
for the bot commits via `peter-murray/workflow-application-token-action@v3`;
`secrets.GH_PAT` for GHCR login.

### 1.1 How the test selection works (the "only test what I changed" rule)

1. `detect.yaml` checks out with full history and compares the push
   (`git diff <before>..<sha>`; new branches compare against the default branch).
2. Every changed path starting with `biobb_wf_` selects that workflow; a change to the
   test-workflow files themselves (`detect|python-tests|python-reusable` for the python
   pipeline, the equivalent for the flavour pipeline) selects **all** workflows.
3. The selected list becomes a matrix; each entry is one job. `workflow_dispatch` lets
   you force a subset (`wf_names=biobb_wf_cmip`) or everything (empty).
4. Pushes by `github-actions[bot]` (Dockerfile/README sync) are ignored entirely.

Verified locally against real commit pairs: a cmip-only commit selects only cmip; a CI-file
commit selects all 19; `require_path: tests/docker/run_test.sh` selects exactly the
workflows that have a docker test.

### 1.2 The per-workflow update flow (version bump → tests → image)

Bumping a tool version (e.g. `biobb_chemistry`) for **one** workflow, end to end:

1. **Update the pins** (the 5+2 places, see architecture.md):
   - this repo: `<wf>/python/workflow.env.yml`, one `dockerPull:` line per adapter in
     `<wf>/cwl/biobb_adapters/*.cwl` and `<wf>/airflow/biobb_adapters/*.cwl`
   - jupyter repo (`bioexcel/<wf>`, the submodule): `conda_env/environment.yml` +
     `binder/environment.yml`. **Push the jupyter repo first** — the docker image (and the
     jupyter e2e test in CI) fetch `conda_env/environment.yml` from its `main` at build time.
   - Then commit in this repo, including the submodule pointer bump.
2. **Test**: python tests auto-run on the push (no path filter); the docker/cwl/airflow/jupyter
   e2e runs are triggered manually via "Flavour e2e Tests" (one run per flavour).
3. **Bump the image label** (so the new content gets a new tag and the old image keeps its
   tag): set the value in `LABEL_OVERRIDES` in `common/docker/sync_dockerfiles.sh`, then push.
   The `docker.yaml` bot re-generates `<wf>/docker/Dockerfile` with the new label and bot-commits
   it; **no publish is triggered** (the publisher's push path is the template only).
4. **Publish**: Actions → "Docker Image CI for GHCR" → Run workflow → `wf: <wf>` → one image
   built + pushed as `<wf>:<new label>` + `<wf>:latest`. Other workflows' images/tags are
   untouched.

Rules this design gives:

- Each image is versioned independently (its own `LABEL version=`); a template change still
  rebuilds **all** images (shared base), re-pushing them under their own current labels.
- Pushing per-wf Dockerfiles or any non-template path never triggers a publish.
- Overwrote a tag by mistake? The old image survives in the registry by digest (package
  versions page) — restore it with `retag-ghcr.yaml`.

## 2. Self-hosted runner infrastructure (`web_microservices/gh_runner`)

Deployment: **Docker Swarm stack on a remote Linux server**, service `gh_runner_biobb`:

- Image: `myoung34/github-runner:latest` (auto register/deregister).
- **Org-level registration** (`RUNNER_SCOPE: org`, org `bioexcel`) → available to every
  bioexcel repo.
- **Ephemeral** runners (`EPHEMERAL: "true"`): fresh container per job, deregisters after.
- Labels: `self-hosted,linux,mmbswarm` (from `.env`; not committed — `.env` holds the PAT).
- Replicas: 3 concurrent (`.env`), each limited to **4 CPUs / 4 GiB** (`deploy.resources`).
- **`/var/run/docker.sock` is mounted into the runner container.**
- `RUNNER_WORKDIR: /tmp/runner/work`, auto-update disabled (image version pinned).

Usage in this repo today: only `cwl_readme.yaml`, `galaxy_readme.yaml`,
`inactive_issues.yml` use `runs-on: self-hosted`. All test jobs use `ubuntu-latest`
(GitHub-hosted, 2 vCPU / 7 GiB), because the self-hosted pool does not carry an
`ubuntu-latest` label. The per-workflow `runs_on` value is emitted by `detect.yaml`
(today always `ubuntu-latest`) — pointing heavy workflows at a bigger pool later is a
one-line change there (see testing.md §runner plan).

### 2.1 Consequences for Docker / CWL testing (important)

1. **No DinD daemon needed**: with the socket mounted, `docker` CLI inside a job talks to
   the **host** daemon. Images are built/stored in the host daemon → they **persist between
   ephemeral jobs** (warm image cache across runs — a big win for cwltool
   `DockerRequirement` pulls of large biocontainers images).
2. **Job resources = runner container limits**: the `myoung34` image executes jobs *inside*
   the runner container, so a job sees at most the replica limit (4 CPU / 4 GiB today).
   MD-heavy workflows (amber, cmip, gromacs) will OOM there; they need a bigger pool
   (see testing.md §runner plan) or GH-hosted runners.
3. **Label routing**: to target the remote pool use `runs-on: [self-hosted, mmbswarm]`
   (or a new label, e.g. `bigmem`). `ubuntu-latest` stays on GitHub.
4. **Linux → Linux**: no QEMU. The Mac-specific workarounds in
   `common/airflow/plugins/docker_wrapper.sh` (path remap, `KMP_AFFINITY=disabled`,
   `--platform=linux/amd64`) are irrelevant on the server — the wrapper becomes a
   pass-through as long as no argument contains `/opt/airflow/*`.
5. **Path visibility**: any path bind-mounted by a nested `docker run` (cwltool, airflow
   tasks) must exist **on the host**. The trick is to work under a host directory that is
   mounted into the job/container at the *same absolute path* (then the docker wrapper's
   rewrites never trigger).

## 3. Known issues (state after the 2026-09-16 CI work)

### Fixed in this round

- ~~Python test filter too narrow / dispatch ran nothing / bot pushes triggered all 19 jobs~~
  → `detect.yaml` + matrix (see §1.1).
- ~~Race between `docker.yaml` and `publish-ghcr.yaml`~~ → the publisher now regenerates
  the per-wf Dockerfiles locally before building.
- ~~Fragile line-number `sed` patches in `docker.yaml`~~ → `common/docker/sync_dockerfiles.sh`
  (anchor-based, verified byte-identical output for all 19 wf; also fixes two stale
  Dockerfiles and the 404-env-file build break for `biobb_wf_md_setup_mutations` /
  `biobb_wf_protein_md_analysis`, which have no jupyter repo).
- ~~`citation.yaml` watching `master`~~ → now `main`.
- ~~`cwl_readme.yaml` typo (`README.mdd`)~~ → fixed.
- ~~48 h timeout in the python test job~~ → 12 h.

### Fixed 2026-09-21 (e2e + publishing round)

- ~~GHCR publish was all-18-in-one-job, no manual trigger~~ → per-workflow matrix with a
  manual `wf` selector (see §1.2); `fail-fast: false`.
- ~~One shared image version label~~ → per-wf labels via `LABEL_OVERRIDES`
  (`sync_dockerfiles.sh`); the publisher tags from each wf's own Dockerfile.
- ~~No way to repair a GHCR tag without rebuilding~~ → `retag-ghcr.yaml`.
- ~~`matrix` context in a job-level `if`~~ → rejected by the workflow validator
  ("Unrecognized named-value: 'matrix'"); selection now happens in a `select` job whose
  JSON output feeds the matrix via `fromJSON(needs.select.outputs.matrix)`.
- Jupyter e2e flavour added to the manual Flavour e2e workflow (pilot workflow; see
  testing.md §2). The flavour e2e scripts themselves fixed several CI-only bugs —
  recorded in testing.md §2.1.
- ~~Python tests only runnable via the automatic pipeline~~ → "Flavour e2e Tests"
  gained a `python` flavour that delegates to `python-reusable.yaml` (no duplication,
  no drift between manual and automatic runs).
- ~~String concatenation in a workflow expression~~ → `${{ 'a' + x }}` is rejected by
  the validator ("Unexpected symbol: '+'"); the flavour→`require_path` mapping now
  happens in `detect.yaml` (plain python), via a new `flavour` input.

### Still open

1. **cmip python tests disabled in CI**: Fortran allocates ~25 GiB vs 7 GiB runner RAM
   (also `test_step24_cmip_run_prot_prot` is commented out in the test file). Needs a
   bigger runner or a reduced run.
2. **`self-hosted`-only workflows** (cwl/galaxy README, stale bot) queue forever if the
   swarm stack is down (no `ubuntu-latest` fallback).
3. **README sync workflows still use cp+sed** (line-number based) — same fragility as the
   old Dockerfile sync; they should migrate to the same anchor-script pattern.
4. **Docker image build fetches `main` at build time** (env.yml, notebook, workflow.py) —
   testing an unpushed local change via `docker build` silently tests the published state.
5. **`NOTES.md` git-ignored** → critical re-sync knowledge for CWL/Airflow is lost for
   anyone else. Consider un-ignoring or moving to `docs/`.
