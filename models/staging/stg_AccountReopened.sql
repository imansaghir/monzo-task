select
    account_id_hashed as account_id,
    cast(reopened_ts as timestamp) as account_reopened_timestamp
from {{ source('monzo_data', 'account_reopened') }}
