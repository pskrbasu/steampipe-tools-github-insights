dashboard "pipeling_summary" {
  title = "Pipeling Repositories Status"
  width = 12

  container {
    title = "Steampipe"
    width = 12
    
    card "followup_issues_status_steampipe" {
      title = "Follow-up (Community)"
      href = "/tools_team_issue_tracker.dashboard.issues_awaiting_org_followup?input.repo.value=turbot/steampipe&input.repo=turbot/steampipe"
      width = 2
      sql = <<-EOQ
        with issue_count as (
          select count(*) as cnt
          from (
            select 1
            from github_search_issue i
            join lateral (
              select author_login, created_at
              from github_issue_comment
              where repository_full_name = i.repository_full_name
                and number = i.number
              order by created_at desc
              limit 1
            ) c on true
            where i.query = 'org:turbot is:open'
              and i.repository_full_name = 'turbot/steampipe'
              and i.author ->> 'login' not in (
                select login from github_organization_member where organization in ('turbot', 'turbotio')
              )
              and c.author_login = i.author ->> 'login'
          ) sub
        )
        select
          'Follow-up Issues' as label,
          cnt as value,
          case
            when cnt > 2 then 'alert'
            when cnt > 0 then 'info'
            else 'ok'
          end as type,
          case
            when cnt > 2 then 'text:🔴'
            when cnt > 0 then 'text:🟡'
            else 'text:🟢'
          end as icon
        from issue_count;
      EOQ
    }
    card "community_stale_issues_status_steampipe" {
      title = "Stale Issues (Community)"
      href = "/tools_team_issue_tracker.dashboard.stale_issues?input.repo.value=turbot/steampipe&input.repo=turbot/steampipe"
      sql = <<-EOQ
        with stale_count as (
          select count(*) as cnt
          from (
            select 1
            from github_search_issue
            where query = 'org:turbot is:open label:stale'
              and repository_full_name = 'turbot/steampipe'
              and author ->> 'login' not in (
                select login from github_organization_member where organization in ('turbot', 'turbotio')
              )
          ) sub
        )
        select
          'Stale Issues' as label,
          cnt as value,
          case
            when cnt > 2 then 'alert'
            when cnt > 0 then 'info'
            else 'ok'
          end as type,
          case
            when cnt > 2 then 'text:🔴'
            when cnt > 0 then 'text:🟡'
            else 'text:🟢'
          end as icon
        from stale_count;
      EOQ
      width = 2
    }
    card "total_age_status_steampipe" {
      title = "Total Age Status"
      width = 2
      href = "/tools_team_issue_tracker.dashboard.tools_insights?input.repo.value=turbot/steampipe&input.repo=turbot/steampipe"
      sql = <<-EOQ
        select
          'Total Age Status' as label,
          coalesce(sum(now()::date - created_at::date), 0) as value,
          case
            when coalesce(sum(now()::date - created_at::date), 0) < 1000 then 'ok'
            when coalesce(sum(now()::date - created_at::date), 0) < 1500 then 'info'
            else 'alert'
          end as type,
          case
            when coalesce(sum(now()::date - created_at::date), 0) < 1000 then 'text:🟢'
            when coalesce(sum(now()::date - created_at::date), 0) < 1500 then 'text:🟡'
            else 'text:🔴'
          end as icon
        from github_search_issue
        where query = 'org:turbot is:open'
          and repository_full_name = 'turbot/steampipe';
      EOQ
    }
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

    card "followup_issues_status_postgres_fdw" {
      title = "Follow-up (Community)"
      href = "/tools_team_issue_tracker.dashboard.issues_awaiting_org_followup?input.repo.value=turbot/steampipe-postgres-fdw&input.repo=turbot/steampipe-postgres-fdw"
      sql = <<-EOQ
        with issue_count as (
          select count(*) as cnt
          from (
            select 1
            from github_search_issue i
            join lateral (
              select author_login, created_at
              from github_issue_comment
              where repository_full_name = i.repository_full_name
                and number = i.number
              order by created_at desc
              limit 1
            ) c on true
            where i.query = 'org:turbot is:open'
              and i.repository_full_name = 'turbot/steampipe-postgres-fdw'
              and i.author ->> 'login' not in (
                select login from github_organization_member where organization in ('turbot', 'turbotio')
              )
              and c.author_login = i.author ->> 'login'
          ) sub
        )
        select
          'Follow-up Issues' as label,
          cnt as value,
          case
            when cnt > 2 then 'alert'
            when cnt > 0 then 'info'
            else 'ok'
          end as type,
          case
            when cnt > 2 then 'text:🔴'
            when cnt > 0 then 'text:🟡'
            else 'text:🟢'
          end as icon
        from issue_count;
      EOQ
      width = 2
    }
    card "community_stale_issues_status_postgres_fdw" {
      title = "Stale Issues (Community)"
      href = "/tools_team_issue_tracker.dashboard.stale_issues?input.repo.value=turbot/steampipe-postgres-fdw&input.repo=turbot/steampipe-postgres-fdw"
      sql = <<-EOQ
        with stale_count as (
          select count(*) as cnt
          from (
            select 1
            from github_search_issue
            where query = 'org:turbot is:open label:stale'
              and repository_full_name = 'turbot/steampipe-postgres-fdw'
              and author ->> 'login' not in (
                select login from github_organization_member where organization in ('turbot', 'turbotio')
              )
          ) sub
        )
        select
          'Stale Issues' as label,
          cnt as value,
          case
            when cnt > 2 then 'alert'
            when cnt > 0 then 'info'
            else 'ok'
          end as type,
          case
            when cnt > 2 then 'text:🔴'
            when cnt > 0 then 'text:🟡'
            else 'text:🟢'
          end as icon
        from stale_count;
      EOQ
      width = 2
    }
    card "total_age_status_postgres_fdw" {
      title = "Total Age Status"
      width = 2
      href = "/tools_team_issue_tracker.dashboard.tools_insights?input.repo.value=turbot/steampipe-postgres-fdw&input.repo=turbot/steampipe-postgres-fdw"
      sql = <<-EOQ
        select
          'Total Age Status' as label,
          coalesce(sum(now()::date - created_at::date), 0) as value,
          case
            when coalesce(sum(now()::date - created_at::date), 0) < 1000 then 'ok'
            when coalesce(sum(now()::date - created_at::date), 0) < 1500 then 'info'
            else 'alert'
          end as type,
          case
            when coalesce(sum(now()::date - created_at::date), 0) < 1000 then 'text:🟢'
            when coalesce(sum(now()::date - created_at::date), 0) < 1500 then 'text:🟡'
            else 'text:🔴'
          end as icon
        from github_search_issue
        where query = 'org:turbot is:open'
          and repository_full_name = 'turbot/steampipe-postgres-fdw';
      EOQ
    }
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

    card "followup_issues_status_plugin_sdk" {
      title = "Follow-up (Community)"
      href = "/tools_team_issue_tracker.dashboard.issues_awaiting_org_followup?input.repo.value=turbot/steampipe-plugin-sdk&input.repo=turbot/steampipe-plugin-sdk"
      sql = <<-EOQ
        with issue_count as (
          select count(*) as cnt
          from (
            select 1
            from github_search_issue i
            join lateral (
              select author_login, created_at
              from github_issue_comment
              where repository_full_name = i.repository_full_name
                and number = i.number
              order by created_at desc
              limit 1
            ) c on true
            where i.query = 'org:turbot is:open'
              and i.repository_full_name = 'turbot/steampipe-plugin-sdk'
              and i.author ->> 'login' not in (
                select login from github_organization_member where organization in ('turbot', 'turbotio')
              )
              and c.author_login = i.author ->> 'login'
          ) sub
        )
        select
          'Follow-up Issues' as label,
          cnt as value,
          case
            when cnt > 2 then 'alert'
            when cnt > 0 then 'info'
            else 'ok'
          end as type,
          case
            when cnt > 2 then 'text:🔴'
            when cnt > 0 then 'text:🟡'
            else 'text:🟢'
          end as icon
        from issue_count;
      EOQ
      width = 2
    }
    card "community_stale_issues_status_plugin_sdk" {
      title = "Stale Issues (Community)"
      href = "/tools_team_issue_tracker.dashboard.stale_issues?input.repo.value=turbot/steampipe-plugin-sdk&input.repo=turbot/steampipe-plugin-sdk"
      sql = <<-EOQ
        with stale_count as (
          select count(*) as cnt
          from (
            select 1
            from github_search_issue
            where query = 'org:turbot is:open label:stale'
              and repository_full_name = 'turbot/steampipe-plugin-sdk'
              and author ->> 'login' not in (
                select login from github_organization_member where organization in ('turbot', 'turbotio')
              )
          ) sub
        )
        select
          'Stale Issues' as label,
          cnt as value,
          case
            when cnt > 2 then 'alert'
            when cnt > 0 then 'info'
            else 'ok'
          end as type,
          case
            when cnt > 2 then 'text:🔴'
            when cnt > 0 then 'text:🟡'
            else 'text:🟢'
          end as icon
        from stale_count;
      EOQ
      width = 2
    }
    card "total_age_status_plugin_sdk" {
      title = "Total Age Status"
      width = 2
      href = "/tools_team_issue_tracker.dashboard.tools_insights?input.repo.value=turbot/steampipe-plugin-sdk&input.repo=turbot/steampipe-plugin-sdk"
      sql = <<-EOQ
        select
          'Total Age Status' as label,
          coalesce(sum(now()::date - created_at::date), 0) as value,
          case
            when coalesce(sum(now()::date - created_at::date), 0) < 1000 then 'ok'
            when coalesce(sum(now()::date - created_at::date), 0) < 1500 then 'info'
            else 'alert'
          end as type,
          case
            when coalesce(sum(now()::date - created_at::date), 0) < 1000 then 'text:🟢'
            when coalesce(sum(now()::date - created_at::date), 0) < 1500 then 'text:🟡'
            else 'text:🔴'
          end as icon
        from github_search_issue
        where query = 'org:turbot is:open'
          and repository_full_name = 'turbot/steampipe-plugin-sdk';
      EOQ
    }
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

    card "followup_issues_status_flowpipe" {
      title = "Follow-up (Community)"
      href = "/tools_team_issue_tracker.dashboard.issues_awaiting_org_followup?input.repo.value=turbot/flowpipe&input.repo=turbot/flowpipe"
      sql = <<-EOQ
        with issue_count as (
          select count(*) as cnt
          from (
            select 1
            from github_search_issue i
            join lateral (
              select author_login, created_at
              from github_issue_comment
              where repository_full_name = i.repository_full_name
                and number = i.number
              order by created_at desc
              limit 1
            ) c on true
            where i.query = 'org:turbot is:open'
              and i.repository_full_name = 'turbot/flowpipe'
              and i.author ->> 'login' not in (
                select login from github_organization_member where organization in ('turbot', 'turbotio')
              )
              and c.author_login = i.author ->> 'login'
          ) sub
        )
        select
          'Follow-up Issues' as label,
          cnt as value,
          case
            when cnt > 2 then 'alert'
            when cnt > 0 then 'info'
            else 'ok'
          end as type,
          case
            when cnt > 2 then 'text:🔴'
            when cnt > 0 then 'text:🟡'
            else 'text:🟢'
          end as icon
        from issue_count;
      EOQ
      width = 2
    }
    card "community_stale_issues_status_flowpipe" {
      title = "Stale Issues (Community)"
      href = "/tools_team_issue_tracker.dashboard.stale_issues?input.repo.value=turbot/flowpipe&input.repo=turbot/flowpipe"
      sql = <<-EOQ
        with stale_count as (
          select count(*) as cnt
          from (
            select 1
            from github_search_issue
            where query = 'org:turbot is:open label:stale'
              and repository_full_name = 'turbot/flowpipe'
              and author ->> 'login' not in (
                select login from github_organization_member where organization in ('turbot', 'turbotio')
              )
          ) sub
        )
        select
          'Stale Issues' as label,
          cnt as value,
          case
            when cnt > 2 then 'alert'
            when cnt > 0 then 'info'
            else 'ok'
          end as type,
          case
            when cnt > 2 then 'text:🔴'
            when cnt > 0 then 'text:🟡'
            else 'text:🟢'
          end as icon
        from stale_count;
      EOQ
      width = 2
    }
    card "total_age_status_flowpipe" {
      title = "Total Age Status"
      width = 2
      href = "/tools_team_issue_tracker.dashboard.tools_insights?input.repo.value=turbot/flowpipe&input.repo=turbot/flowpipe"
      sql = <<-EOQ
        select
          'Total Age Status' as label,
          coalesce(sum(now()::date - created_at::date), 0) as value,
          case
            when coalesce(sum(now()::date - created_at::date), 0) < 1000 then 'ok'
            when coalesce(sum(now()::date - created_at::date), 0) < 1500 then 'info'
            else 'alert'
          end as type,
          case
            when coalesce(sum(now()::date - created_at::date), 0) < 1000 then 'text:🟢'
            when coalesce(sum(now()::date - created_at::date), 0) < 1500 then 'text:🟡'
            else 'text:🔴'
          end as icon
        from github_search_issue
        where query = 'org:turbot is:open'
          and repository_full_name = 'turbot/flowpipe';
      EOQ
    }
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

    card "followup_issues_status_powerpipe" {
      title = "Follow-up (Community)"
      href = "/tools_team_issue_tracker.dashboard.issues_awaiting_org_followup?input.repo.value=turbot/powerpipe&input.repo=turbot/powerpipe"
      sql = <<-EOQ
        with issue_count as (
          select count(*) as cnt
          from (
            select 1
            from github_search_issue i
            join lateral (
              select author_login, created_at
              from github_issue_comment
              where repository_full_name = i.repository_full_name
                and number = i.number
              order by created_at desc
              limit 1
            ) c on true
            where i.query = 'org:turbot is:open'
              and i.repository_full_name = 'turbot/powerpipe'
              and i.author ->> 'login' not in (
                select login from github_organization_member where organization in ('turbot', 'turbotio')
              )
              and c.author_login = i.author ->> 'login'
          ) sub
        )
        select
          'Follow-up Issues' as label,
          cnt as value,
          case
            when cnt > 2 then 'alert'
            when cnt > 0 then 'info'
            else 'ok'
          end as type,
          case
            when cnt > 2 then 'text:🔴'
            when cnt > 0 then 'text:🟡'
            else 'text:🟢'
          end as icon
        from issue_count;
      EOQ
      width = 2
    }
    card "community_stale_issues_status_powerpipe" {
      title = "Stale Issues (Community)"
      href = "/tools_team_issue_tracker.dashboard.stale_issues?input.repo.value=turbot/powerpipe&input.repo=turbot/powerpipe"
      sql = <<-EOQ
        with stale_count as (
          select count(*) as cnt
          from (
            select 1
            from github_search_issue
            where query = 'org:turbot is:open label:stale'
              and repository_full_name = 'turbot/powerpipe'
              and author ->> 'login' not in (
                select login from github_organization_member where organization in ('turbot', 'turbotio')
              )
          ) sub
        )
        select
          'Stale Issues' as label,
          cnt as value,
          case
            when cnt > 2 then 'alert'
            when cnt > 0 then 'info'
            else 'ok'
          end as type,
          case
            when cnt > 2 then 'text:🔴'
            when cnt > 0 then 'text:🟡'
            else 'text:🟢'
          end as icon
        from stale_count;
      EOQ
      width = 2
    }
    card "total_age_status_powerpipe" {
      title = "Total Age Status"
      width = 2
      href = "/tools_team_issue_tracker.dashboard.tools_insights?input.repo.value=turbot/powerpipe&input.repo=turbot/powerpipe"
      sql = <<-EOQ
        select
          'Total Age Status' as label,
          coalesce(sum(now()::date - created_at::date), 0) as value,
          case
            when coalesce(sum(now()::date - created_at::date), 0) < 1000 then 'ok'
            when coalesce(sum(now()::date - created_at::date), 0) < 1500 then 'info'
            else 'alert'
          end as type,
          case
            when coalesce(sum(now()::date - created_at::date), 0) < 1000 then 'text:🟢'
            when coalesce(sum(now()::date - created_at::date), 0) < 1500 then 'text:🟡'
            else 'text:🔴'
          end as icon
        from github_search_issue
        where query = 'org:turbot is:open'
          and repository_full_name = 'turbot/powerpipe';
      EOQ
    }
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

    card "followup_issues_status_tailpipe" {
      title = "Follow-up (Community)"
      href = "/tools_team_issue_tracker.dashboard.issues_awaiting_org_followup?input.repo.value=turbot/tailpipe&input.repo=turbot/tailpipe"
      sql = <<-EOQ
        with issue_count as (
          select count(*) as cnt
          from (
            select 1
            from github_search_issue i
            join lateral (
              select author_login, created_at
              from github_issue_comment
              where repository_full_name = i.repository_full_name
                and number = i.number
              order by created_at desc
              limit 1
            ) c on true
            where i.query = 'org:turbot is:open'
              and i.repository_full_name = 'turbot/tailpipe'
              and i.author ->> 'login' not in (
                select login from github_organization_member where organization in ('turbot', 'turbotio')
              )
              and c.author_login = i.author ->> 'login'
          ) sub
        )
        select
          'Follow-up Issues' as label,
          cnt as value,
          case
            when cnt > 2 then 'alert'
            when cnt > 0 then 'info'
            else 'ok'
          end as type,
          case
            when cnt > 2 then 'text:🔴'
            when cnt > 0 then 'text:🟡'
            else 'text:🟢'
          end as icon
        from issue_count;
      EOQ
      width = 2
    }
    card "community_stale_issues_status_tailpipe" {
      title = "Stale Issues (Community)"
      href = "/tools_team_issue_tracker.dashboard.stale_issues?input.repo.value=turbot/tailpipe&input.repo=turbot/tailpipe"
      sql = <<-EOQ
        with stale_count as (
          select count(*) as cnt
          from (
            select 1
            from github_search_issue
            where query = 'org:turbot is:open label:stale'
              and repository_full_name = 'turbot/tailpipe'
              and author ->> 'login' not in (
                select login from github_organization_member where organization in ('turbot', 'turbotio')
              )
          ) sub
        )
        select
          'Stale Issues' as label,
          cnt as value,
          case
            when cnt > 2 then 'alert'
            when cnt > 0 then 'info'
            else 'ok'
          end as type,
          case
            when cnt > 2 then 'text:🔴'
            when cnt > 0 then 'text:🟡'
            else 'text:🟢'
          end as icon
        from stale_count;
      EOQ
      width = 2
    }
    card "total_age_status_tailpipe" {
      title = "Total Age Status"
      width = 2
      href = "/tools_team_issue_tracker.dashboard.tools_insights?input.repo.value=turbot/tailpipe&input.repo=turbot/tailpipe"
      sql = <<-EOQ
        select
          'Total Age Status' as label,
          coalesce(sum(now()::date - created_at::date), 0) as value,
          case
            when coalesce(sum(now()::date - created_at::date), 0) < 1000 then 'ok'
            when coalesce(sum(now()::date - created_at::date), 0) < 1500 then 'info'
            else 'alert'
          end as type,
          case
            when coalesce(sum(now()::date - created_at::date), 0) < 1000 then 'text:🟢'
            when coalesce(sum(now()::date - created_at::date), 0) < 1500 then 'text:🟡'
            else 'text:🔴'
          end as icon
        from github_search_issue
        where query = 'org:turbot is:open'
          and repository_full_name = 'turbot/tailpipe';
      EOQ
    }
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

    card "followup_issues_status_tailpipe_plugin_sdk" {
      title = "Follow-up (Community)"
      href = "/tools_team_issue_tracker.dashboard.issues_awaiting_org_followup?input.repo.value=turbot/tailpipe-plugin-sdk&input.repo=turbot/tailpipe-plugin-sdk"
      sql = <<-EOQ
        with issue_count as (
          select count(*) as cnt
          from (
            select 1
            from github_search_issue i
            join lateral (
              select author_login, created_at
              from github_issue_comment
              where repository_full_name = i.repository_full_name
                and number = i.number
              order by created_at desc
              limit 1
            ) c on true
            where i.query = 'org:turbot is:open'
              and i.repository_full_name = 'turbot/tailpipe-plugin-sdk'
              and i.author ->> 'login' not in (
                select login from github_organization_member where organization in ('turbot', 'turbotio')
              )
              and c.author_login = i.author ->> 'login'
          ) sub
        )
        select
          'Follow-up Issues' as label,
          cnt as value,
          case
            when cnt > 2 then 'alert'
            when cnt > 0 then 'info'
            else 'ok'
          end as type,
          case
            when cnt > 2 then 'text:🔴'
            when cnt > 0 then 'text:🟡'
            else 'text:🟢'
          end as icon
        from issue_count;
      EOQ
      width = 2
    }
    card "community_stale_issues_status_tailpipe_plugin_sdk" {
      title = "Stale Issues (Community)"
      href = "/tools_team_issue_tracker.dashboard.stale_issues?input.repo.value=turbot/tailpipe-plugin-sdk&input.repo=turbot/tailpipe-plugin-sdk"
      sql = <<-EOQ
        with stale_count as (
          select count(*) as cnt
          from (
            select 1
            from github_search_issue
            where query = 'org:turbot is:open label:stale'
              and repository_full_name = 'turbot/tailpipe-plugin-sdk'
              and author ->> 'login' not in (
                select login from github_organization_member where organization in ('turbot', 'turbotio')
              )
          ) sub
        )
        select
          'Stale Issues' as label,
          cnt as value,
          case
            when cnt > 2 then 'alert'
            when cnt > 0 then 'info'
            else 'ok'
          end as type,
          case
            when cnt > 2 then 'text:🔴'
            when cnt > 0 then 'text:🟡'
            else 'text:🟢'
          end as icon
        from stale_count;
      EOQ
      width = 2
    }
    card "total_age_status_tailpipe_plugin_sdk" {
      title = "Total Age Status"
      width = 2
      href = "/tools_team_issue_tracker.dashboard.tools_insights?input.repo.value=turbot/tailpipe-plugin-sdk&input.repo=turbot/tailpipe-plugin-sdk"
      sql = <<-EOQ
        select
          'Total Age Status' as label,
          coalesce(sum(now()::date - created_at::date), 0) as value,
          case
            when coalesce(sum(now()::date - created_at::date), 0) < 1000 then 'ok'
            when coalesce(sum(now()::date - created_at::date), 0) < 1500 then 'info'
            else 'alert'
          end as type,
          case
            when coalesce(sum(now()::date - created_at::date), 0) < 1000 then 'text:🟢'
            when coalesce(sum(now()::date - created_at::date), 0) < 1500 then 'text:🟡'
            else 'text:🔴'
          end as icon
        from github_search_issue
        where query = 'org:turbot is:open'
          and repository_full_name = 'turbot/tailpipe-plugin-sdk';
      EOQ
    }
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