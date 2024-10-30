{#
    Test to ensure account closure timestamp is after account creation timestamp.
    
    Arguments:
        model: The model being tested
        column_name: The timestamp column being validated (closed_ts)
    
    Returns:
        List of account_id values where closed_ts <= created_ts

    Severity:
        Default: error (can be overridden in test configuration)

#}

{% test assert_closed_after_created(model, column_name) %}

with closed_accounts as (
    select account_id, account_closed_timestamp 
    from {{ ref('stg_AccountClosed') }}
),

created_accounts as (
    select account_id, account_created_timestamp
    from {{ ref('stg_AccountCreated') }}
)

select 
    c.account_id
from closed_accounts c
join created_accounts a 
    on c.account_id = a.account_id
where c.account_closed_timestamp <= a.account_created_timestamp

{% endtest %}