dashboard "issues_awaiting_org_followup" {
  title = "External Issues Awaiting Follow-up"
  width = 12

  input "repo" {
    title = "Select a repo:"
    width = 4
    placeholder = "select repository"
    option  "turbot/steampipe" {
      label = "Steampipe (turbot/steampipe)"
    }
    option  "turbot/steampipe-postgres-fdw" {
      label = "Steampipe Postgres FDW (turbot/steampipe-postgres-fdw)"
    }
    option  "turbot/steampipe-plugin-sdk" {
      label = "Steampipe Plugin SDK (turbot/steampipe-plugin-sdk)"
    }
    option  "turbot/flowpipe" {
      label = "Flowpipe (turbot/flowpipe)"
    }
    option  "turbot/powerpipe" {
      label = "Powerpipe (turbot/powerpipe)"
    }
    option  "turbot/tailpipe" {
      label = "Tailpipe (turbot/tailpipe)"
    }
    option  "turbot/tailpipe-plugin-sdk" {
      label = "Tailpipe Plugin SDK (turbot/tailpipe-plugin-sdk)"
    }
  }

  container {
    description = "This table shows the issues that have not been followed up by the organization."
    width = 12
  
    table {
      query = query.issues_awaiting_org_followup
      args = [self.input.repo.value]
      width = 12
    }
  }
} 

query "issues_awaiting_org_followup" {
  sql = <<-EOQ
-- Issues from external users where the last comment is from the external author (for a single repository)
-- Usage: pass the repository_full_name as $1
SELECT
  i.repository_full_name AS repository,
  i.number AS issue_number,
  i.title AS issue_title,
  i.author ->> 'login' AS author,
  i.created_at,
  c.author_login AS last_comment_by,
  c.created_at AS last_comment_at,
  i.url
FROM
  github_search_issue i
  JOIN LATERAL (
    SELECT author_login, created_at
    FROM github_issue_comment
    WHERE repository_full_name = i.repository_full_name
      AND number = i.number
    ORDER BY created_at DESC
    LIMIT 1
  ) c ON TRUE
WHERE
  i.query = 'org:turbot is:open'
  AND i.repository_full_name = $1
  AND i.author ->> 'login' NOT IN (
    SELECT login FROM github_organization_member WHERE organization IN ('turbot', 'turbotio')
  )
  AND c.author_login = i.author ->> 'login'
ORDER BY
  c.created_at ASC; 
  EOQ

  param "repository_full_name" {}
}