-- Create a date range from first account created by a user to latest transaction
with date_spine as (
    select
        day_date as transaction_date
    from {{ ref('dates') }}
    where day_date between ( 
        select min(date(account_created_timestamp)) from {{ ref('int_Accounts') }})
        and (select max(transaction_date) from {{ ref('stg_AccountTransactions') }})

-- Get base user list
), user_spine as ( 
    select 
        distinct user_id 
    from {{ ref('int_Accounts') }}

-- Create a record for each date-user combination
), date_user_spine as (
    select 
        d.transaction_date,
        u.user_id
    from date_spine d
    cross join user_spine u 

-- Get user cohort dates - the first date a user created an account
), cohorts as (
    select 
        user_id,
        min(date(account_created_timestamp)) as cohort_date
    from {{ ref('int_Accounts') }}
    group by 1

-- Determine if each user's account is currently open
-- An account is open if it has never been closed or if it was reopened after being closed
), accounts as (
    select
        user_id,
        max(case when last_closed_timestamp is null or date(last_reopened_timestamp) > date(last_closed_timestamp)
            then 1 else 0 end) as is_open
    from {{ ref('int_Accounts') }}
    group by 1

-- Get daily user activity
), user_activity as (
    select
        date(t.transaction_date) as activity_date,
        a.user_id
    from {{ ref('stg_AccountTransactions') }} t
    inner join {{ ref('int_Accounts') }} a
        on t.account_id = a.account_id

-- Calculate whether a user was active in the last 7 days for each transacion date
), activity_status as (
    select
        s.transaction_date,
        s.user_id,
        max(case when ua.activity_date between date_sub(s.transaction_date, interval 7 day) 
                and s.transaction_date then 1 else 0 end) as is_active_7d
    from date_user_spine s
    left join user_activity ua
        on s.user_id = ua.user_id
    group by s.transaction_date, s.user_id
)

-- Final output
select 
    s.transaction_date,
    s.user_id,
    c.cohort_date,
    acc.is_open,
    a.is_active_7d
from date_user_spine s
left join cohorts c on s.user_id = c.user_id
left join accounts acc on s.user_id = acc.user_id
left join activity_status a on s.transaction_date = a.transaction_date and s.user_id = a.user_id
where s.transaction_date >= c.cohort_date  -- Only include dates after user created first account