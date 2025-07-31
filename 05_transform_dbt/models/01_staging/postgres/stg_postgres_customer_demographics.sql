with customer_demographics as (

    select
          cast(customer_type_id as string)     as CustomerTypeId
        , cast(customer_desc as string)        as CustomerDesc

    from {{ source('00_raw', 'customer_demographics') }}

)

select
    *
from customer_demographics