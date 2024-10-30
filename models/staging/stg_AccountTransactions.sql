select
    account_id_hashed as account_id,
    cast(date as date) as transaction_date,
    transactions_num as transaction_count
from {{ source('monzo_data', 'account_transactions') }}
