with products as (

    select
    
          cast(product_id as int) as ProductId
        , cast(product_name as string) as ProductName
        , cast(supplier_id as int) as SupplierId
        , cast(category_id as int) as CategoryId
        , cast(quantity_per_unit as string) as QuantityPerUnit
        , cast(unit_price as double) as UnitPrice
        , cast(units_in_stock as int) as UnitsInStock
        , cast(units_on_order as int) as UnitsOnOrder
        , cast(reorder_level as int) as ReorderLevel
        , cast(discontinued as boolean) as Discontinued

    from {{ source('00_raw', 'products') }}

)

select
    *
from products