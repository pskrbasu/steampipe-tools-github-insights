-- Issues from external users with no Turbot org response within 48 hours (for a single repository)
-- Usage: pass the repository_full_name as $1
SELECT
  repository_full_name AS repository,
  title AS issue_title,
  author ->> 'login' AS author,
  created_at,
  ROUND(EXTRACT(EPOCH FROM (now() - created_at))/3600, 1) AS hours_since_created,
  url
FROM
  github_search_issue
WHERE
  query = 'org:turbot is:open'
  AND repository_full_name = $1
  AND author ->> 'login' NOT IN (
    SELECT login FROM github_organization_member WHERE organization IN ('turbot', 'turbotio')
  )
  AND created_at <= now() - interval '48 hours'
  AND comments_total_count = 0
ORDER BY
  created_at ASC;