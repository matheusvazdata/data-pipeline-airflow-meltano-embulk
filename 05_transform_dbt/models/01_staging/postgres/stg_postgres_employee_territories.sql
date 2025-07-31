with employee_territories as (

    select
          cast(employee_id as int) as EmployeeId
        , cast(territory_id as string) as TerritoryId

    from {{ source('00_raw', 'employee_territories') }}

)

select
    *
from employee_territories