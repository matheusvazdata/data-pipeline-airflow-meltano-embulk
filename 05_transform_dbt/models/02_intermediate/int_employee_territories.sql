-- models/02_intermediate/hr/int_employee_territories.sql

with employee_territories as (
    select
        EmployeeID
        , TerritoryID
    from {{ ref('stg_postgres_employee_territories') }}
),

employees as (
    select
        EmployeeID
        , LastName
        , FirstName
        , Title
        , TitleOfCourtesy
        , BirthDate
        , HireDate
        , Address
        , City
        , Region
        , PostalCode
        , Country
        , HomePhone
        , Extension
        , ReportsTo
        , PhotoPath
    from {{ ref('stg_postgres_employees') }}
),

territories as (
    select
        TerritoryID
        , TerritoryDescription
        , RegionID
    from {{ ref('stg_postgres_territories') }}
),

region as (
    select
        RegionID
        , RegionDescription
    from {{ ref('stg_postgres_region') }}
),

joined_data as (

    select
        employees.EmployeeID
        , employees.LastName
        , employees.FirstName
        , employees.Title
        , employees.HireDate
        , territories.TerritoryID
        , territories.TerritoryDescription
        , region.RegionID
        , region.RegionDescription
    from employee_territories
    left join employees
        on employee_territories.EmployeeID = employees.EmployeeID
    left join territories
        on employee_territories.TerritoryID = territories.TerritoryID
    left join region
        on territories.RegionID = region.RegionID
        
)

select
    *
from joined_data