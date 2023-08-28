select
  title as "Issue title",
  now()::date - created_at::date as "Age in Days",
  now()::date - updated_at::date as "Last Updated (Days)",
  "author" ->> 'login' as "Author",
  url
from
  github_search_issue
where
  query='org:turbot is:open' and
  repository_full_name = 'turbot/steampipe-postgres-fdw'
order by "Age in Days";