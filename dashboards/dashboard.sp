dashboard "tools_insights" {
  title = "Tools team github issues insights"

  input "repo" {
    title = "Select a repo:"
    width = 4
    placeholder = "select repository"
    option  "turbot/steampipe" {
    label = "CLI (turbot/steampipe)"
    }
    option  "turbot/steampipe-postgres-fdw" {
      label = "FDW (turbot/steampipe-postgres-fdw)"
    }
    option  "turbot/steampipe-plugin-sdk" {
      label = "SDK (turbot/steampipe-plugin-sdk)"
    }
  }

  container "container_with_cards" {
    title = "GitHub Open CLI Issues"
    container {
      width = 10

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
        type = "info"
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
        type = "ok"
        width = 2
        args  = [self.input.repo.value]
      }
    }
  }

  input "issue_group" {
    title = "Select group:"
    width = 4
    placeholder = "select group"
    option  "all" {
    label = "All issues"
    }
    option  "community" {
      label = "Community issues"
    }
    option  "turbot" {
      label = "Turbot team"
    }
  }

  container "container_with_table" {
    width = 12

    table "data" {
      query = query.issue_table
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
        repository_full_name as "Repository",
        title as "Issue",
        now()::date - created_at::date as "Age in Days",
        now()::date - updated_at::date as "Last Updated (Days)",
        author ->> 'login' as author,
        url
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
        sum("Age in Days") AS "Community Issues Age"
      from (
  select
        repository_full_name as "Repository",
        title as "Issue",
        now()::date - created_at::date as "Age in Days",
        now()::date - updated_at::date as "Last Updated (Days)",
        author ->> 'login' as author,
        url
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
      now()::date - created_at::date as "Max Age in Days"
    from
      github_search_issue
    where
      query='org:turbot is:open' and
      repository_full_name = $1
    order by "Max Age in Days" desc limit 1;
  EOQ

  param "repository_full_name" {}
}

# table queries

query "issue_table" {
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