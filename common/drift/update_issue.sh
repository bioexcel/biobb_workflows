#!/usr/bin/env bash
# Keep ONE GitHub issue per check up to date, without spam.
#
#   update_issue.sh TITLE BODY_FILE COMMENT_FILE RED NOTABLE RUN_URL
#
#   RED > 0      open the issue (create or reopen), refresh its body, and comment only if
#                NOTABLE=true (something newly broke: needs action). Each comment emails the
#                assignee, so nothing else comments.
#   RED == 0     refresh the body of the existing issue and close it if open, WITHOUT a
#                comment (the user wants mail only when something needs fixing)
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
elif [ -n "$num" ]; then
  # all good: keep the text current, close quietly (no comment, no mail)
  gh issue edit "$num" --repo "$REPO" --body-file "$body" >/dev/null
  if [ "$state" = OPEN ]; then gh issue close "$num" --repo "$REPO"; fi
else
  echo "nothing to report on \"$title\""
fi
