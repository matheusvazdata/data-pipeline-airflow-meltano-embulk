-- models/02_intermediate/products/int_product_catalog.sql

with products as (
    select
        ProductID
        , ProductName
        , SupplierID
        , CategoryID
        , QuantityPerUnit
        , UnitPrice
        , UnitsInStock
        , UnitsOnOrder
        , ReorderLevel
        , Discontinued
    from {{ ref('stg_postgres_products') }}
),

suppliers as (
    select
        SupplierID
        , CompanyName as SupplierCompanyName
        , ContactName as SupplierContactName
        , ContactTitle as SupplierContactTitle
        , Address as SupplierAddress
        , City as SupplierCity
        , Region as SupplierRegion
        , PostalCode as SupplierPostalCode
        , Country as SupplierCountry
        , Phone as SupplierPhone
        , Fax as SupplierFax
        , HomePage as SupplierHomePage
    from {{ ref('stg_postgres_suppliers') }}
),

categories as (
    select
        CategoryID
        , CategoryName
        , Description as CategoryDescription
    from {{ ref('stg_postgres_categories') }}
),

joined_data as (

    select
        products.ProductID
        , products.ProductName
        , products.SupplierID
        , products.CategoryID
        , products.QuantityPerUnit
        , products.UnitPrice
        , products.UnitsInStock
        , products.UnitsOnOrder
        , products.ReorderLevel
        , products.Discontinued
        , suppliers.SupplierCompanyName
        , suppliers.SupplierContactName
        , suppliers.SupplierContactTitle
        , suppliers.SupplierAddress
        , suppliers.SupplierCity
        , suppliers.SupplierRegion
        , suppliers.SupplierPostalCode
        , suppliers.SupplierCountry
        , suppliers.SupplierPhone
        , suppliers.SupplierFax
        , suppliers.SupplierHomePage
        , categories.CategoryName
        , categories.CategoryDescription
    from products
    left join suppliers
        on products.SupplierID = suppliers.SupplierID
    left join categories
        on products.CategoryID = categories.CategoryID
        
)

select
    *
from joined_data