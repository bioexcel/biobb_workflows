# Release helper

`bump_versions.py` changes the biobb versions of every workflow and flavour in one go.
It is driven by the project skill `.claude/skills/biobb-release/SKILL.md` (run
`/biobb-release` in Claude Code); the skill decides and asks, the script edits.

```bash
python3 common/release/bump_versions.py scan --jupyter            # what is written today
python3 common/release/bump_versions.py latest --jupyter --out release.json
python3 common/release/bump_versions.py check release.json        # installable? decisions?
python3 common/release/bump_versions.py apply release.json --jupyter --docker-version 2026.2
python3 common/python/check_versions.py --strict-flavours         # every flavour in step
python3 common/galaxy/galaxy_wf.py update && python3 common/galaxy/galaxy_wf.py check
```

What it edits, the release file format and the rules for image builds are in the
script's docstring. Markdown files are never edited (`scan` lists them).

Tested on 2026-11-23 on a throwaway worktree with the then-latest bioconda versions:
253 files in 19 workflows changed, then `check_versions.py --strict-flavours` passed.
