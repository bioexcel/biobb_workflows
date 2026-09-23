# CI / CD — GitHub Actions & Runner Infrastructure

## 1. Workflow inventory (`.github/workflows/`)

### Test workflows

| File | Trigger | Runner | Purpose |
| --- | --- | --- | --- |
| `detect.yaml` | `workflow_call` (inputs: `wf_names`, `all_on_paths`, `require_path`, `flavour`) | `ubuntu-latest` | **Shared brain**: decides *which* workflows a test run must cover and emits a JSON matrix `[{wf, runs_on}]`. Rules: push → folders changed in the push (all, if a CI file matched by `all_on_paths` changed); manual/call → `wf_names` (empty or `all` = all); scheduled → all. `require_path` restricts to workflows that contain a given file (used by the flavour tests) |
| `python-tests.yaml` | `push` (only `biobb_wf_*/python/**`, `biobb_wf_*/tests/python/**`) + `workflow_dispatch` (`wf_names`) | `ubuntu-latest` (per job) | The python step-by-step pytest pipeline: `detect` → one call of `python-reusable.yaml` per selected workflow. The always-on push trigger and the weekly all-19 regression were removed 2026-09-22 ("test what you changed"); also available on demand via the manual Flavour e2e (`python` flavour, which delegates to `python-reusable.yaml`) |
| `cwl-tests.yaml` | `push` (only `biobb_wf_*/cwl/**`, `biobb_wf_*/tests/cwl/**`) | `ubuntu-latest` (per job) | Automatic cwl e2e ("test what you changed"): `detect` (flavour cwl → only wfs with `tests/cwl/run_test.sh` and no `tests/cwl/SKIP`) → `flavour-test-reusable`. Test-only |
| `airflow-tests.yaml` | `push` (only `biobb_wf_*/airflow/**`, `biobb_wf_*/tests/airflow/**`) | `ubuntu-latest` (per job) | Same for the airflow e2e (`tests/airflow/SKIP` opt-out). Test-only |
| `jupyter-tests.yaml` | `push` (only `biobb_wf_*/tests/jupyter/**`, the `biobb_wf_*/jupyter` submodule pointer) + `workflow_call` (`wf_names`, from the hourly probe) | `ubuntu-latest` (per job) | Same for the jupyter e2e (`tests/jupyter/SKIP` opt-out). Test-only. The notebook/env **content** lives in the separate `bioexcel/<wf>` jupyter repos — a push there can't trigger this repo, so the hourly `jupyter-sync.yaml` probe calls this workflow when a jupyter repo advanced |
| `python-reusable.yaml` | `workflow_call` (`wf_name`, optional `runs_on`) | input-driven | Per-workflow python test: checkout → per-wf `sed` runtime reductions (values: testing.md §1.5) → micromamba env from `<wf>/python/workflow.env.yml` (+`pytest`, `imagehash`) → `pytest <wf>.py --config ../../python/workflow.yml --remove`. `timeout-minutes: 720` |
| `flavour-tests.yaml` | `workflow_dispatch` only (inputs: `flavour` = docker/cwl/airflow/jupyter/python, `wf_names`) | `ubuntu-latest` (per job) | Manual e2e runner for any flavour: `detect` (only workflows that have `tests/<flavour>/run_test.sh`; for python, the `tests/python/` dir = every wf) → one call of `flavour-test-reusable.yaml` each. The per-flavour **automatic** counterparts (`cwl-tests.yaml`, `airflow-tests.yaml`, `jupyter-tests.yaml`, and the test-gated publish chain for docker) run on path changes; this workflow is for ad-hoc subsets. Concurrency group includes the flavour, so the 5 flavours can run in parallel |
| `flavour-test-reusable.yaml` | `workflow_call` (`wf_name`, `flavour`, optional `runs_on`) | input-driven | Runs `<wf>/tests/<flavour>/run_test.sh` (installs `cwltool` via micromamba for the cwl flavour). `timeout-minutes: 720`. The **python** flavour has no script: the job delegates to `python-reusable.yaml` (the CI python pipeline, so manual and automatic runs can never drift) |

### Code-generation & publishing workflows (they commit/publish, they do not test)

