WITH tmp_table as (
    SELECT
        "AccountId" as account_id,
        "BusinessGroup" as business_group
    FROM
        csv."MYCSVfile"
)
SELECT
    acclist.id as account_id,
    (SELECT business_group from tmp_table WHERE tmp_table.account_id=acclist.id LIMIT 1) as bg
FROM
    csv."accounts" acclist /* list of accounts updated by generateSteampipeConfig.py */