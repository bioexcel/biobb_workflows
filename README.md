# Drift snapshots

Written every day by `.github/workflows/drift-daily.yaml` (docs/ci.md §1.1d).
Do not edit by hand.

- `latest/`: today's dry-run solves (`envs/<env>/<platform>__<tool>.txt`), the spec
  lists they came from (`specs/`), and the tool, runner and Colab versions (`meta/`).
- `last-green/`: the same, from the last day when nothing was red.

The git history of this branch is the day-by-day record: `git log -p -- latest/`.
