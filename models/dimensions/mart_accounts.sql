with accounts as (
    select * from {{ ref('int_Accounts') }}

), days_since_last_transaction as (
    select     
        account_id,
        date_diff(current_date, last_transaction_date,day) as days_since_last_transaction
    from accounts )

select
    -- Identifiers
    a.account_id,
    a.user_id,
    -- Account Details
    a.account_type,
    case
        when first_transaction_date is null then 'Not Activated'
        when last_closed_timestamp > last_reopened_timestamp or (last_reopened_timestamp is null and last_closed_timestamp is not null) then 'Closed'
        when days_since_last_transaction <= 30 then 'Very Active'
        when days_since_last_transaction <= 90 then 'Active'
        when days_since_last_transaction <= 180 then 'Inactive'
        else 'Dormant'
    end as account_status,
    -- Account Dates
    a.account_created_timestamp,
    a.first_transaction_date,
    a.last_transaction_date,
    a.last_closed_timestamp,
    a.last_reopened_timestamp,
      -- Metrics
    l.days_since_last_transaction,
    a.account_age_days,
    a.total_closures,
    a.total_reopens,
    a.days_since_last_closure,
    a.days_since_last_reopen,
    case 
        when account_age_days < 30 then 'Young'
        when account_age_days < 90  then 'Developing'
        when account_age_days < 365 then 'Mature'
        else 'Old'
    end as account_age_category,
    --Flags
    case when first_transaction_date = date(account_created_timestamp) then true else false end as activated_on_creation,
    case when (date_diff(first_transaction_date, date(account_created_timestamp), DAY) <= 7) then true else false end as activated_within_week
from accounts a
left join days_since_last_transaction l on a.account_id = l.account_id