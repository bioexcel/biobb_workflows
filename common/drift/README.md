# Drift checks

Scripts behind `.github/workflows/drift-daily.yaml` and `drift-weekly-report.yaml`.
Rules and reasons are in `docs/ci.md` §1.1c (weekly round) and §1.1d (daily check). The
Python scripts use only the standard library.

| Script | What it does |
| --- | --- |
| `list_envs.py OUT` | Writes the spec list of every environment we ship to `OUT/specs/`: the 19 `python/workflow.env.yml` files and `conda_env/environment.yml` from GitHub main of each jupyter repo in `.gitmodules`. |
| `meta.py OUT` | Writes `OUT/meta/colab.txt` (Colab's Ubuntu, Python and runtime versions, from `googlecolab/backend-info`) and `OUT/meta/runner.txt` (this machine). |
| `solve.py --solver S --exe PATH --platform P --work OUT --out DIR` | Dry-run solves each spec list with conda, mamba or micromamba for one platform (nothing is installed) and writes the package list or the failure reason. |
| `weekly_report.py --repo R --out DIR [--trigger FILE]` | Summarises the latest scheduled run of each weekly-round test workflow (needs `gh`) for the "Drift: weekly tests" issue. |
| `update_issue.sh TITLE BODY COMMENT RED NOTABLE RUN_URL` | Opens, refreshes, comments on and closes one issue per check, without spam (shared by both checks). |
| `report.py --new DIR --prev DIR --green DIR --out DIR` | Compares today with yesterday and with the last all-green day; writes the issue text, the comment (only when something changed) and `status.json`. |

Run it locally (needs conda; solving for Linux from a Mac works):

```bash
python3 common/drift/list_envs.py /tmp/drift
python3 common/drift/meta.py /tmp/drift
python3 common/drift/solve.py --solver conda --exe "$(which conda)" --platform linux-64 \
  --work /tmp/drift --out /tmp/drift
python3 common/drift/report.py --new /tmp/drift --out /tmp/drift/report
```
