---
name: workflowhub-submission
description: Publish new versions of the biobb_workflows flavours (Jupyter, Python, CWL, Airflow, Nextflow, Docker, Galaxy) to WorkflowHub from workflowhub.manifest.yml, add a workflow or flavour to the manifest, or fix a failed submission. Use when the user asks to publish/update WorkflowHub, when a release reaches the WorkflowHub step, or when a WorkflowHub entry got a duplicate or a missing version.
---

# WorkflowHub publishing for biobb_workflows

Each flavour folder of each workflow is its own WorkflowHub entry (team 11, about 130
entries). Publishing = one new version per entry, with every file of the flavour inside
the version's RO-Crate. Nothing is uploaded by hand.

## Files

| File | Role |
| --- | --- |
| `workflowhub.manifest.yml` (repo root) | The "phone book": one block per entry (id, flavour, path, main file, exact source link `isBasedOn`, name, extra files, `remote` links, license, authors). `skip: true` = never sent; `id: null` = new entry |
| `.github/workflowhub/wfh_stage.py` | Builds `_wfh_stage/<key>/` per entry (folder copy + extras + `ro-crate-metadata.json`) and `_wfh_stage/index.json`. `--dry-run` audits only. `--keep-going` stages what is ready |
| `.github/workflowhub/wfh_submit.py` | Zips and POSTs each staged crate to `<instance>/workflows/submit`; keeps going after a failure; reports links and NEW ids |
| `.github/workflows/workflowhub-publish.yml` | The button: version, target (sandbox/production), filters. Production refuses to run while the latest test runs on main are not green |
| `scripts/wfh_bootstrap.py` (this skill) | Re-drafts a manifest from the live team entries (use only to add many entries or rebuild) |

Secrets and variables, created by the user (never write tokens into files):
`WORKFLOWHUB_API_TOKEN` (workflowhub.eu → My profile → Actions → API tokens),
`DEV_WORKFLOWHUB_API_TOKEN` + repository variable `DEV_TEAM_ID` (an account and a team on
https://dev.workflowhub.eu, the sandbox).

## How WorkflowHub decides "new version" or "new entry" (verified in its source, Nov 2026)

1. The crate's source URL is the root's `isBasedOn`. Missing source URL or `version` → rejected.
2. WorkflowHub looks for entries whose stored source link is **exactly** that string:
   one → new version of it; none → a new entry in the team; several → error.
3. If the entry already has a version with that version name, **nothing happens and it
   reports success**. Use a new version name every time (the release label).
4. Main workflow = `mainEntity`; its type comes from its `programmingLanguage`.
5. Title, description, license and creators are re-read from the crate every time.

So `isBasedOn` must be the entry's current source link **verbatim**, even if it looks old
(`/tree/master/`, old repo). To change a link: edit it on WorkflowHub first, then the manifest.

## Publish

1. Audit: `pip install pyyaml` (or any venv), then
   `python3 .github/workflowhub/wfh_stage.py --version test --dry-run`. Every `SKIPPED` line
   must be understood (see Fixes). Expected today: 118 entries, 0 skipped.
2. Sandbox first (the default target): Actions → **Publish to WorkflowHub** → version, target
   `sandbox`, optionally a tutorial filter. The sandbox has none of the production entries,
   so the first run creates them; a second run with another version name must add versions.
3. Production: same button, target `production`, version = the release label. Start with
   one tutorial (`tutorials: biobb_wf_amber_abc_setup/`), open each entry and its new
   version's files on workflowhub.eu, then run the rest.
   From the shell: `gh workflow run workflowhub-publish.yml -f version=2026.2 -f target=production`.
4. Read the job summary:
   - **NEW ENTRY** lines: write each id into `workflowhub.manifest.yml` (replace `id: null`)
     and commit. Later releases would still reach the right entry (WorkflowHub matches by
     source link, not id), but the `ids` filter, the summary checks and people need it.
   - **landed on entry X, manifest says Y**: a source link mismatch. Check both entries.
   - FAILED lines: fix, then re-run with `ids:` set to the failed ones and the SAME version.
5. In a release this runs after the merge published the images (`/biobb-release` step 6),
   then bio.tools.

## Fixes

- `isBasedOn shared by entries A, B`: WorkflowHub would reject all of them. The user gives
  each entry its own source link on WorkflowHub (e.g. its folder URL); update the manifest.
- `main file not found`: the file was renamed; update `main` and tell the user the new
  version has a different main file.
- `folder not found` for jupyter entries: the submodules are not checked out
  (`git submodule update --init`).
- A duplicate entry appeared: the source link did not match. Delete the duplicate on
  WorkflowHub, fix `isBasedOn` (or the entry's link), re-run with a new version name.
- Hidden files (e.g. `.curvesplus/`) never travel inside the zip (the RO-Crate libraries
  skip them): list them under `remote:` and they are added as links to the file on GitHub
  (`blob/main`), like the existing dna_helparms entries.

## Add a workflow or flavour

Add a block to the manifest by hand (copy a sibling), `id: null`, `isBasedOn` = the
folder's GitHub URL on `main` (`https://github.com/bioexcel/biobb_workflows/tree/main/<wf>/<flavour>`).
For many at once: `python3 .claude/skills/workflowhub-submission/scripts/wfh_bootstrap.py --team 11 --repo . --out /tmp/draft.yml`
and copy the proposed blocks (it reads the live entries and proposes new ones; review
every `CHECK` and `TODO`).

## Gotchas

- A version name works once per entry; reusing one is a silent no-op.
- Exact strings: `/tree/main` vs `/tree/master`, trailing slash, `.git` all matter.
- `tests/`, hidden files and `__pycache__` are never staged; `exclude:` adds globs.
- WorkflowHub versions get a DOI only when someone mints it on the website.