| File | Trigger | Runner | Purpose |
| --- | --- | --- | --- |
| `docker.yaml` | push to `common/docker/Dockerfile` or `common/docker/sync_dockerfiles.sh` + dispatch | `ubuntu-latest` | **Code generation**: runs `common/docker/sync_dockerfiles.sh` (regenerates all 19 per-wf Dockerfiles from the template with anchor-based patches, injecting per-wf `<wf>/docker/VERSION` labels — see §1.2), commits + pushes if anything changed (`github-actions[bot]`). Its bot push is ignored by the publish chain (no double chain) |
| `publish-ghcr.yaml` | push to `common/docker/**` (all images), `biobb_wf_X/docker/**` (X), or `biobb_wf_X/python/workflow.py` / `workflow.env.yml` (X — the image bakes these in from `main` at build time) + `workflow_dispatch` (inputs `wf`, `skip_tests`) + `workflow_call` (`wf_names`, from the hourly probe when a jupyter repo's conda env changed) | `ubuntu-latest` (per image) | **Test-gated chain**: `detect` → `select` (publish matrix + docker-e2e test matrix) → docker e2e (`flavour-test-reusable`, one job per wf) → `publish` — **only if every selected test passed** (skipped when none exists). A wf opts out of its own gate with a `tests/docker/SKIP` file (first line = printed reason; it then publishes untested like a wf without an e2e — currently biobb_wf_cmip, OOM on the 7 GiB runner). One job per workflow, `fail-fast: false`. Each image is tagged with **its own** version (`<wf>/docker/VERSION` if present, else the template label) + `latest`. Test and publish jobs both run the sync script **locally first** (not committed), so they build identical Dockerfiles even if the docker.yaml bot commit is still in flight. See §1.2 |
| `jupyter-sync.yaml` | `schedule` (hourly, :17) + `workflow_dispatch` | `ubuntu-latest` | **Cross-repo bridge** (the image + jupyter e2e consume `bioexcel/<wf>` main, which can't trigger this repo): for each jupyter submodule, grouped by repo (the three amber sub-wfs share `biobb_wf_amber`), `ls-remote main` vs the committed pointer; on advance, clone + diff `old..new`, then — bot-commit the pointer bump (always, keeps local checkouts current), run the jupyter e2e (always), and run the publish chain **if `conda_env/environment.yml` or the wf's tutorial notebook changed** (after the jupyter e2e passed — a broken notebook can never reach the image). Clone/diff failure → no bump, retry next hour. No secrets (public ls-remote/clone) |
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
2. Every changed path starting with `biobb_wf_` selects that workflow. (The former rule
   "a change to the test-workflow files themselves selects **all** workflows" was removed
   2026-09-22: CI plumbing changes trigger nothing — validate plumbing via a manual
   `workflow_dispatch`. The publish chain keeps its own `all_on_paths`
   (`common/docker/**` → all images), which is semantically different: a template change
   changes *every* image.)
3. The selected list becomes a matrix; each entry is one job. `workflow_dispatch` lets
   you force a subset (`wf_names=biobb_wf_cmip`) or everything (empty).
4. Pushes by `github-actions[bot]` (Dockerfile/README sync) are ignored entirely.

Verified locally against real commit pairs: a cmip-only commit selects only cmip;
`require_path: tests/docker/run_test.sh` selects exactly the workflows that have a docker
test.

### 1.2 The per-workflow update flow (version bump → tests → image)

Bumping a tool version (e.g. `biobb_chemistry`) for **one** workflow, end to end:

1. **Update the pins** (the 5+2 places, see architecture.md):
   - this repo: `<wf>/python/workflow.env.yml`, one `dockerPull:` line per adapter in
     `<wf>/cwl/biobb_adapters/*.cwl` and `<wf>/airflow/biobb_adapters/*.cwl`
   - jupyter repo (`bioexcel/<wf>`, the submodule): `conda_env/environment.yml` +
     `binder/environment.yml`. **Push the jupyter repo first** — the docker image (and the
     jupyter e2e test in CI) fetch `conda_env/environment.yml` from its `main` at build time.
   - Then commit in this repo, including the submodule pointer bump.
2. **Test (automatic, per changed path)**: a push runs each touched flavour's own tests —
   `python/**` → python tests, `cwl/**` → cwl e2e, `airflow/**` → airflow e2e,
   `tests/jupyter`/jupyter pointer → jupyter e2e, `docker/**` → docker e2e as the gate of
   the publish chain (step 4). The manual "Flavour e2e Tests" workflow remains for ad-hoc
   subsets. A wf opts out of a flavour's auto tests with `tests/<flavour>/SKIP`.
3. **Bump the image label** (so the new content gets a new tag and the old image keeps its
   tag): update `<wf>/docker/VERSION` (one line, e.g. `2026.2`; the file is absent for
   workflows that follow the shared template label). Steps 2–3 land in the same push.
4. **Test + publish (automatic)**: the push touches `biobb_wf_X/docker/**` — or the
   image-baked `biobb_wf_X/python/workflow.py` / `workflow.env.yml` (e.g. the env-pin bump
   of step 1, pushed after the jupyter repo) → `detect` selects X → the docker e2e runs →
   the image is built + pushed as `<wf>:<label>` + `<wf>:latest` **only if the test is
   green**. Other workflows' images/tags are untouched. The rebuild lands under the
   *current* label — for a meaningful content change, bump `VERSION` (step 3) in the same
   push so the old image keeps its tag. Manual rebuild: Actions → "Docker Image CI for
   GHCR" → `wf: <wf>` (the docker e2e runs too; `skip_tests` bypasses it — not
   recommended).

Rules this design gives:

- Each image is versioned independently (`<wf>/docker/VERSION` or the template label); a
  template change (`common/docker/**`) still tests + rebuilds **all** images, each under
  its own current label.
- The chain fires on `common/docker/**`, `biobb_wf_*/docker/**`, or the image-baked
  `biobb_wf_*/python/workflow.py` / `workflow.env.yml` (or manual dispatch) — e.g. a
  cwl/airflow adapter (`dockerPull`) change never rebuilds the image, and neither does a
  `workflow.yml`/`README.md`/`tests/**` change. Jupyter-repo content (conda env,
  notebook) is fetched from `main` at build time, and a jupyter-repo push cannot trigger
  this repo — the hourly `jupyter-sync.yaml` probe covers it: pointer bump + jupyter
  e2e on any jupyter-repo advance, image rebuild only when `conda_env/environment.yml`
  changed.
- Run-level gate: if any selected docker e2e fails, that run publishes nothing (re-push or
  re-dispatch publishes the green ones). Workflows without a docker e2e script publish
  without a gate (the select job prints a warning). A wf can opt out of its own gate with
  a `tests/docker/SKIP` file (first line = the printed reason; currently: biobb_wf_cmip —
  OOM on the 7 GiB runner); it then publishes untested, like a wf without an e2e.
- Per-flavour opt-out (all test workflows): a `tests/<flavour>/SKIP` file next to
  `run_test.sh` excludes the wf from that flavour's selection — `detect` (and the publish
  chain's select job) print the first line as the reason. The manual "Flavour e2e Tests"
  honours the same file. Currently set for `biobb_wf_cmip` on docker/cwl/airflow.
- Overwrote a tag by mistake? The old image survives in the registry by digest (package
  versions page) — restore it with `retag-ghcr.yaml`.

### Image consistency: the "last green trio" rule

An image bakes in three moving parts: the conda env + tutorial notebook (from the
jupyter repo `bioexcel/<wf>` main) and `python/workflow.py` (from this repo's main;
the two wfs without a jupyter repo instead bake their own `python/workflow.env.yml`
and no notebook). A **published image is always the last *green* combination of the
three**: the docker e2e runs `workflow.py` inside the very image it built, and the
jupyter e2e runs the notebook inside a freshly built image — so a broken combination
can never be published. Single-side changes:

| You change only... | What happens | Broken image? |
| --- | --- | --- |
| jupyter env (`conda_env/environment.yml`) | the probe rebuilds (env gate): new env + old `workflow.py` | no — if the old code doesn't run on the new env, the docker e2e fails and the old image stays |
| `python/workflow.py` (or the no-jupyter wfs' own env) | the chain rebuilds: new code + old env (jupyter main) | no — same gate; the image lags until the env catch-up push |
| tutorial notebook | the probe rebuilds: new notebook + current env + code | no — the chain runs only after the jupyter e2e passed, so a broken notebook can never be published |
| this repo's `python/workflow.env.yml` (the 17 jupyter wfs) | content no-op: their image env comes from the jupyter repo | no |
| both sides (version-bump flow) | two rebuilds, each testing its concrete intermediate | no — every published state was tested |

The one thing no gate checks: that the two env files pin the same `biobb_*`
versions. The hourly probe (`jupyter-sync.yaml`) now warns on `biobb_*` pin drift
between `python/workflow.env.yml` (this repo) and `conda_env/environment.yml`
(jupyter repo).

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
- ~~GHCR publishing was manual-dispatch only, untested~~ → push-triggered chain
  `detect → select → docker e2e → publish` (publish only when green). The per-wf version
  label moved from a central `LABEL_OVERRIDES` dict to a per-wf `<wf>/docker/VERSION`
  file, so a label bump is a per-wf path change and the chain stays per-workflow.
- ~~Python pipeline ran on EVERY push + a weekly all-19 regression~~ → "test what you
  changed": `python-tests.yaml` fires only on `biobb_wf_*/python/**`,
  `biobb_wf_*/tests/python/**`; the weekly regression was dropped. (The owner's
  2026-09-21 request was about the *always-on* behaviour, not about removing python
  coverage.)
- ~~CI-file change → all workflows ("pipeline self-proof")~~ → removed 2026-09-22 from
  all test workflows (python/cwl/airflow/jupyter): a push touching only CI plumbing
  triggers nothing; validate plumbing via `workflow_dispatch`. The publish chain's
  `common/docker/**` → all-images rule stays (a template change changes every image —
  different semantics).
- ~~A `workflow.py` change left the GHCR image stale~~ (the image bakes
  `<wf>/python/workflow.py` from `main` at build time, but the chain only fired on
  `docker/**` paths) → the chain now also fires on `biobb_wf_*/python/workflow.py` and
  `workflow.env.yml` (the latter is image-baked for the two wfs without a jupyter repo,
  and useful for the other 17 in the version-bump flow, where it lands right after the
  jupyter-repo push).
- ~~Jupyter-repo changes were invisible to CI~~ (the image bakes in their conda env +
  notebook at build time, the jupyter e2e runs their notebook, but a push to
  `bioexcel/<wf>` can't trigger this repo) → hourly probe `jupyter-sync.yaml`:
  `ls-remote main` vs the committed submodule pointer → on advance, bot-commit the
  pointer bump + run the jupyter e2e + run the publish chain **if
  `conda_env/environment.yml` or the wf's tutorial notebook changed (after the
  jupyter e2e passed)**. Bonus fix: `detect` now handles
  `workflow_call` and the `wf_names=all` value (the dispatch `all` option was silently
  rejected before).
- ~~cwl/airflow/jupyter e2e were manual-only~~ → per-flavour auto workflows
  (`cwl-tests.yaml`, `airflow-tests.yaml`, `jupyter-tests.yaml`): a push to a wf's
  flavour paths runs that wf's e2e (test-only; selection via `detect`'s `flavour` input).
- ~~One red docker e2e (biobb_wf_cmip — OOM on the 7 GiB runner) blocked every
  all-workflows publish run forever~~ → per-wf opt-out file `tests/<flavour>/SKIP`: the
  select job (publish chain) and `detect` (all test workflows) drop the wf from that
  flavour's selection and print the reason; a SKIP-ed wf's image still publishes
  untested. Currently set for `biobb_wf_cmip` on docker/cwl/airflow.
- ~~`biobb_wf_structure_checking` had no GHCR image entry~~ → it was in the old
  all-in-one publisher but dropped when the per-workflow matrix was written (`d236d3c`);
  re-added to the chain's image list (it now builds/publishes like the other 18 —
  untested until its docker e2e script exists).

### Still open

1. **cmip python tests disabled in CI**: Fortran allocates ~25 GiB vs 7 GiB runner RAM
   (also `test_step24_cmip_run_prot_prot` is commented out in the test file). Needs a
   bigger runner or a reduced run. Its docker e2e hits the same wall and is opted out of
   the publish gate via `biobb_wf_cmip/tests/docker/SKIP`.
2. **`self-hosted`-only workflows** (cwl/galaxy README, stale bot) queue forever if the
   swarm stack is down (no `ubuntu-latest` fallback).
3. **README sync workflows still use cp+sed** (line-number based) — same fragility as the
   old Dockerfile sync; they should migrate to the same anchor-script pattern.
4. **Docker image build fetches `main` at build time** (env.yml, notebook, workflow.py) —
   testing an unpushed local change via `docker build` silently tests the published state.
5. **`NOTES.md` git-ignored** → critical re-sync knowledge for CWL/Airflow is lost for
   anyone else. Consider un-ignoring or moving to `docs/`.
6. **Publish gate is run-level** → one failing docker e2e blocks every image of that run
   (re-dispatch publishes the green ones; the `tests/docker/SKIP` opt-out covers the
   known-broken case). Per-workflow partial publishing would need per-matrix-leg job
   outputs.

