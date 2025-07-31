with employees as (

    select
          cast(employee_id as int) as EmployeeId
        , cast(first_name as string) as FirstName
        , cast(last_name as string) as LastName
        , cast(title as string) as Title
        , cast(cast(birth_date as timestamp) as date) as BirthDate

    from {{ source('00_raw', 'employees') }}

)

select
    *
from employees