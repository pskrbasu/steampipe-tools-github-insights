dashboard "weekly_stats" {
  title = "Weekly Stats"
  description = "Weekly activity for the pipeling repos"

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

  container "stats" {
    title = "Weekly Stats"
    description = "Weekly stats for the Tools team repos"

    container {
      title = "Last 7 days"
      width = 12

      card "total_opened_last_7_days" {
        query  = query.total_opened_last_7_days
        type = "info"
        width = 2
        args  = [self.input.repo.value]
      }

      card "total_community_opened_last_7_days" {
        query  = query.total_community_opened_last_7_days
        type = "alert"
        width = 2
        args  = [self.input.repo.value]
      }

      card "total_closed_last_7_days" {
        query  = query.total_closed_last_7_days
        type = "info"
        width = 2
        args  = [self.input.repo.value]
      }

      card "total_community_closed_last_7_days" {
        query  = query.total_community_closed_last_7_days
        type = "ok"
        width = 2
        args  = [self.input.repo.value]
      }

      card "total_community_opened_last_7_days_not_responded" {
        query  = query.total_community_opened_last_7_days_not_responded
        type = "alert"
        width = 2
        args  = [self.input.repo.value]
      }

      table "community_issue_last_7_days_list_table_open" {
        width = 6
        title = "New Community Issues (Still Open):"
        query = query.community_issue_last_7_days_list_table
        args  = [self.input.repo.value]
      }
      
      table "community_issue_last_7_days_list_table_closed" {
        width = 6
        title = "New Community Issues (Closed):"
        query = query.community_issue_closed_last_7_days_list_table
        args  = [self.input.repo.value]
      }

      # table "community_issue_closed_last_7_days_list_table" {
      #   width = 6
      #   title = "Open community issues (last 7 days):"
      #   query = query.community_issue_closed_last_7_days_list_table
      #   args  = [self.input.repo.value]
      # }
    }

    container {
      title = "Last 14 days"
      width = 12

      card "total_opened_last_14_days" {
        query  = query.total_opened_last_14_days
        type = "info"
        width = 2
        args  = [self.input.repo.value]
      }

      card "total_community_opened_last_14_days" {
        query  = query.total_community_opened_last_14_days
        type = "alert"
        width = 2
        args  = [self.input.repo.value]
      }

      card "total_closed_last_14_days" {
        query  = query.total_closed_last_14_days
        type = "info"
        width = 2
        args  = [self.input.repo.value]
      }

      card "total_community_closed_last_14_days" {
        query  = query.total_community_closed_last_14_days
        type = "ok"
        width = 2
        args  = [self.input.repo.value]
      }

      card "total_community_opened_last_14_days_not_responded" {
        query  = query.total_community_opened_last_14_days_not_responded
        type = "alert"
        width = 2
        args  = [self.input.repo.value]
      }

      table "community_issue_last_14_days_list_table_open" {
        width = 6
        title = "New Community Issues (Still Open):"
        query = query.community_issue_last_14_days_list_table
        args  = [self.input.repo.value]
      }

      table "community_issue_last_14_days_list_table_closed" {
        width = 6
        title = "New Community Issues (Closed):"
        query = query.community_issue_closed_last_14_days_list_table
        args  = [self.input.repo.value]
      }
    }

    # container {
    #   title = "Last 30 days"
    #   width = 12

    #   card "total_opened_last_30_days" {
    #     query  = query.total_opened_last_30_days
    #     type = "info"
    #     width = 2
    #     args  = [self.input.repo.value]
    #   }

    #   card "total_community_opened_last_30_days" {
    #     query  = query.total_community_opened_last_30_days
    #     type = "alert"
    #     width = 2
    #     args  = [self.input.repo.value]
    #   }

    #   card "total_closed_last_30_days" {
    #     query  = query.total_closed_last_30_days
    #     type = "info"
    #     width = 2
    #     args  = [self.input.repo.value]
    #   }

    #   card "total_community_closed_last_30_days" {
    #     query  = query.total_community_closed_last_30_days
    #     type = "ok"
    #     width = 2
    #     args  = [self.input.repo.value]
    #   }

    #   card "total_community_opened_last_30_days_not_responded" {
    #     query  = query.total_community_opened_last_30_days_not_responded
    #     type = "alert"
    #     width = 2
    #     args  = [self.input.repo.value]
    #   }
    # }
  }

}




