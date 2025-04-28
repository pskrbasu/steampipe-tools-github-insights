dashboard "stale_issues" {
  title = "Pipelings Stale Issues "
  description = "Stale issue reporting for the Pipeling repos"

  input "repo" {
    title = "Select a repo:"
    width = 4
    placeholder = "select repository"
    option  "turbot/steampipe" {
      label = "Steampipe (turbot/steampipe)"
    }
    option  "turbot/steampipe-postgres-fdw" {
      label = "Steampipe Postgres FDW (turbot/steampipe-postgres-fdw)"
    }
    option  "turbot/steampipe-plugin-sdk" {
      label = "Steampipe Plugin SDK (turbot/steampipe-plugin-sdk)"
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
    option  "turbot/tailpipe-plugin-sdk" {
      label = "Tailpipe Plugin SDK (turbot/tailpipe-plugin-sdk)"
    }
  }

  container "stale_cards" {
    title = "Stale issues"
    container {
      title = "Stale issues"
      width = 12

      card "stale_open_issues_count" {
        query  = query.stale_open_issues_count
        type = "info"
        width = 2
        args  = [self.input.repo.value]
      }

      card "stale_closed_issues_count" {
        query  = query.stale_closed_issues_count
        type = "alert"
        width = 2
        args  = [self.input.repo.value]
      }

      card "community_stale_issues_open_count" {
        query  = query.community_stale_issues_open_count
        type = "alert"
        width = 2
        args  = [self.input.repo.value]
      }

      card "community_stale_issues_closed_count" {
        query  = query.community_stale_issues_closed_count
        type = "alert"
        width = 2
        args  = [self.input.repo.value]
      }
    }
    container "stale_open_table" {
      title = "Open Stale Issues (Community)"
      width = 12

      table "open_stale_community_list" {
        query = query.open_stale_community_list
        width = 12
        args  = [self.input.repo.value]
      }
    }
    container "stale_closed_table" {
      title = "Closed Stale Issues (Community)"
      width = 12

      table "closed_stale_community_list" {
        query = query.closed_stale_community_list
        width = 12
        args  = [self.input.repo.value]
      }
    }
  }

  container "stale_activity" {
    title = "Stale activity"
    container {
      title = "Community Stale activity (last 7 days)"
      width = 12

      card "stale_community_closed_last_7_days" {
        query  = query.stale_community_closed_last_7_days
        type = "alert"
        width = 2
        args  = [self.input.repo.value]
      }
    }

    container {
      table "stale_community_closed_last_7_days_list" {
        query = query.stale_community_closed_last_7_days_list
        width = 6
        args  = [self.input.repo.value]
      }
    }
    container {
      title = "Community Stale activity (last 14 days)"
      width = 12

      card "stale_community_closed_last_14_days" {
        query  = query.stale_community_closed_last_14_days
        type = "alert"
        width = 2
        args  = [self.input.repo.value]
      }
    }
    container {
      table "stale_community_closed_last_14_days_list" {
        query = query.stale_community_closed_last_14_days_list
        width = 6
        args  = [self.input.repo.value]
      }
    }
  }
}

query "stale_open_issues_count" {
  sql = <<-EOQ
    select
      count(*) AS "Open Stale Issues"
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

query "stale_closed_issues_count" {
  sql = <<-EOQ
    select
      count(*) AS "Closed Stale Issues"
    from (
      select
        title AS "Issue"
      from
        github_search_issue
      where
        query = 'org:turbot is:closed label:stale' -- Filter by the "stale" label
        and repository_full_name = $1
    ) subquery;
  EOQ

  param "repository_full_name" {}
}


query "community_stale_issues_open_count" {
  sql = <<-EOQ
    select
        count(*) AS "Open Stale Issues(Community)"
      from (
  select
        title as "Issue"
      from
        github_search_issue
      where
        query='org:turbot is:open label:stale' -- Filter by the "stale" label
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

query "community_stale_issues_closed_count" {
  sql = <<-EOQ
    select
        count(*) AS "Closed Stale Issues(Community)"
      from (
  select
        title as "Issue"
      from
        github_search_issue
      where
        query='org:turbot is:closed label:stale' -- Filter by the "stale" label
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

query "stale_closed_last_7_days" {
  sql = <<-EOQ
    select
      count(*) AS "Stale Issues Closed"
    from (
      select
        title AS "Issue"
      from
        github_search_issue
      where
        query = 'org:turbot is:closed label:stale' -- Filter by the "stale" label
        and repository_full_name = $1
        and closed_at >= current_date - interval '7 days'
    ) subquery;
  EOQ

  param "repository_full_name" {}
}

query "stale_community_closed_last_7_days" {
  sql = <<-EOQ
    select
      count(*) AS "Stale Issues Closed (Community)"
    from (
      select
        title AS "Issue"
      from
        github_search_issue
      where
        query = 'org:turbot is:closed label:stale' -- Filter by the "stale" label
        and repository_full_name = $1
        and closed_at >= current_date - interval '7 days'
        AND author ->> 'login' not in (
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

query "stale_closed_last_7_days_list" {
  sql = <<-EOQ
    SELECT
      title AS "Issue",
      author ->> 'login' AS author,
      url
    FROM
      github_search_issue
    WHERE
      query = 'org:turbot is:closed label:stale' -- Filter by the "stale" label
      AND repository_full_name = $1
      AND closed_at >= current_date - interval '7 days';
  EOQ

  param "repository_full_name" {}
}

query "stale_closed_last_14_days" {
  sql = <<-EOQ
    select
      count(*) AS "Stale Issues Closed"
    from (
      select
        title AS "Issue"
      from
        github_search_issue
      where
        query = 'org:turbot is:closed label:stale' -- Filter by the "stale" label
        and repository_full_name = $1
        and closed_at >= current_date - interval '14 days'
    ) subquery;
  EOQ

  param "repository_full_name" {}
}

query "stale_community_closed_last_14_days" {
  sql = <<-EOQ
    select
      count(*) AS "Stale Issues Closed (Community)"
    from (
      select
        title AS "Issue"
      from
        github_search_issue
      where
        query = 'org:turbot is:closed label:stale' -- Filter by the "stale" label
        and repository_full_name = $1
        and closed_at >= current_date - interval '14 days'
        AND author ->> 'login' not in (
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

query "stale_community_closed_last_7_days_list" {
  sql = <<-EOQ
    SELECT
      title AS "Issue",
      author ->> 'login' AS author,
      url
    FROM
      github_search_issue
    WHERE
      query = 'org:turbot is:closed label:stale' -- Filter by the "stale" label
      AND repository_full_name = $1
      AND closed_at >= current_date - interval '7 days'
      AND author ->> 'login' not in (
          select
            login
          from
            github_organization_member g
          where
            g.organization = any( array['turbot', 'turbotio'] )
        )
  EOQ

  param "repository_full_name" {}
}

query "stale_community_closed_last_14_days_list" {
  sql = <<-EOQ
    SELECT
      title AS "Issue",
      author ->> 'login' AS author,
      url
    FROM
      github_search_issue
    WHERE
      query = 'org:turbot is:closed label:stale' -- Filter by the "stale" label
      AND repository_full_name = $1
      AND closed_at >= current_date - interval '14 days'
      AND author ->> 'login' not in (
          select
            login
          from
            github_organization_member g
          where
            g.organization = any( array['turbot', 'turbotio'] )
        )
  EOQ

  param "repository_full_name" {}
}

query "open_stale_community_list" {
  sql = <<-EOQ
    SELECT
      title AS "Issue",
      author ->> 'login' AS author,
      url
    FROM
      github_search_issue
    WHERE
      query = 'org:turbot is:open label:stale' -- Filter by the "stale" label
      AND repository_full_name = $1
      AND author ->> 'login' not in (
          select
            login
          from
            github_organization_member g
          where
            g.organization = any( array['turbot', 'turbotio'] )
        )
  EOQ

  param "repository_full_name" {}
}

query "closed_stale_community_list" {
  sql = <<-EOQ
    SELECT
      title AS "Issue",
      author ->> 'login' AS author,
      url,
      closed_at
    FROM
      github_search_issue
    WHERE
      query = 'org:turbot is:closed label:stale' -- Filter by the "stale" label
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
      closed_at DESC;
  EOQ

  param "repository_full_name" {}
}