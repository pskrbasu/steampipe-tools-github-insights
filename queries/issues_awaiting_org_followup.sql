-- Issues from external users where the last comment is from the external author (for a single repository)
-- Usage: pass the repository_full_name as $1 e.g. 'turbot/steampipe'
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