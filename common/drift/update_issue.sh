#!/usr/bin/env bash
# Keep ONE GitHub issue per check up to date, without spam.
#
#   update_issue.sh TITLE BODY_FILE COMMENT_FILE RED NOTABLE RUN_URL
#
#   RED > 0      open the issue (create or reopen), refresh its body, and comment
#                only if NOTABLE=true (something changed since the last run)
#   RED == 0     if open: refresh body, comment (COMMENT_FILE or "all green"), close
#                if not open and NOTABLE=true: comment on the closed issue (create it
#                and close it at once if it never existed)
#
# Env: GH_TOKEN, REPO (owner/name), optional ASSIGNEE (login to assign on creation,
# which makes GitHub notify that person). Label: drift.
set -euo pipefail
title=$1 body=$2 comment=$3 red=$4 notable=$5 run_url=$6

gh label create drift --repo "$REPO" --color FBCA04 --description "Automatic drift checks" --force >/dev/null
num=$(gh issue list --repo "$REPO" --label drift --state all --limit 100 --json number,title \
      --jq "map(select(.title == \"$title\")) | sort_by(.number) | last | .number // empty")
state=""
[ -n "$num" ] && state=$(gh issue view "$num" --repo "$REPO" --json state --jq .state)
assign=()
[ -n "${ASSIGNEE:-}" ] && assign=(--assignee "$ASSIGNEE")

create() {
  gh issue create --repo "$REPO" --title "$title" --label drift ${assign[@]+"${assign[@]}"} \
    --body-file "$body" | sed 's#.*/##'
}

if [ "$red" -gt 0 ]; then
  if [ -z "$num" ]; then
    num=$(create); echo "created issue #$num"
  else
    if [ "$state" = CLOSED ]; then gh issue reopen "$num" --repo "$REPO"; fi
    gh issue edit "$num" --repo "$REPO" --body-file "$body" >/dev/null
    if [ "$notable" = true ] && [ -s "$comment" ]; then
      gh issue comment "$num" --repo "$REPO" --body-file "$comment"
    fi
  fi
elif [ "$state" = OPEN ]; then
  gh issue edit "$num" --repo "$REPO" --body-file "$body" >/dev/null
  if [ -s "$comment" ]; then
    gh issue comment "$num" --repo "$REPO" --body-file "$comment"
  else
    gh issue comment "$num" --repo "$REPO" --body "### 🟢 All green again ([run]($run_url))"
  fi
  gh issue close "$num" --repo "$REPO"
elif [ "$notable" = true ] && [ -s "$comment" ]; then
  if [ -z "$num" ]; then
    num=$(create)
    gh issue comment "$num" --repo "$REPO" --body-file "$comment"
    gh issue close "$num" --repo "$REPO"
  else
    gh issue edit "$num" --repo "$REPO" --body-file "$body" >/dev/null
    gh issue comment "$num" --repo "$REPO" --body-file "$comment"
  fi
else
  echo "nothing to report on \"$title\""
fi
