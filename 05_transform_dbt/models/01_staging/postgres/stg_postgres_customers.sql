with customers as (

    select
          cast(customer_id as string) as CustomerId
        , cast(company_name as string) as CompanyName
        , cast(contact_name as string) as ContactName
        , cast(contact_title as string) as ContactTitle
        , cast(address as string) as Address
        , cast(city as string) as City
        , cast(region as string) as Region
        , cast(postal_code as string) as PostalCode
        , cast(country as string) as Country
        , cast(phone as string) as Phone
        , cast(fax as string) as Fax

    from {{ source('00_raw', 'customers') }}

)

select
    *
from customers