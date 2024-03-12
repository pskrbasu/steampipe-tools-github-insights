dashboard "tools_insights" {
  title = "Tools Team Github Issue Tracker"

  input "repo" {
    title = "Select a repo:"
    width = 4
    placeholder = "select repository"
    option  "turbot/steampipe" {
      label = "Steampipe (turbot/steampipe)"
    }
    option  "turbot/steampipe-postgres-fdw" {
      label = "FDW (turbot/steampipe-postgres-fdw)"
    }
    option  "turbot/steampipe-plugin-sdk" {
      label = "SDK (turbot/steampipe-plugin-sdk)"
    }
    option  "turbot/powerpipe" {
      label = "Powerpipe (turbot/powerpipe)"
    }
  }

  container "container_with_cards" {
    title = "GitHub Open CLI Issues"
    container {
      width = 12

      card "total_count" {
        query  = query.total_count
        type = "info"
        width = 2
        args  = [self.input.repo.value]
      }

      card "total_age" {
        query  = query.total_age
        type = "alert"
        width = 2
        args  = [self.input.repo.value]
      }

      card "total_count_community" {
        query  = query.total_count_community
        type = "ok"
        width = 2
        args  = [self.input.repo.value]
      }

      card "total_age_community" {
        query  = query.total_age_community
        type = "alert"
        width = 2
        args  = [self.input.repo.value]
      }

      card "max_age_issue" {
        query  = query.max_age_issue
        type = "info"
        width = 2
        args  = [self.input.repo.value]
      }

      card "total_count_stale" {
        query  = query.stale_issues_count
        type = "alert"
        width = 2
        args  = [self.input.repo.value]
      }
    }
  }

  container "container_with_charts" {
    width = 12

    chart "issue_age_stats"{
      type  = "column"
      title = "Issue Age Stats:"
      width = 4
      args  = [self.input.repo.value]

      sql = <<-EOQ
        WITH age_counts AS (
          SELECT
            CASE
              WHEN now()::date - created_at::date > 180 THEN '>6 Months'
              WHEN now()::date - created_at::date > 90 THEN '>3 Months'
              WHEN now()::date - created_at::date > 30 THEN '>1 Month'
            END AS age_group,
            1 AS issue_count
          FROM
            github_search_issue
          WHERE
            query = 'org:turbot is:open'
            AND repository_full_name = $1
        )
        SELECT
          age_group,
          COUNT(issue_count) AS count_of_issues
        FROM
          age_counts
        WHERE
          age_group IS NOT NULL
        GROUP BY
          age_group
        ORDER BY
          age_group;
      EOQ
    }

    chart "stale_stats" {
      type  = "pie"
      title = "Stale Issues Stats:"
      width = 4
      args  = [self.input.repo.value]

      sql = <<-EOQ
        SELECT
  'Contributor Stale Issues' AS "Issue Type",
  COUNT(*) AS "Count"
FROM
  github_search_issue
WHERE
  query = 'org:turbot is:open label:stale'
  AND
  author ->> 'login' NOT IN (
    SELECT
      login
    FROM
      github_organization_member g
    WHERE
      g.organization = ANY(ARRAY['turbot', 'turbotio'])
  )
  AND repository_full_name = $1
UNION ALL
SELECT
  'Total Stale Issues' AS "Issue Type",
  COUNT(*) AS "Count"
FROM
  github_search_issue
WHERE
  query = 'org:turbot is:open label:stale'
  AND repository_full_name = $1;
      EOQ
    }
  }

  
  

  container "container_with_table" {
    width = 12

    table "data" {
      title = "Issue List:"
      query = query.full_issue_list_table
      args  = [self.input.repo.value]
    }
  }
}

# Card queries

query "total_count" {
  sql = <<-EOQ
    select
      count(*) AS "Total Count"
    from (
      select
        title AS "Issue"
      from
        github_search_issue
      where
        query = 'org:turbot is:open'
        and repository_full_name = $1
    ) subquery;
  EOQ

  param "repository_full_name" {}
}

query "total_age" {
  sql = <<-EOQ
    select
      sum("Age in Days") AS "Total Age in Days"
    from (
      select
        now()::date - created_at::date AS "Age in Days"
      from
        github_search_issue
      where
        query = 'org:turbot is:open'
        and repository_full_name = $1
    ) subquery;
  EOQ

  param "repository_full_name" {}
}

query "total_count_community" {
  sql = <<-EOQ
    select
        count(*) AS "Community Issues"
      from (
  select
        title as "Issue"
      from
        github_search_issue
      where
        query='org:turbot is:open'
        and repository_full_name = $1
        and author ->> 'login' not in (
          select
              login
          from
              github_organization_member g
          where
              g.organization = any( array['turbot', 'turbotio'] )
          )
    ) subquery;
  EOQ

  param "repository_full_name" {}
}

query "total_age_community" {
  sql = <<-EOQ
    select
        sum("Age in Days") AS "Community Issues Total Age"
      from (
  select
        now()::date - created_at::date as "Age in Days"
      from
        github_search_issue
      where
        query='org:turbot is:open'
        and repository_full_name = $1
        and author ->> 'login' not in (
          select
              login
          from
              github_organization_member g
          where
              g.organization = any( array['turbot', 'turbotio'] )
          )
    ) subquery;
  EOQ

  param "repository_full_name" {}
}

query "max_age_issue" {
  sql = <<-EOQ
    select
      now()::date - created_at::date as "Max Issue Age in Days"
    from
      github_search_issue
    where
      query='org:turbot is:open' and
      repository_full_name = $1
    order by "Max Issue Age in Days" desc limit 1;
  EOQ

  param "repository_full_name" {}
}

query "stale_issues_count" {
  sql = <<-EOQ
    select
      count(*) AS "Stale Issues"
    from (
      select
        title AS "Issue"
      from
        github_search_issue
      where
        query = 'org:turbot is:open label:stale' -- Filter by the "stale" label
        and repository_full_name = $1
    ) subquery;
  EOQ

  param "repository_full_name" {}
}

# table queries

query "full_issue_list_table" {
  sql = <<-EOQ
  select
    title as "Issue Title",
    now()::date - created_at::date as "Age in Days",
    now()::date - updated_at::date as "Last Updated (Days)",
    "author" ->> 'login' as "Author",
    url
  from
    github_search_issue
  where
    query='org:turbot is:open' and
    repository_full_name = $1
  order by "Age in Days" desc;
  EOQ

  param "repository_full_name" {}
}

query "stale_issue_list_table" {
  sql = <<-EOQ
    SELECT
    title AS "Issue",
    now()::date - created_at::date AS "Age in Days",
    now()::date - updated_at::date AS "Last Updated (Days)",
    author ->> 'login' AS author,
    url
  FROM
    github_search_issue
  WHERE
    query = 'org:turbot is:open label:stale' -- Filter by the "stale" label
    AND repository_full_name = $1
  ORDER BY
    "Age in Days" DESC;
  EOQ

  param "repository_full_name" {}
}

query "contributor_issue_list_table" {
  sql = <<-EOQ
    SELECT
    title AS "Issue",
    now()::date - created_at::date AS "Age in Days",
    now()::date - updated_at::date AS "Last Updated (Days)",
    author ->> 'login' AS author,
    url
  FROM
    github_search_issue
  WHERE
    query = 'org:turbot is:open'
    AND repository_full_name = $1
    AND author ->> 'login' not in (
      select
        login
      from
        github_organization_member g
      where
        g.organization = any( array['turbot', 'turbotio'] )
      )
  ORDER BY
    "Age in Days" DESC;
  EOQ

  param "repository_full_name" {}
}