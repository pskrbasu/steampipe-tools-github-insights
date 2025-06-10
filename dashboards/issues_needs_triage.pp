dashboard "issues_needs_triage" {
  title = "External Issues Needing Triage"
  width = 12

  input "repo" {
    title = "Select a repo:"
    width = 4
    placeholder = "select repository"
    option  "turbot/steampipe" {
      label = "Steampipe (turbot/steampipe)"
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
    option  "turbot/steampipe-postgres-fdw" {
      label = "Steampipe Postgres FDW (turbot/steampipe-postgres-fdw)"
    }
    option  "turbot/steampipe-plugin-sdk" {
      label = "Steampipe Plugin SDK (turbot/steampipe-plugin-sdk)"
    }
    option  "turbot/tailpipe-plugin-sdk" {
      label = "Tailpipe Plugin SDK (turbot/tailpipe-plugin-sdk)"
    }
  }

  container {
    description = "This table shows the issues created by external users that need triage."
    width = 12
  
    table {
      query = query.issues_needs_triage
      args = [self.input.repo.value]
      width = 12
    }
  }
} 

query "issues_needs_triage" {
  sql = <<-EOQ
-- this query gives the list of issues(community) that have been responded to by the organization but now needs triage/action
-- pass the repository_full_name as $1
select 
  url,
  title,
  author,
  created_at::date as created_date,
  number as issue_number
from (
  select 
    i.number,
    i.url,
    i.title,
    i.author ->> 'login' as author,
    i.created_at
  from github_search_issue i
  where i.query = 'org:turbot is:open label:ext:needs-triage'
    and i.repository_full_name = $1
    and i.author ->> 'login' not in (
      select login from github_organization_member where organization in ('turbot', 'turbotio')
    )
) sub
order by created_at desc;
EOQ

  param "repository_full_name" {}
}