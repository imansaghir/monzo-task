select 
    account_id_hashed as account_id,
    cast(closed_ts as timestamp) as account_closed_timestamp
from {{ source('monzo_data', 'account_closed') }}
