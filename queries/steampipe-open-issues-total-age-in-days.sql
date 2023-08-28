select
  count(*) AS "Total Count",
  sum("Age in Days") AS "Total Age in Days"
from (
  select
    repository_full_name AS "Repository",
    title AS "Issue",
    now()::date - created_at::date AS "Age in Days",
    now()::date - updated_at::date AS "Last Updated (Days)",
    "author" ->> 'login' AS "Author",
    url
  from
    github_search_issue
  where
    query = 'org:turbot is:open'
    and repository_full_name = 'turbot/steampipe'
) subquery;