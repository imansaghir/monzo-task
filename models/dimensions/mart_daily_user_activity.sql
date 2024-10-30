with metrics as (
    select
        transaction_date,
        cohort_date,
        date_diff(transaction_date, cohort_date, day) as days_since_signup,
        date_diff(transaction_date, cohort_date, month) as months_since_signup,
        count(distinct case when is_open = 1 then user_id  end) as total_users, --is_open =1 means we exclude closed accounts
        count(distinct case when is_open = 1  and is_active_7d = 1 then user_id --is_open =1 means we exclude closed accounts
        end) as active_users,
        -- Activity rate calculation
        safe_divide(count(distinct case when is_open = 1 and is_active_7d = 1 then user_id end),
                    count(distinct case when is_open = 1 then user_id end)
        ) as active_rate
    from {{ ref('int_daily_user_status') }}
    group by 1, 2
)

-- Final output with cohort analysis
select
    cohort_date,
    date_trunc(cohort_date, month) as cohort_month,
    days_since_signup,
    months_since_signup,
    total_users,
    active_users,
    active_rate
from metrics
order by cohort_date, days_since_signup
