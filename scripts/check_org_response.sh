#!/bin/bash

# Usage: ./check_org_response.sh <repo>
# Example: ./check_org_response.sh turbot/steampipe

REPO="$1"
if [ -z "$REPO" ]; then
  echo "Usage: $0 <repo> (e.g. turbot/steampipe)"
  exit 1
fi

ORG_LOGINS=$(steampipe query "select login from github_organization_member where organization in ('turbot', 'turbotio');" --output csv | tail -n +2)

# Get all open issues from external contributors older than 48h
ISSUES_JSON=$(steampipe query "
select
  number,
  title,
  author ->> 'login' as author,
  created_at
from
  github_search_issue
where
  query = 'org:turbot is:open'
  and repository_full_name = '$REPO'
  and author ->> 'login' not in (
    select login from github_organization_member where organization in ('turbot', 'turbotio')
  )
  and created_at <= now() - interval '48 hours'
" --output json)

echo "[DEBUG] Raw JSON output from Steampipe:"
echo "$ISSUES_JSON"

# Check if the output is a non-empty array under .rows
if echo "$ISSUES_JSON" | jq -e '.rows | type == "array" and length > 0' >/dev/null; then
  echo "$ISSUES_JSON" | jq -c '.rows[]' | while read -r issue; do
    ISSUE_NUMBER=$(echo "$issue" | jq -r '.number')
    ISSUE_TITLE=$(echo "$issue" | jq -r '.title')
    ISSUE_AUTHOR=$(echo "$issue" | jq -r '.author')
    ISSUE_CREATED=$(echo "$issue" | jq -r '.created_at')

    # Skip if issue number is empty
    if [ -z "$ISSUE_NUMBER" ] || [ "$ISSUE_NUMBER" = "null" ]; then
      continue
    fi

    RESPONDED="no"
    for LOGIN in $ORG_LOGINS; do
      COMMENT_COUNT=$(steampipe query "
        select count(*) as count
        from github_issue_comment
        where repository_full_name = '$REPO'
          and number = $ISSUE_NUMBER
          and author_login = '$LOGIN'
          and created_at <= timestamp '$ISSUE_CREATED' + interval '48 hours'
      " --output csv | tail -n +2)
      if [ "$COMMENT_COUNT" != "" ] && [ "$COMMENT_COUNT" -gt 0 ]; then
        RESPONDED="yes"
        break
      fi
    done

    if [ "$RESPONDED" = "no" ]; then
      echo "No org response: #$ISSUE_NUMBER - $ISSUE_TITLE (author: $ISSUE_AUTHOR, created: $ISSUE_CREATED)"
    fi
  done
else
  echo "[INFO] No matching issues found or output is not a valid array."
fi 