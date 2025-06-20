dashboard "pipeling_summary" {
  title = "Pipeling Repositories Status (Community issues)"
  width = 12

  text {
    value = <<-EOQ
      ## Status Indicators

      **Awaiting Initial Response: Issues older than 5 days that have not been responded to**
      - 🔴 count > 0
      - 🟢 count = 0

      **Needs Triage: Issues with 'ext:needs-triage' label - this is a label that indicates that the issue has been responded to but now needs to be triaged**
      - 🔴 age > 28 days
      - 🟡 14 days < age ≤ 28 days
      - 🟢 age ≤ 14 days

      **Awaiting Response From Author: Issues with 'ext:pending-feedback' label - this is a label that indicates that the issue has been responded to but now needs more information from the author**
      - 🔴 label age > 28 days
      - 🟡 14 days < label age ≤ 28 days
      - 🟢 label age ≤ 14 days

      **Stale Issues: issues with 'stale' label - no activity for 60 days**
      - 🔴 count > 2
      - 🟡 1 ≤ count ≤ 2
      - 🟢 count = 0

      **Total Age: sum of all open issue ages in days**
      - 🔴 total > 1000
      - 🟡 500 < total ≤ 1000
      - 🟢 total ≤ 500
    EOQ
    width = 4
  }

  container {
    title = "Steampipe"
    width = 12

    card "awaiting_initial_response_steampipe" {
      title = "Awaiting Initial Response"
      href = "/tools_team_issue_tracker.dashboard.issues_awaiting_response?input.repo.value=turbot/steampipe&input.repo=turbot/steampipe"
      sql = <<-EOQ
        with awaiting_issues as (
          select 
            i.number,
            i.title,
            i.author ->> 'login' as author,
            i.created_at
          from github_search_issue i
          left join lateral (
            select 1
            from github_issue_comment c
            where c.repository_full_name = i.repository_full_name
              and c.number = i.number
              and c.author_login in (
                select login from github_organization_member where organization in ('turbot', 'turbotio')
              )
          ) c on true
          where i.query = 'org:turbot is:open'
            and i.repository_full_name = 'turbot/steampipe'
            and i.author ->> 'login' not in (
              select login from github_organization_member where organization in ('turbot', 'turbotio')
            )
            and c is null
            and i.created_at < now() - interval '5 days'
        )
        select
          'Not Responded' as label,
          (select count(*) from awaiting_issues) as value,
          case
            when (select count(*) from awaiting_issues) > 0 then 'alert'
            else 'ok'
          end as type,
          case
            when (select count(*) from awaiting_issues) > 0 then 'text:🔴'
            else 'text:🟢'
          end as icon;
      EOQ
      width = 2
    }

    card "needs_triage_steampipe" {
      title = "Needs Triage"
      href = "/tools_team_issue_tracker.dashboard.issues_needs_triage?input.repo.value=turbot/steampipe&input.repo=turbot/steampipe"
      sql = <<-EOQ
        with triage_issues as (
          select 
            i.number,
            i.title,
            i.author ->> 'login' as author,
            i.created_at,
            now()::date - i.created_at::date as age_days
          from github_search_issue i
          where i.query = 'org:turbot is:open label:ext:needs-triage'
            and i.repository_full_name = 'turbot/steampipe'
            and i.author ->> 'login' not in (
              select login from github_organization_member where organization in ('turbot', 'turbotio')
            )
        ),
        age_stats as (
          select 
            max(age_days) as max_age,
            count(*) as total_count
          from triage_issues
        )
        select
          'Responded - needs triage' as label,
          (select total_count from age_stats) as value,
          case
            when (select max_age from age_stats) > 28 then 'alert'
            when (select max_age from age_stats) > 14 then 'info'
            else 'ok'
          end as type,
          case
            when (select max_age from age_stats) > 28 then 'text:🔴'
            when (select max_age from age_stats) > 14 then 'text:🟡'
            else 'text:🟢'
          end as icon;
      EOQ
      width = 2
    }

    card "pending_feedback_steampipe" {
      title = "Awaiting Response From Author"
      href = "/tools_team_issue_tracker.dashboard.issues_pending_feedback?input.repo.value=turbot/steampipe&input.repo=turbot/steampipe"
      sql = <<-EOQ
        with pending_issues as (
          select 
            i.number,
            i.title,
            i.author ->> 'login' as author,
            i.created_at,
            -- Try to find when the label was added by looking for the most recent team response
            -- This is a proxy since we don't have direct label change history
            coalesce(
              (select max(c.created_at)
               from github_issue_comment c
               where c.repository_full_name = i.repository_full_name
                 and c.number = i.number
                 and c.author_login in (
                   select login from github_organization_member where organization in ('turbot', 'turbotio')
                 )
              ), i.created_at
            ) as label_added_date,
            now()::date - coalesce(
              (select max(c.created_at)
               from github_issue_comment c
               where c.repository_full_name = i.repository_full_name
                 and c.number = i.number
                 and c.author_login in (
                   select login from github_organization_member where organization in ('turbot', 'turbotio')
                 )
              ), i.created_at
            )::date as label_age_days
          from github_search_issue i
          where i.query = 'org:turbot is:open label:ext:pending-feedback'
            and i.repository_full_name = 'turbot/steampipe'
            and i.author ->> 'login' not in (
              select login from github_organization_member where organization in ('turbot', 'turbotio')
            )
        ),
        age_stats as (
          select 
            max(label_age_days) as max_age,
            count(*) as total_count
          from pending_issues
        )
        select
          'Responded - needs more info' as label,
          (select total_count from age_stats) as value,
          case
            when (select max_age from age_stats) > 28 then 'alert'
            when (select max_age from age_stats) > 14 then 'info'
            else 'ok'
          end as type,
          case
            when (select max_age from age_stats) > 28 then 'text:🔴'
            when (select max_age from age_stats) > 14 then 'text:🟡'
            else 'text:🟢'
          end as icon;
      EOQ
      width = 2
    }
    
    card "community_stale_issues_status_steampipe" {
      title = "Stale Issues"
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

    card "total_communtiy_age_status_steampipe" {
      title = "Total Age"
      width = 2
      href = "/tools_team_issue_tracker.dashboard.tools_insights?input.repo.value=turbot/steampipe&input.repo=turbot/steampipe"
      sql = <<-EOQ
        select
          'Total Issues Age' as label,
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
    title = "Flowpipe"
    width = 12

    card "awaiting_initial_response_flowpipe" {
      title = "Awaiting Initial Response"
      href = "/tools_team_issue_tracker.dashboard.issues_awaiting_response?input.repo.value=turbot/flowpipe&input.repo=turbot/flowpipe"
      sql = <<-EOQ
        with awaiting_issues as (
          select 
            i.number,
            i.title,
            i.author ->> 'login' as author,
            i.created_at
          from github_search_issue i
          left join lateral (
            select 1
            from github_issue_comment c
            where c.repository_full_name = i.repository_full_name
              and c.number = i.number
              and c.author_login in (
                select login from github_organization_member where organization in ('turbot', 'turbotio')
              )
          ) c on true
          where i.query = 'org:turbot is:open'
            and i.repository_full_name = 'turbot/flowpipe'
            and i.author ->> 'login' not in (
              select login from github_organization_member where organization in ('turbot', 'turbotio')
            )
            and c is null
            and i.created_at < now() - interval '5 days'
        )
        select
          'Not Responded' as label,
          (select count(*) from awaiting_issues) as value,
          case
            when (select count(*) from awaiting_issues) > 0 then 'alert'
            else 'ok'
          end as type,
          case
            when (select count(*) from awaiting_issues) > 0 then 'text:🔴'
            else 'text:🟢'
          end as icon;
      EOQ
      width = 2
    }

    card "needs_triage_flowpipe" {
      title = "Needs Triage"
      href = "/tools_team_issue_tracker.dashboard.issues_needs_triage?input.repo.value=turbot/flowpipe&input.repo=turbot/flowpipe"
      sql = <<-EOQ
        with triage_issues as (
          select 
            i.number,
            i.title,
            i.author ->> 'login' as author,
            i.created_at,
            now()::date - i.created_at::date as age_days
          from github_search_issue i
          where i.query = 'org:turbot is:open label:ext:needs-triage'
            and i.repository_full_name = 'turbot/flowpipe'
            and i.author ->> 'login' not in (
              select login from github_organization_member where organization in ('turbot', 'turbotio')
            )
        ),
        age_stats as (
          select 
            max(age_days) as max_age,
            count(*) as total_count
          from triage_issues
        )
        select
          'Responded - needs triage' as label,
          (select total_count from age_stats) as value,
          case
            when (select max_age from age_stats) > 28 then 'alert'
            when (select max_age from age_stats) > 14 then 'info'
            else 'ok'
          end as type,
          case
            when (select max_age from age_stats) > 28 then 'text:🔴'
            when (select max_age from age_stats) > 14 then 'text:🟡'
            else 'text:🟢'
          end as icon;
      EOQ
      width = 2
    }

    card "pending_feedback_flowpipe" {
      title = "Awaiting Response From Author"
      href = "/tools_team_issue_tracker.dashboard.issues_pending_feedback?input.repo.value=turbot/flowpipe&input.repo=turbot/flowpipe"
      sql = <<-EOQ
        with pending_issues as (
          select 
            i.number,
            i.title,
            i.author ->> 'login' as author,
            i.created_at,
            -- Try to find when the label was added by looking for the most recent team response
            -- This is a proxy since we don't have direct label change history
            coalesce(
              (select max(c.created_at)
               from github_issue_comment c
               where c.repository_full_name = i.repository_full_name
                 and c.number = i.number
                 and c.author_login in (
                   select login from github_organization_member where organization in ('turbot', 'turbotio')
                 )
              ), i.created_at
            ) as label_added_date,
            now()::date - coalesce(
              (select max(c.created_at)
               from github_issue_comment c
               where c.repository_full_name = i.repository_full_name
                 and c.number = i.number
                 and c.author_login in (
                   select login from github_organization_member where organization in ('turbot', 'turbotio')
                 )
              ), i.created_at
            )::date as label_age_days
          from github_search_issue i
          where i.query = 'org:turbot is:open label:ext:pending-feedback'
            and i.repository_full_name = 'turbot/flowpipe'
            and i.author ->> 'login' not in (
              select login from github_organization_member where organization in ('turbot', 'turbotio')
            )
        ),
        age_stats as (
          select 
            max(label_age_days) as max_age,
            count(*) as total_count
          from pending_issues
        )
        select
          'Responded - needs more info' as label,
          (select total_count from age_stats) as value,
          case
            when (select max_age from age_stats) > 28 then 'alert'
            when (select max_age from age_stats) > 14 then 'info'
            else 'ok'
          end as type,
          case
            when (select max_age from age_stats) > 28 then 'text:🔴'
            when (select max_age from age_stats) > 14 then 'text:🟡'
            else 'text:🟢'
          end as icon;
      EOQ
      width = 2
    }

    card "community_stale_issues_status_flowpipe" {
      title = "Stale Issues"
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

    card "total_communtiy_age_status_flowpipe" {
      title = "Total Age"
      width = 2
      href = "/tools_team_issue_tracker.dashboard.tools_insights?input.repo.value=turbot/flowpipe&input.repo=turbot/flowpipe"
      sql = <<-EOQ
        select
          'Total Issues Age' as label,
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

    card "awaiting_initial_response_powerpipe" {
      title = "Awaiting Initial Response"
      href = "/tools_team_issue_tracker.dashboard.issues_awaiting_response?input.repo.value=turbot/powerpipe&input.repo=turbot/powerpipe"
      sql = <<-EOQ
        with awaiting_issues as (
          select 
            i.number,
            i.title,
            i.author ->> 'login' as author,
            i.created_at
          from github_search_issue i
          left join lateral (
            select 1
            from github_issue_comment c
            where c.repository_full_name = i.repository_full_name
              and c.number = i.number
              and c.author_login in (
                select login from github_organization_member where organization in ('turbot', 'turbotio')
              )
          ) c on true
          where i.query = 'org:turbot is:open'
            and i.repository_full_name = 'turbot/powerpipe'
            and i.author ->> 'login' not in (
              select login from github_organization_member where organization in ('turbot', 'turbotio')
            )
            and c is null
            and i.created_at < now() - interval '5 days'
        )
        select
          'Not Responded' as label,
          (select count(*) from awaiting_issues) as value,
          case
            when (select count(*) from awaiting_issues) > 0 then 'alert'
            else 'ok'
          end as type,
          case
            when (select count(*) from awaiting_issues) > 0 then 'text:🔴'
            else 'text:🟢'
          end as icon;
      EOQ
      width = 2
    }

    card "needs_triage_powerpipe" {
      title = "Needs Triage"
      href = "/tools_team_issue_tracker.dashboard.issues_needs_triage?input.repo.value=turbot/powerpipe&input.repo=turbot/powerpipe"
      sql = <<-EOQ
        with triage_issues as (
          select 
            i.number,
            i.title,
            i.author ->> 'login' as author,
            i.created_at,
            now()::date - i.created_at::date as age_days
          from github_search_issue i
          where i.query = 'org:turbot is:open label:ext:needs-triage'
            and i.repository_full_name = 'turbot/powerpipe'
            and i.author ->> 'login' not in (
              select login from github_organization_member where organization in ('turbot', 'turbotio')
            )
        ),
        age_stats as (
          select 
            max(age_days) as max_age,
            count(*) as total_count
          from triage_issues
        )
        select
          'Responded - needs triage' as label,
          (select total_count from age_stats) as value,
          case
            when (select max_age from age_stats) > 28 then 'alert'
            when (select max_age from age_stats) > 14 then 'info'
            else 'ok'
          end as type,
          case
            when (select max_age from age_stats) > 28 then 'text:🔴'
            when (select max_age from age_stats) > 14 then 'text:🟡'
            else 'text:🟢'
          end as icon;
      EOQ
      width = 2
    }

    card "pending_feedback_powerpipe" {
      title = "Awaiting Response From Author"
      href = "/tools_team_issue_tracker.dashboard.issues_pending_feedback?input.repo.value=turbot/powerpipe&input.repo=turbot/powerpipe"
      sql = <<-EOQ
        with pending_issues as (
          select 
            i.number,
            i.title,
            i.author ->> 'login' as author,
            i.created_at,
            -- Try to find when the label was added by looking for the most recent team response
            -- This is a proxy since we don't have direct label change history
            coalesce(
              (select max(c.created_at)
               from github_issue_comment c
               where c.repository_full_name = i.repository_full_name
                 and c.number = i.number
                 and c.author_login in (
                   select login from github_organization_member where organization in ('turbot', 'turbotio')
                 )
              ), i.created_at
            ) as label_added_date,
            now()::date - coalesce(
              (select max(c.created_at)
               from github_issue_comment c
               where c.repository_full_name = i.repository_full_name
                 and c.number = i.number
                 and c.author_login in (
                   select login from github_organization_member where organization in ('turbot', 'turbotio')
                 )
              ), i.created_at
            )::date as label_age_days
          from github_search_issue i
          where i.query = 'org:turbot is:open label:ext:pending-feedback'
            and i.repository_full_name = 'turbot/powerpipe'
            and i.author ->> 'login' not in (
              select login from github_organization_member where organization in ('turbot', 'turbotio')
            )
        ),
        age_stats as (
          select 
            max(label_age_days) as max_age,
            count(*) as total_count
          from pending_issues
        )
        select
          'Responded - needs more info' as label,
          (select total_count from age_stats) as value,
          case
            when (select max_age from age_stats) > 28 then 'alert'
            when (select max_age from age_stats) > 14 then 'info'
            else 'ok'
          end as type,
          case
            when (select max_age from age_stats) > 28 then 'text:🔴'
            when (select max_age from age_stats) > 14 then 'text:🟡'
            else 'text:🟢'
          end as icon;
      EOQ
      width = 2
    }

    card "community_stale_issues_status_powerpipe" {
      title = "Stale Issues"
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

    card "total_communtiy_age_status_powerpipe" {
      title = "Total Age"
      width = 2
      href = "/tools_team_issue_tracker.dashboard.tools_insights?input.repo.value=turbot/powerpipe&input.repo=turbot/powerpipe"
      sql = <<-EOQ
        select
          'Total Issues Age' as label,
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

    card "awaiting_initial_response_tailpipe" {
      title = "Awaiting Initial Response"
      href = "/tools_team_issue_tracker.dashboard.issues_awaiting_response?input.repo.value=turbot/tailpipe&input.repo=turbot/tailpipe"
      sql = <<-EOQ
        with awaiting_issues as (
          select 
            i.number,
            i.title,
            i.author ->> 'login' as author,
            i.created_at
          from github_search_issue i
          left join lateral (
            select 1
            from github_issue_comment c
            where c.repository_full_name = i.repository_full_name
              and c.number = i.number
              and c.author_login in (
                select login from github_organization_member where organization in ('turbot', 'turbotio')
              )
          ) c on true
          where i.query = 'org:turbot is:open'
            and i.repository_full_name = 'turbot/tailpipe'
            and i.author ->> 'login' not in (
              select login from github_organization_member where organization in ('turbot', 'turbotio')
            )
            and c is null
            and i.created_at < now() - interval '5 days'
        )
        select
          'Not Responded' as label,
          (select count(*) from awaiting_issues) as value,
          case
            when (select count(*) from awaiting_issues) > 0 then 'alert'
            else 'ok'
          end as type,
          case
            when (select count(*) from awaiting_issues) > 0 then 'text:🔴'
            else 'text:🟢'
          end as icon;
      EOQ
      width = 2
    }

    card "needs_triage_tailpipe" {
      title = "Needs Triage"
      href = "/tools_team_issue_tracker.dashboard.issues_needs_triage?input.repo.value=turbot/tailpipe&input.repo=turbot/tailpipe"
      sql = <<-EOQ
        with triage_issues as (
          select 
            i.number,
            i.title,
            i.author ->> 'login' as author,
            i.created_at,
            now()::date - i.created_at::date as age_days
          from github_search_issue i
          where i.query = 'org:turbot is:open label:ext:needs-triage'
            and i.repository_full_name = 'turbot/tailpipe'
            and i.author ->> 'login' not in (
              select login from github_organization_member where organization in ('turbot', 'turbotio')
            )
        ),
        age_stats as (
          select 
            max(age_days) as max_age,
            count(*) as total_count
          from triage_issues
        )
        select
          'Responded - needs triage' as label,
          (select total_count from age_stats) as value,
          case
            when (select max_age from age_stats) > 28 then 'alert'
            when (select max_age from age_stats) > 14 then 'info'
            else 'ok'
          end as type,
          case
            when (select max_age from age_stats) > 28 then 'text:🔴'
            when (select max_age from age_stats) > 14 then 'text:🟡'
            else 'text:🟢'
          end as icon;
      EOQ
      width = 2
    }

    card "pending_feedback_tailpipe" {
      title = "Awaiting Response From Author"
      href = "/tools_team_issue_tracker.dashboard.issues_pending_feedback?input.repo.value=turbot/tailpipe&input.repo=turbot/tailpipe"
      sql = <<-EOQ
        with pending_issues as (
          select 
            i.number,
            i.title,
            i.author ->> 'login' as author,
            i.created_at,
            -- Try to find when the label was added by looking for the most recent team response
            -- This is a proxy since we don't have direct label change history
            coalesce(
              (select max(c.created_at)
               from github_issue_comment c
               where c.repository_full_name = i.repository_full_name
                 and c.number = i.number
                 and c.author_login in (
                   select login from github_organization_member where organization in ('turbot', 'turbotio')
                 )
              ), i.created_at
            ) as label_added_date,
            now()::date - coalesce(
              (select max(c.created_at)
               from github_issue_comment c
               where c.repository_full_name = i.repository_full_name
                 and c.number = i.number
                 and c.author_login in (
                   select login from github_organization_member where organization in ('turbot', 'turbotio')
                 )
              ), i.created_at
            )::date as label_age_days
          from github_search_issue i
          where i.query = 'org:turbot is:open label:ext:pending-feedback'
            and i.repository_full_name = 'turbot/tailpipe'
            and i.author ->> 'login' not in (
              select login from github_organization_member where organization in ('turbot', 'turbotio')
            )
        ),
        age_stats as (
          select 
            max(label_age_days) as max_age,
            count(*) as total_count
          from pending_issues
        )
        select
          'Responded - needs more info' as label,
          (select total_count from age_stats) as value,
          case
            when (select max_age from age_stats) > 28 then 'alert'
            when (select max_age from age_stats) > 14 then 'info'
            else 'ok'
          end as type,
          case
            when (select max_age from age_stats) > 28 then 'text:🔴'
            when (select max_age from age_stats) > 14 then 'text:🟡'
            else 'text:🟢'
          end as icon;
      EOQ
      width = 2
    }

    card "community_stale_issues_status_tailpipe" {
      title = "Stale Issues"
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

    card "total_communtiy_age_status_tailpipe" {
      title = "Total Age"
      width = 2
      href = "/tools_team_issue_tracker.dashboard.tools_insights?input.repo.value=turbot/tailpipe&input.repo=turbot/tailpipe"
      sql = <<-EOQ
        select
          'Total Issues Age' as label,
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
    title = "Steampipe Postgres FDW"
    width = 12

    card "awaiting_initial_response_postgres_fdw" {
      title = "Awaiting Initial Response"
      href = "/tools_team_issue_tracker.dashboard.issues_awaiting_response?input.repo.value=turbot/steampipe-postgres-fdw&input.repo=turbot/steampipe-postgres-fdw"
      sql = <<-EOQ
        with awaiting_issues as (
          select 
            i.number,
            i.title,
            i.author ->> 'login' as author,
            i.created_at
          from github_search_issue i
          left join lateral (
            select 1
            from github_issue_comment c
            where c.repository_full_name = i.repository_full_name
              and c.number = i.number
              and c.author_login in (
                select login from github_organization_member where organization in ('turbot', 'turbotio')
              )
          ) c on true
          where i.query = 'org:turbot is:open'
            and i.repository_full_name = 'turbot/steampipe-postgres-fdw'
            and i.author ->> 'login' not in (
              select login from github_organization_member where organization in ('turbot', 'turbotio')
            )
            and c is null
            and i.created_at < now() - interval '5 days'
        )
        select
          'Not Responded' as label,
          (select count(*) from awaiting_issues) as value,
          case
            when (select count(*) from awaiting_issues) > 0 then 'alert'
            else 'ok'
          end as type,
          case
            when (select count(*) from awaiting_issues) > 0 then 'text:🔴'
            else 'text:🟢'
          end as icon;
      EOQ
      width = 2
    }

    card "needs_triage_postgres_fdw" {
      title = "Needs Triage"
      href = "/tools_team_issue_tracker.dashboard.issues_needs_triage?input.repo.value=turbot/steampipe-postgres-fdw&input.repo=turbot/steampipe-postgres-fdw"
      sql = <<-EOQ
        with triage_issues as (
          select 
            i.number,
            i.title,
            i.author ->> 'login' as author,
            i.created_at,
            now()::date - i.created_at::date as age_days
          from github_search_issue i
          where i.query = 'org:turbot is:open label:ext:needs-triage'
            and i.repository_full_name = 'turbot/steampipe-postgres-fdw'
            and i.author ->> 'login' not in (
              select login from github_organization_member where organization in ('turbot', 'turbotio')
            )
        ),
        age_stats as (
          select 
            max(age_days) as max_age,
            count(*) as total_count
          from triage_issues
        )
        select
          'Responded - needs triage' as label,
          (select total_count from age_stats) as value,
          case
            when (select max_age from age_stats) > 28 then 'alert'
            when (select max_age from age_stats) > 14 then 'info'
            else 'ok'
          end as type,
          case
            when (select max_age from age_stats) > 28 then 'text:🔴'
            when (select max_age from age_stats) > 14 then 'text:🟡'
            else 'text:🟢'
          end as icon;
      EOQ
      width = 2
    }

    card "pending_feedback_postgres_fdw" {
      title = "Awaiting Response From Author"
      href = "/tools_team_issue_tracker.dashboard.issues_pending_feedback?input.repo.value=turbot/steampipe-postgres-fdw&input.repo=turbot/steampipe-postgres-fdw"
      sql = <<-EOQ
        with pending_issues as (
          select 
            i.number,
            i.title,
            i.author ->> 'login' as author,
            i.created_at,
            -- Try to find when the label was added by looking for the most recent team response
            -- This is a proxy since we don't have direct label change history
            coalesce(
              (select max(c.created_at)
               from github_issue_comment c
               where c.repository_full_name = i.repository_full_name
                 and c.number = i.number
                 and c.author_login in (
                   select login from github_organization_member where organization in ('turbot', 'turbotio')
                 )
              ), i.created_at
            ) as label_added_date,
            now()::date - coalesce(
              (select max(c.created_at)
               from github_issue_comment c
               where c.repository_full_name = i.repository_full_name
                 and c.number = i.number
                 and c.author_login in (
                   select login from github_organization_member where organization in ('turbot', 'turbotio')
                 )
              ), i.created_at
            )::date as label_age_days
          from github_search_issue i
          where i.query = 'org:turbot is:open label:ext:pending-feedback'
            and i.repository_full_name = 'turbot/steampipe-postgres-fdw'
            and i.author ->> 'login' not in (
              select login from github_organization_member where organization in ('turbot', 'turbotio')
            )
        ),
        age_stats as (
          select 
            max(label_age_days) as max_age,
            count(*) as total_count
          from pending_issues
        )
        select
          'Responded - needs more info' as label,
          (select total_count from age_stats) as value,
          case
            when (select max_age from age_stats) > 28 then 'alert'
            when (select max_age from age_stats) > 14 then 'info'
            else 'ok'
          end as type,
          case
            when (select max_age from age_stats) > 28 then 'text:🔴'
            when (select max_age from age_stats) > 14 then 'text:🟡'
            else 'text:🟢'
          end as icon;
      EOQ
      width = 2
    }

    card "community_stale_issues_status_postgres_fdw" {
      title = "Stale Issues"
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

    card "total_communtiy_age_status_postgres_fdw" {
      title = "Total Age"
      width = 2
      href = "/tools_team_issue_tracker.dashboard.tools_insights?input.repo.value=turbot/steampipe-postgres-fdw&input.repo=turbot/steampipe-postgres-fdw"
      sql = <<-EOQ
        select
          'Total Issues Age' as label,
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

    card "awaiting_initial_response_plugin_sdk" {
      title = "Awaiting Initial Response"
      href = "/tools_team_issue_tracker.dashboard.issues_awaiting_response?input.repo.value=turbot/steampipe-plugin-sdk&input.repo=turbot/steampipe-plugin-sdk"
      sql = <<-EOQ
        with awaiting_issues as (
          select 
            i.number,
            i.title,
            i.author ->> 'login' as author,
            i.created_at
          from github_search_issue i
          left join lateral (
            select 1
            from github_issue_comment c
            where c.repository_full_name = i.repository_full_name
              and c.number = i.number
              and c.author_login in (
                select login from github_organization_member where organization in ('turbot', 'turbotio')
              )
          ) c on true
          where i.query = 'org:turbot is:open'
            and i.repository_full_name = 'turbot/steampipe-plugin-sdk'
            and i.author ->> 'login' not in (
              select login from github_organization_member where organization in ('turbot', 'turbotio')
            )
            and c is null
            and i.created_at < now() - interval '5 days'
        )
        select
          'Not Responded' as label,
          (select count(*) from awaiting_issues) as value,
          case
            when (select count(*) from awaiting_issues) > 0 then 'alert'
            else 'ok'
          end as type,
          case
            when (select count(*) from awaiting_issues) > 0 then 'text:🔴'
            else 'text:🟢'
          end as icon;
      EOQ
      width = 2
    }

    card "needs_triage_plugin_sdk" {
      title = "Needs Triage"
      href = "/tools_team_issue_tracker.dashboard.issues_needs_triage?input.repo.value=turbot/steampipe-plugin-sdk&input.repo=turbot/steampipe-plugin-sdk"
      sql = <<-EOQ
        with triage_issues as (
          select 
            i.number,
            i.title,
            i.author ->> 'login' as author,
            i.created_at,
            now()::date - i.created_at::date as age_days
          from github_search_issue i
          where i.query = 'org:turbot is:open label:ext:needs-triage'
            and i.repository_full_name = 'turbot/steampipe-plugin-sdk'
            and i.author ->> 'login' not in (
              select login from github_organization_member where organization in ('turbot', 'turbotio')
            )
        ),
        age_stats as (
          select 
            max(age_days) as max_age,
            count(*) as total_count
          from triage_issues
        )
        select
          'Responded - needs triage' as label,
          (select total_count from age_stats) as value,
          case
            when (select max_age from age_stats) > 28 then 'alert'
            when (select max_age from age_stats) > 14 then 'info'
            else 'ok'
          end as type,
          case
            when (select max_age from age_stats) > 28 then 'text:🔴'
            when (select max_age from age_stats) > 14 then 'text:🟡'
            else 'text:🟢'
          end as icon;
      EOQ
      width = 2
    }

    card "pending_feedback_plugin_sdk" {
      title = "Awaiting Response From Author"
      href = "/tools_team_issue_tracker.dashboard.issues_pending_feedback?input.repo.value=turbot/steampipe-plugin-sdk&input.repo=turbot/steampipe-plugin-sdk"
      sql = <<-EOQ
        with pending_issues as (
          select 
            i.number,
            i.title,
            i.author ->> 'login' as author,
            i.created_at,
            -- Try to find when the label was added by looking for the most recent team response
            -- This is a proxy since we don't have direct label change history
            coalesce(
              (select max(c.created_at)
               from github_issue_comment c
               where c.repository_full_name = i.repository_full_name
                 and c.number = i.number
                 and c.author_login in (
                   select login from github_organization_member where organization in ('turbot', 'turbotio')
                 )
              ), i.created_at
            ) as label_added_date,
            now()::date - coalesce(
              (select max(c.created_at)
               from github_issue_comment c
               where c.repository_full_name = i.repository_full_name
                 and c.number = i.number
                 and c.author_login in (
                   select login from github_organization_member where organization in ('turbot', 'turbotio')
                 )
              ), i.created_at
            )::date as label_age_days
          from github_search_issue i
          where i.query = 'org:turbot is:open label:ext:pending-feedback'
            and i.repository_full_name = 'turbot/steampipe-plugin-sdk'
            and i.author ->> 'login' not in (
              select login from github_organization_member where organization in ('turbot', 'turbotio')
            )
        ),
        age_stats as (
          select 
            max(label_age_days) as max_age,
            count(*) as total_count
          from pending_issues
        )
        select
          'Responded - needs more info' as label,
          (select total_count from age_stats) as value,
          case
            when (select max_age from age_stats) > 28 then 'alert'
            when (select max_age from age_stats) > 14 then 'info'
            else 'ok'
          end as type,
          case
            when (select max_age from age_stats) > 28 then 'text:🔴'
            when (select max_age from age_stats) > 14 then 'text:🟡'
            else 'text:🟢'
          end as icon;
      EOQ
      width = 2
    }

    card "community_stale_issues_status_plugin_sdk" {
      title = "Stale Issues"
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

    card "total_communtiy_age_status_plugin_sdk" {
      title = "Total Age"
      width = 2
      href = "/tools_team_issue_tracker.dashboard.tools_insights?input.repo.value=turbot/steampipe-plugin-sdk&input.repo=turbot/steampipe-plugin-sdk"
      sql = <<-EOQ
        select
          'Total Issues Age' as label,
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
    title = "Tailpipe Plugin SDK"
    width = 12

    card "awaiting_initial_response_tailpipe_plugin_sdk" {
      title = "Awaiting Initial Response"
      href = "/tools_team_issue_tracker.dashboard.issues_awaiting_response?input.repo.value=turbot/tailpipe-plugin-sdk&input.repo=turbot/tailpipe-plugin-sdk"
      sql = <<-EOQ
        with awaiting_issues as (
          select 
            i.number,
            i.title,
            i.author ->> 'login' as author,
            i.created_at
          from github_search_issue i
          left join lateral (
            select 1
            from github_issue_comment c
            where c.repository_full_name = i.repository_full_name
              and c.number = i.number
              and c.author_login in (
                select login from github_organization_member where organization in ('turbot', 'turbotio')
              )
          ) c on true
          where i.query = 'org:turbot is:open'
            and i.repository_full_name = 'turbot/tailpipe-plugin-sdk'
            and i.author ->> 'login' not in (
              select login from github_organization_member where organization in ('turbot', 'turbotio')
            )
            and c is null
            and i.created_at < now() - interval '5 days'
        )
        select
          'Not Responded' as label,
          (select count(*) from awaiting_issues) as value,
          case
            when (select count(*) from awaiting_issues) > 0 then 'alert'
            else 'ok'
          end as type,
          case
            when (select count(*) from awaiting_issues) > 0 then 'text:🔴'
            else 'text:🟢'
          end as icon;
      EOQ
      width = 2
    }

    card "needs_triage_tailpipe_plugin_sdk" {
      title = "Needs Triage"
      href = "/tools_team_issue_tracker.dashboard.issues_needs_triage?input.repo.value=turbot/tailpipe-plugin-sdk&input.repo=turbot/tailpipe-plugin-sdk"
      sql = <<-EOQ
        with triage_issues as (
          select 
            i.number,
            i.title,
            i.author ->> 'login' as author,
            i.created_at,
            now()::date - i.created_at::date as age_days
          from github_search_issue i
          where i.query = 'org:turbot is:open label:ext:needs-triage'
            and i.repository_full_name = 'turbot/tailpipe-plugin-sdk'
            and i.author ->> 'login' not in (
              select login from github_organization_member where organization in ('turbot', 'turbotio')
            )
        ),
        age_stats as (
          select 
            max(age_days) as max_age,
            count(*) as total_count
          from triage_issues
        )
        select
          'Responded - needs triage' as label,
          (select total_count from age_stats) as value,
          case
            when (select max_age from age_stats) > 28 then 'alert'
            when (select max_age from age_stats) > 14 then 'info'
            else 'ok'
          end as type,
          case
            when (select max_age from age_stats) > 28 then 'text:🔴'
            when (select max_age from age_stats) > 14 then 'text:🟡'
            else 'text:🟢'
          end as icon;
      EOQ
      width = 2
    }

    card "pending_feedback_tailpipe_plugin_sdk" {
      title = "Awaiting Response From Author"
      href = "/tools_team_issue_tracker.dashboard.issues_pending_feedback?input.repo.value=turbot/tailpipe-plugin-sdk&input.repo=turbot/tailpipe-plugin-sdk"
      sql = <<-EOQ
        with pending_issues as (
          select 
            i.number,
            i.title,
            i.author ->> 'login' as author,
            i.created_at,
            -- Try to find when the label was added by looking for the most recent team response
            -- This is a proxy since we don't have direct label change history
            coalesce(
              (select max(c.created_at)
               from github_issue_comment c
               where c.repository_full_name = i.repository_full_name
                 and c.number = i.number
                 and c.author_login in (
                   select login from github_organization_member where organization in ('turbot', 'turbotio')
                 )
              ), i.created_at
            ) as label_added_date,
            now()::date - coalesce(
              (select max(c.created_at)
               from github_issue_comment c
               where c.repository_full_name = i.repository_full_name
                 and c.number = i.number
                 and c.author_login in (
                   select login from github_organization_member where organization in ('turbot', 'turbotio')
                 )
              ), i.created_at
            )::date as label_age_days
          from github_search_issue i
          where i.query = 'org:turbot is:open label:ext:pending-feedback'
            and i.repository_full_name = 'turbot/tailpipe-plugin-sdk'
            and i.author ->> 'login' not in (
              select login from github_organization_member where organization in ('turbot', 'turbotio')
            )
        ),
        age_stats as (
          select 
            max(label_age_days) as max_age,
            count(*) as total_count
          from pending_issues
        )
        select
          'Responded - needs more info' as label,
          (select total_count from age_stats) as value,
          case
            when (select max_age from age_stats) > 28 then 'alert'
            when (select max_age from age_stats) > 14 then 'info'
            else 'ok'
          end as type,
          case
            when (select max_age from age_stats) > 28 then 'text:🔴'
            when (select max_age from age_stats) > 14 then 'text:🟡'
            else 'text:🟢'
          end as icon;
      EOQ
      width = 2
    }

    card "community_stale_issues_status_tailpipe_plugin_sdk" {
      title = "Stale Issues"
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

    card "total_communtiy_age_status_tailpipe_plugin_sdk" {
      title = "Total Age"
      width = 2
      href = "/tools_team_issue_tracker.dashboard.tools_insights?input.repo.value=turbot/tailpipe-plugin-sdk&input.repo=turbot/tailpipe-plugin-sdk"
      sql = <<-EOQ
        select
          'Total Issues Age' as label,
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