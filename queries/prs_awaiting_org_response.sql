-- PRs from external users with no Turbot org response within 48 hours
SELECT
  p.repository_full_name AS repository,
  p.number AS pr_number,
  p.title AS pr_title,
  p.author ->> 'login' AS author,
  p.created_at,
  p.url,
  EXTRACT(EPOCH FROM (now() - p.created_at))/3600 AS hours_since_created
FROM
  github_pull_request p
WHERE
  p.state = 'open'
  AND p.author ->> 'login' NOT IN (
    SELECT login FROM github_organization_member WHERE organization IN ('turbot', 'turbotio')
  )
  AND NOT EXISTS (
    SELECT 1 FROM github_pull_request_review r
    WHERE r.pull_request_number = p.number
      AND r.repository_full_name = p.repository_full_name
      AND r.author_login IN (
        SELECT login FROM github_organization_member WHERE organization IN ('turbot', 'turbotio')
      )
      AND r.submitted_at <= p.created_at + interval '48 hours'
  )
  AND NOT EXISTS (
    SELECT 1 FROM github_pull_request_comment c
    WHERE c.pull_request_number = p.number
      AND c.repository_full_name = p.repository_full_name
      AND c.author_login IN (
        SELECT login FROM github_organization_member WHERE organization IN ('turbot', 'turbotio')
      )
      AND c.created_at <= p.created_at + interval '48 hours'
  )
  AND p.created_at <= now() - interval '48 hours'
ORDER BY
  p.created_at ASC; 