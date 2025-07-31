with region as (

    select
          cast(region_id as int) as RegionId
        , cast(region_description as string) as RegionDescription

    from {{ source('00_raw', 'region') }}

)

select
    *
from region