# Card queries

# Last 7 days

query "total_opened_last_7_days" {
  sql = <<-EOQ
    select
      count(*) AS "Total Issues Opened"
    from (
      select
        title AS "Issue"
      from
        github_search_issue
      where
        query = 'org:turbot is:open'
        and repository_full_name = $1
        and created_at >= current_date - interval '7 days'
    ) subquery;
  EOQ

  param "repository_full_name" {}
}

query "total_community_opened_last_7_days" {
  sql = <<-EOQ
    select
        count(*) AS "Community Issues Opened"
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
        and created_at >= current_date - interval '7 days'
    ) subquery;
  EOQ

  param "repository_full_name" {}
}

query "total_community_opened_last_7_days_not_responded" {
  sql = <<-EOQ
    select
        count(*) AS "Community Issues Not Responded"
      from (
  select
        title as "Issue"
      from
        github_search_issue
      where
        query='org:turbot is:open'
        and query = 'org:turbot comments:<1'
        and repository_full_name = $1
        and author ->> 'login' not in (
          select
              login
          from
              github_organization_member g
          where
              g.organization = any( array['turbot', 'turbotio'] )
          )
        and created_at >= current_date - interval '7 days'
    ) subquery;
  EOQ

  param "repository_full_name" {}
}

query "total_closed_last_7_days" {
  sql = <<-EOQ
    select
      count(*) AS "Total Issues Closed"
    from (
      select
        title AS "Issue"
      from
        github_search_issue
      where
        query = 'org:turbot is:closed'
        and repository_full_name = $1
        and created_at >= current_date - interval '7 days'
    ) subquery;
  EOQ

  param "repository_full_name" {}
}

query "total_community_closed_last_7_days" {
  sql = <<-EOQ
    select
        count(*) AS "Community Issues Closed"
      from (
  select
        title as "Issue"
      from
        github_search_issue
      where
        query='org:turbot is:closed'
        and repository_full_name = $1
        and author ->> 'login' not in (
          select
              login
          from
              github_organization_member g
          where
              g.organization = any( array['turbot', 'turbotio'] )
          )
        and created_at >= current_date - interval '7 days'
    ) subquery;
  EOQ

  param "repository_full_name" {}
}

# Last 14 days

query "total_opened_last_14_days" {
  sql = <<-EOQ
    select
      count(*) AS "Total Issues Opened"
    from (
      select
        title AS "Issue"
      from
        github_search_issue
      where
        query = 'org:turbot is:open'
        and repository_full_name = $1
        and created_at >= current_date - interval '14 days'
    ) subquery;
  EOQ

  param "repository_full_name" {}
}

query "total_community_opened_last_14_days" {
  sql = <<-EOQ
    select
        count(*) AS "Community Issues Opened"
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
        and created_at >= current_date - interval '14 days'
    ) subquery;
  EOQ

  param "repository_full_name" {}
}

query "total_community_opened_last_14_days_not_responded" {
  sql = <<-EOQ
    select
        count(*) AS "Community Issues Not Responded"
      from (
  select
        title as "Issue"
      from
        github_search_issue
      where
        query='org:turbot is:open'
        and query = 'org:turbot comments:<1'
        and repository_full_name = $1
        and author ->> 'login' not in (
          select
              login
          from
              github_organization_member g
          where
              g.organization = any( array['turbot', 'turbotio'] )
          )
        and created_at >= current_date - interval '14 days'
    ) subquery;
  EOQ

  param "repository_full_name" {}
}

query "total_closed_last_14_days" {
  sql = <<-EOQ
    select
      count(*) AS "Total Issues Closed"
    from (
      select
        title AS "Issue"
      from
        github_search_issue
      where
        query = 'org:turbot is:closed'
        and repository_full_name = $1
        and created_at >= current_date - interval '14 days'
    ) subquery;
  EOQ

  param "repository_full_name" {}
}

query "total_community_closed_last_14_days" {
  sql = <<-EOQ
    select
        count(*) AS "Community Issues Closed"
      from (
  select
        title as "Issue"
      from
        github_search_issue
      where
        query='org:turbot is:closed'
        and repository_full_name = $1
        and author ->> 'login' not in (
          select
              login
          from
              github_organization_member g
          where
              g.organization = any( array['turbot', 'turbotio'] )
          )
        and created_at >= current_date - interval '14 days'
    ) subquery;
  EOQ

  param "repository_full_name" {}
}

