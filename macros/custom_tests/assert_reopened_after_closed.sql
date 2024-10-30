{#
    Test to ensure account reopening timestamp is after account closure timestamp.
    
    Arguments:
        model: The model being tested
        column_name: The timestamp column being validated (reopened_ts)
    
    Returns:
        List of account_id values where reopened_ts <= closed_ts

    Severity:
        Default: error (can be overridden in test configuration)
#}

{% test assert_reopened_after_closed(model, column_name) %}

with reopened_accounts as (
    select account_id, account_reopened_timestamp
    from {{ ref('stg_AccountReopened') }}
),

closed_accounts as (
    select account_id, account_closed_timestamp
    from {{ ref('stg_AccountClosed') }}
)

select 
    r.account_id
from reopened_accounts r
join closed_accounts c 
    on r.account_id = c.account_id
where r.account_reopened_timestamp <= c.account_closed_timestamp

{% endtest %}