-- Stale issues from external contributors (for a single repository)
-- Usage: pass the repository_full_name as $1
SELECT
  repository_full_name AS repository,
  number AS issue_number,
  title AS issue_title,
  author ->> 'login' AS author,
  created_at,
  url
FROM
  github_search_issue
WHERE
  query = 'org:turbot is:open label:stale'
  AND repository_full_name = $1
  AND author ->> 'login' NOT IN (
    SELECT login FROM github_organization_member WHERE organization IN ('turbot', 'turbotio')
  )
ORDER BY
  created_at ASC; 