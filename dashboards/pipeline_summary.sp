dashboard "pipeline_summary" {
  container {
    title = "Steampipe"
    width = 12
    
    card "total_communtiy_age_status_steampipe" {
      title = "Total Age (Community)"
      width = 2
      href = "/tools_team_issue_tracker.dashboard.tools_insights?input.repo.value=turbot/steampipe&input.repo=turbot/steampipe"
      sql = <<-EOQ
        select
          'Total Age (Community)' as label,
          coalesce(sum(now()::date - created_at::date), 0) as value,
          case
            when coalesce(sum(now()::date - created_at::date), 0) < 500 then 'ok'
            when coalesce(sum(now()::date - created_at::date), 0) < 1000 then 'info'
            else 'alert'
          end as type,
          case
            when coalesce(sum(now()::date - created_at::date), 0) < 500 then 'text:🟢'
            when coalesce(sum(now()::date - created_at::date), 0) < 1000 then 'text:🟡'
            else 'text:🔴'
          end as icon
        from github_search_issue
        where query = 'org:turbot is:open'
          and repository_full_name = 'turbot/steampipe'
        and author ->> 'login' not in (
          select
              login
          from
              github_organization_member g
          where
              g.organization = any( array['turbot', 'turbotio'] )
          )
      EOQ
    }
  }

  container {
    title = "Steampipe Postgres FDW"
    width = 12
    
    card "total_communtiy_age_status_postgres_fdw" {
      title = "Total Age (Community)"
      width = 2
      href = "/tools_team_issue_tracker.dashboard.tools_insights?input.repo.value=turbot/steampipe-postgres-fdw&input.repo=turbot/steampipe-postgres-fdw"
      sql = <<-EOQ
        select
          'Total Age (Community)' as label,
          coalesce(sum(now()::date - created_at::date), 0) as value,
          case
            when coalesce(sum(now()::date - created_at::date), 0) < 500 then 'ok'
            when coalesce(sum(now()::date - created_at::date), 0) < 1000 then 'info'
            else 'alert'
          end as type,
          case
            when coalesce(sum(now()::date - created_at::date), 0) < 500 then 'text:🟢'
            when coalesce(sum(now()::date - created_at::date), 0) < 1000 then 'text:🟡'
            else 'text:🔴'
          end as icon
        from github_search_issue
        where query = 'org:turbot is:open'
          and repository_full_name = 'turbot/steampipe-postgres-fdw'
        and author ->> 'login' not in (
          select
              login
          from
              github_organization_member g
          where
              g.organization = any( array['turbot', 'turbotio'] )
          )
      EOQ
    }
  }

  container {
    title = "Steampipe Plugin SDK"
    width = 12
    
    card "total_communtiy_age_status_plugin_sdk" {
      title = "Total Age (Community)"
      width = 2
      href = "/tools_team_issue_tracker.dashboard.tools_insights?input.repo.value=turbot/steampipe-plugin-sdk&input.repo=turbot/steampipe-plugin-sdk"
      sql = <<-EOQ
        select
          'Total Age (Community)' as label,
          coalesce(sum(now()::date - created_at::date), 0) as value,
          case
            when coalesce(sum(now()::date - created_at::date), 0) < 500 then 'ok'
            when coalesce(sum(now()::date - created_at::date), 0) < 1000 then 'info'
            else 'alert'
          end as type,
          case
            when coalesce(sum(now()::date - created_at::date), 0) < 500 then 'text:🟢'
            when coalesce(sum(now()::date - created_at::date), 0) < 1000 then 'text:🟡'
            else 'text:🔴'
          end as icon
        from github_search_issue
        where query = 'org:turbot is:open'
          and repository_full_name = 'turbot/steampipe-plugin-sdk'
        and author ->> 'login' not in (
          select
              login
          from
              github_organization_member g
          where
              g.organization = any( array['turbot', 'turbotio'] )
          )
      EOQ
    }
  }

  container {
    title = "Flowpipe"
    width = 12
    
    card "total_communtiy_age_status_flowpipe" {
      title = "Total Age (Community)"
      width = 2
      href = "/tools_team_issue_tracker.dashboard.tools_insights?input.repo.value=turbot/flowpipe&input.repo=turbot/flowpipe"
      sql = <<-EOQ
        select
          'Total Age (Community)' as label,
          coalesce(sum(now()::date - created_at::date), 0) as value,
          case
            when coalesce(sum(now()::date - created_at::date), 0) < 500 then 'ok'
            when coalesce(sum(now()::date - created_at::date), 0) < 1000 then 'info'
            else 'alert'
          end as type,
          case
            when coalesce(sum(now()::date - created_at::date), 0) < 500 then 'text:🟢'
            when coalesce(sum(now()::date - created_at::date), 0) < 1000 then 'text:🟡'
            else 'text:🔴'
          end as icon
        from github_search_issue
        where query = 'org:turbot is:open'
          and repository_full_name = 'turbot/flowpipe'
        and author ->> 'login' not in (
          select
              login
          from
              github_organization_member g
          where
              g.organization = any( array['turbot', 'turbotio'] )
          )
      EOQ
    }
  }

  container {
    title = "Powerpipe"
    width = 12
    
    card "total_communtiy_age_status_powerpipe" {
      title = "Total Age (Community)"
      width = 2
      href = "/tools_team_issue_tracker.dashboard.tools_insights?input.repo.value=turbot/powerpipe&input.repo=turbot/powerpipe"
      sql = <<-EOQ
        select
          'Total Age (Community)' as label,
          coalesce(sum(now()::date - created_at::date), 0) as value,
          case
            when coalesce(sum(now()::date - created_at::date), 0) < 500 then 'ok'
            when coalesce(sum(now()::date - created_at::date), 0) < 1000 then 'info'
            else 'alert'
          end as type,
          case
            when coalesce(sum(now()::date - created_at::date), 0) < 500 then 'text:🟢'
            when coalesce(sum(now()::date - created_at::date), 0) < 1000 then 'text:🟡'
            else 'text:🔴'
          end as icon
        from github_search_issue
        where query = 'org:turbot is:open'
          and repository_full_name = 'turbot/powerpipe'
        and author ->> 'login' not in (
          select
              login
          from
              github_organization_member g
          where
              g.organization = any( array['turbot', 'turbotio'] )
          )
      EOQ
    }
  }

  container {
    title = "Tailpipe"
    width = 12
    
    card "total_communtiy_age_status_tailpipe" {
      title = "Total Age (Community)"
      width = 2
      href = "/tools_team_issue_tracker.dashboard.tools_insights?input.repo.value=turbot/tailpipe&input.repo=turbot/tailpipe"
      sql = <<-EOQ
        select
          'Total Age (Community)' as label,
          coalesce(sum(now()::date - created_at::date), 0) as value,
          case
            when coalesce(sum(now()::date - created_at::date), 0) < 500 then 'ok'
            when coalesce(sum(now()::date - created_at::date), 0) < 1000 then 'info'
            else 'alert'
          end as type,
          case
            when coalesce(sum(now()::date - created_at::date), 0) < 500 then 'text:🟢'
            when coalesce(sum(now()::date - created_at::date), 0) < 1000 then 'text:🟡'
            else 'text:🔴'
          end as icon
        from github_search_issue
        where query = 'org:turbot is:open'
          and repository_full_name = 'turbot/tailpipe'
        and author ->> 'login' not in (
          select
              login
          from
              github_organization_member g
          where
              g.organization = any( array['turbot', 'turbotio'] )
          )
      EOQ
    }
  }

  container {
    title = "Tailpipe Plugin SDK"
    width = 12
    
    card "total_communtiy_age_status_tailpipe_plugin_sdk" {
      title = "Total Age (Community)"
      width = 2
      href = "/tools_team_issue_tracker.dashboard.tools_insights?input.repo.value=turbot/tailpipe-plugin-sdk&input.repo=turbot/tailpipe-plugin-sdk"
      sql = <<-EOQ
        select
          'Total Age (Community)' as label,
          coalesce(sum(now()::date - created_at::date), 0) as value,
          case
            when coalesce(sum(now()::date - created_at::date), 0) < 500 then 'ok'
            when coalesce(sum(now()::date - created_at::date), 0) < 1000 then 'info'
            else 'alert'
          end as type,
          case
            when coalesce(sum(now()::date - created_at::date), 0) < 500 then 'text:🟢'
            when coalesce(sum(now()::date - created_at::date), 0) < 1000 then 'text:🟡'
            else 'text:🔴'
          end as icon
        from github_search_issue
        where query = 'org:turbot is:open'
          and repository_full_name = 'turbot/tailpipe-plugin-sdk'
        and author ->> 'login' not in (
          select
              login
          from
              github_organization_member g
          where
              g.organization = any( array['turbot', 'turbotio'] )
          )
      EOQ
    }
  }
} 