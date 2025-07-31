-- models/02_intermediate/sales/int_orders_with_customers.sql

with orders as (
    select
        OrderID
        , CustomerID
        , EmployeeID
        , OrderDate
        , RequiredDate
        , ShippedDate
        , ShipVia
        , Freight
        , ShipName
        , ShipAddress
        , ShipCity
        , ShipRegion
        , ShipPostalCode
        , ShipCountry
    from {{ ref('stg_postgres_orders') }}
),

customers as (
    select
        CustomerID
        , CompanyName
        , ContactName
        , ContactTitle
        , Address
        , City
        , Region
        , PostalCode
        , Country
        , Phone
        , Fax
    from {{ ref('stg_postgres_customers') }}
),

joined_data as (

    select
        orders.OrderID
        , orders.CustomerID
        , orders.EmployeeID
        , orders.OrderDate
        , orders.RequiredDate
        , orders.ShippedDate
        , orders.ShipVia
        , orders.Freight
        , orders.ShipName
        , orders.ShipAddress
        , orders.ShipCity
        , orders.ShipRegion
        , orders.ShipPostalCode
        , orders.ShipCountry
        , customers.CompanyName
        , customers.ContactName
        , customers.ContactTitle
        , customers.Address as CustomerAddress
        , customers.City as CustomerCity
        , customers.Region as CustomerRegion
        , customers.PostalCode as CustomerPostalCode
        , customers.Country as CustomerCountry
        , customers.Phone as CustomerPhone
        , customers.Fax as CustomerFax
    from orders
    left join customers
        on orders.CustomerID = customers.CustomerID
)

select
    *
from joined_data