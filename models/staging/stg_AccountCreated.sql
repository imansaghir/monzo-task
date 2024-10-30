
select
    account_id_hashed as account_id,  
    user_id_hashed as user_id,     
    cast(created_ts as timestamp) as account_created_timestamp,  
    account_type
from {{ source('monzo_data', 'account_created') }}
