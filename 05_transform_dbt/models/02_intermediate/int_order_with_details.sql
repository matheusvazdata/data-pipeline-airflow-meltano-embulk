-- models/02_intermediate/sales/int_order_with_details.sql

with order_details as (
    select
        OrderID
        , ProductID
        , UnitPrice
        , Quantity
        , Discount
    from {{ ref('stg_csv_order_details') }}
),

products as (
    select
        ProductID
        , ProductName
        , SupplierID
        , CategoryID
        , QuantityPerUnit
        , UnitPrice as ProductUnitPrice
        , UnitsInStock
        , UnitsOnOrder
        , ReorderLevel
        , Discontinued
    from {{ ref('stg_postgres_products') }}
),

categories as (
    select
        CategoryID
        , CategoryName
        , Description
    from {{ ref('stg_postgres_categories') }}
),

joined_data as (

    select
        order_details.OrderID
        , order_details.ProductID
        , order_details.UnitPrice
        , order_details.Quantity
        , order_details.Discount
        , products.ProductName
        , products.SupplierID
        , products.CategoryID
        , products.QuantityPerUnit
        , products.ProductUnitPrice
        , products.UnitsInStock
        , products.UnitsOnOrder
        , products.ReorderLevel
        , products.Discontinued
        , categories.CategoryName
        , categories.Description as CategoryDescription
    from order_details
    left join products
        on order_details.ProductID = products.ProductID
    left join categories
        on products.CategoryID = categories.CategoryID

)

select
    *
from joined_data