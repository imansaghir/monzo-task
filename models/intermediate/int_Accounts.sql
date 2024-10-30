with account_created as (
    select 
        account_id,
        user_id,
        account_created_timestamp,
        account_type
    from {{ ref('stg_AccountCreated') }}
),

account_closed as (
    select account_id, account_closed_timestamp
    from {{ ref('stg_AccountClosed') }}
),

account_reopened as (
    select 
        account_id,
        account_reopened_timestamp
    from {{ ref('stg_AccountReopened') }}
),

latest_closed_reopened_time as (
select 
            ac.account_id,
            max(account_closed_timestamp) as last_closed_timestamp,
            max(account_reopened_timestamp) as last_reopened_timestamp
        from account_created ac
        left join account_closed cl on ac.account_id = cl.account_id
        left join account_reopened ro on ac.account_id = ro.account_id
        group by 1

), transaction_dates as (
    select
        account_id,
        max(transaction_date) as last_transaction_date,
        min(transaction_date) as first_transaction_date
    from {{ ref('stg_AccountTransactions') }}
    group by 1

), account_metrics as (
     select 
        account_id,
        count(account_closed_timestamp) as total_closures,
        count(account_reopened_timestamp) as total_reopens
    from account_closed cl
    full outer join account_reopened ro using (account_id)
    group by 1
)

select 
    ac.account_id,
    ac.user_id,
    ac.account_created_timestamp,
    ac.account_type,
    ls.last_closed_timestamp,
    ls.last_reopened_timestamp,
    td.first_transaction_date,
    td.last_transaction_date,
    case when am.total_closures is not null then am.total_closures else 0 end as total_closures,
    case when am.total_reopens is not null then am.total_reopens else 0 end as total_reopens,
    case when am.total_closures > 0 then true else false end as has_ever_been_closed,
    date_diff(current_date(), date(ac.account_created_timestamp), day) as account_age_days,
    date_diff(current_date(), date(ls.last_reopened_timestamp), day) as days_since_last_reopen,
    date_diff(current_date(), date(ls.last_closed_timestamp), day)  as days_since_last_closure
from account_created ac
left join latest_closed_reopened_time  ls on ac.account_id = ls.account_id
left join account_metrics am on ac.account_id = am.account_id
left join transaction_dates td on ac.account_id = td.account_id