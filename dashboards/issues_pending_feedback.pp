dashboard "issues_pending_feedback" {
  title = "External Issues Pending Feedback"
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
    description = "This table shows the issues created by external users that have been responded to by the organization but now need feedback from the author."
    width = 12
  
    table {
      query = query.issues_pending_feedback
      args = [self.input.repo.value]
      width = 12
    }
  }
} 

query "issues_pending_feedback" {
  sql = <<-EOQ
-- this query gives the list of issues(community) that have been responded to by the organization but now needs feedback from the author
-- pass the repository_full_name as $1
select 
  url,
  title,
  author,
  created_at::date as created_date,
  case
    when now()::date - coalesce(
      (select max(c.created_at)
       from github_issue_comment c
       where c.repository_full_name = sub.repository_full_name
         and c.number = sub.number
         and c.author_login in (
           select login from github_organization_member where organization in ('turbot', 'turbotio')
         )
      ), sub.created_at
    )::date > 28 then '🔴'
    when now()::date - coalesce(
      (select max(c.created_at)
       from github_issue_comment c
       where c.repository_full_name = sub.repository_full_name
         and c.number = sub.number
         and c.author_login in (
           select login from github_organization_member where organization in ('turbot', 'turbotio')
         )
      ), sub.created_at
    )::date > 14 then '🟡'
    else '🟢'
  end as status,
  number as issue_number,
  now()::date - coalesce(
    (select max(c.created_at)
     from github_issue_comment c
     where c.repository_full_name = sub.repository_full_name
       and c.number = sub.number
       and c.author_login in (
         select login from github_organization_member where organization in ('turbot', 'turbotio')
       )
    ), sub.created_at
  )::date as label_age_days
from (
  select 
    i.number,
    i.url,
    i.title,
    i.author ->> 'login' as author,
    i.created_at,
    i.repository_full_name
  from github_search_issue i
  where i.query = 'org:turbot is:open label:ext:pending-feedback'
    and i.repository_full_name = $1
    and i.author ->> 'login' not in (
      select login from github_organization_member where organization in ('turbot', 'turbotio')
    )
) sub
order by label_age_days desc;
EOQ

  param "repository_full_name" {}
}