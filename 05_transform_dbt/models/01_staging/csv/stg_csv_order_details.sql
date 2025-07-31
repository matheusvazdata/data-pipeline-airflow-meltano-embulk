with order_details as (

    select
          cast(order_id as int) as OrderId
        , cast(product_id as int) as ProductId
        , cast(unit_price as double) as UnitPrice
        , cast(quantity as int) as Quantity
        , cast(discount as double) as Discount

    from {{ source('00_raw', 'order_details') }}

)

select
    *
from order_details