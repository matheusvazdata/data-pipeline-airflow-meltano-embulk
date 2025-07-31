with territories as (

    select
    
          cast(territory_id as string) as TerritoryId
        , cast(territory_description as string) as TerritoryDescription
        , cast(region_id as int) as RegionId

    from {{ source('00_raw', 'territories') }}

)

select
    *
from territories