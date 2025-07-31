-- models/02_intermediate/sales/int_shipments_info.sql

with orders as (
    select
        OrderID
        , ShippedDate
        , ShipVia
        , ShipName
        , ShipAddress
        , ShipCity
        , ShipRegion
        , ShipPostalCode
        , ShipCountry
    from {{ ref('stg_postgres_orders') }}
),

shippers as (
    select
        ShipperID
        , CompanyName as ShipperCompanyName
        , Phone as ShipperPhone
    from {{ ref('stg_postgres_shippers') }}
),

joined_data as (

    select
        orders.OrderID
        , orders.ShippedDate
        , orders.ShipVia
        , orders.ShipName
        , orders.ShipAddress
        , orders.ShipCity
        , orders.ShipRegion
        , orders.ShipPostalCode
        , orders.ShipCountry
        , shippers.ShipperCompanyName
        , shippers.ShipperPhone
    from orders
    left join shippers
        on orders.ShipVia = shippers.ShipperID
        
)

select
    *
from joined_data