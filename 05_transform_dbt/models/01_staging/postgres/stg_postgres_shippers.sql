with shippers as (

    select
    
          cast(shipper_id as int) as ShipperId
        , cast(company_name as string) as CompanyName
        , cast(phone as string) as Phone

    from {{ source('00_raw', 'shippers') }}

)

select
    *
from shippers