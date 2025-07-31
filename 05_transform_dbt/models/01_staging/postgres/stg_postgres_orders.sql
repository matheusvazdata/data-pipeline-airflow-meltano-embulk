with orders as (

    select
    
          cast(order_id as int) as OrderId
        , cast(customer_id as string) as CustomerId
        , cast(employee_id as int) as EmployeeId
        , cast(cast(order_date as timestamp) as date) as OrderDate
        , cast(cast(required_date as timestamp) as date) as RequiredDate
        , cast(cast(shipped_date as timestamp) as date) as ShippedDate
        , cast(ship_via as int) as ShipVia
        , cast(freight as double) as Freight
        , cast(ship_name as string) as ShipName
        , cast(ship_address as string) as ShipAddress
        , cast(ship_city as string) as ShipCity
        , cast(ship_region as string) as ShipRegion
        , cast(ship_postal_code as string) as ShipPostalCode
        , cast(ship_country as string) as ShipCountry

    from {{ source('00_raw', 'orders') }}

)

select
    *
from orders