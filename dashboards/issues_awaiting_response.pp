dashboard "issues_awaiting_response" {
  title = "External Issues Awaiting Response"
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
    description = "This table shows the issues created by external users that have not been responded to by the organization."
    width = 12
  
    table {
      query = query.issues_awaiting_response
      args = [self.input.repo.value]
      width = 12
    }
  }
} 

query "issues_awaiting_response" {
  sql = <<-EOQ
-- this query gives the list of issues(community) that have been not responded to by anyone in the organization
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
  left join lateral (
    select 1
    from github_issue_comment c
    where c.repository_full_name = i.repository_full_name
      and c.number = i.number
      and c.author_login in (
        select login from github_organization_member where organization in ('turbot', 'turbotio')
      )
  ) c on true
  where i.query = 'org:turbot is:open'
    and i.repository_full_name = $1
    and i.author ->> 'login' not in (
      select login from github_organization_member where organization in ('turbot', 'turbotio')
    )
    and c is null
) sub
order by created_at desc;
EOQ

  param "repository_full_name" {}
}