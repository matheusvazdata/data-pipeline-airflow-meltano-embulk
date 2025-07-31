with customer_customer_demo as (

    select
          cast(customer_id as string) as CustomerId
        , cast(customer_type_id as string) as CustomerTypeId

    from {{ source('00_raw', 'customer_customer_demo') }}

)

select
    *
from customer_customer_demo