# Last 30 days

query "total_opened_last_30_days" {
  sql = <<-EOQ
    select
      count(*) AS "Total Issues Opened"
    from (
      select
        title AS "Issue"
      from
        github_search_issue
      where
        query = 'org:turbot is:open'
        and repository_full_name = $1
        and created_at >= current_date - interval '30 days'
    ) subquery;
  EOQ

  param "repository_full_name" {}
}

query "total_community_opened_last_30_days" {
  sql = <<-EOQ
    select
        count(*) AS "Community Issues Opened"
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
        and created_at >= current_date - interval '30 days'
    ) subquery;
  EOQ

  param "repository_full_name" {}
}

query "total_community_opened_last_30_days_not_responded" {
  sql = <<-EOQ
    select
        count(*) AS "Community Issues Not Responded"
      from (
  select
        title as "Issue"
      from
        github_search_issue
      where
        query='org:turbot is:open'
        and query = 'org:turbot comments:<1'
        and repository_full_name = $1
        and author ->> 'login' not in (
          select
              login
          from
              github_organization_member g
          where
              g.organization = any( array['turbot', 'turbotio'] )
          )
        and created_at >= current_date - interval '30 days'
    ) subquery;
  EOQ

  param "repository_full_name" {}
}

query "total_closed_last_30_days" {
  sql = <<-EOQ
    select
      count(*) AS "Total Issues Closed"
    from (
      select
        title AS "Issue"
      from
        github_search_issue
      where
        query = 'org:turbot is:closed'
        and repository_full_name = $1
        and created_at >= current_date - interval '30 days'
    ) subquery;
  EOQ

  param "repository_full_name" {}
}

query "total_community_closed_last_30_days" {
  sql = <<-EOQ
    select
        count(*) AS "Community Issues Closed"
      from (
  select
        title as "Issue"
      from
        github_search_issue
      where
        query='org:turbot is:closed'
        and repository_full_name = $1
        and author ->> 'login' not in (
          select
              login
          from
              github_organization_member g
          where
              g.organization = any( array['turbot', 'turbotio'] )
          )
        and created_at >= current_date - interval '30 days'
    ) subquery;
  EOQ

  param "repository_full_name" {}
}

# table queries

# Last 7 days

query "community_issue_last_7_days_list_table" {
  sql = <<-EOQ
    SELECT
    title AS "Issue",
    author ->> 'login' AS author,
    url,
    CASE 
      WHEN query = 'org:turbot comments:<1' THEN 'no'
      ELSE 'yes'
    END AS responded
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
    AND created_at >= current_date - interval '7 days'
  EOQ

  param "repository_full_name" {}
}

query "community_issue_closed_last_7_days_list_table" {
  sql = <<-EOQ
    SELECT
    title AS "Issue",
    author ->> 'login' AS author,
    url
  FROM
    github_search_issue
  WHERE
    query = 'org:turbot is:closed'
    AND repository_full_name = $1
    AND author ->> 'login' not in (
      select
        login
      from
        github_organization_member g
      where
        g.organization = any( array['turbot', 'turbotio'] )
      )
    AND created_at >= current_date - interval '7 days'
  EOQ

  param "repository_full_name" {}
}

# Last 14 days

query "community_issue_last_14_days_list_table" {
  sql = <<-EOQ
    SELECT
    title AS "Issue",
    author ->> 'login' AS author,
    url,
    CASE 
      WHEN query = 'org:turbot comments:<1' THEN 'no'
      ELSE 'yes'
    END AS responded
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
    AND created_at >= current_date - interval '14 days'
  EOQ

  param "repository_full_name" {}
}

query "community_issue_closed_last_14_days_list_table" {
  sql = <<-EOQ
    SELECT
    title AS "Issue",
    author ->> 'login' AS author,
    url
  FROM
    github_search_issue
  WHERE
    query = 'org:turbot is:closed'
    AND repository_full_name = $1
    AND author ->> 'login' not in (
      select
        login
      from
        github_organization_member g
      where
        g.organization = any( array['turbot', 'turbotio'] )
      )
    AND created_at >= current_date - interval '14 days'
  EOQ

  param "repository_full_name" {}
}