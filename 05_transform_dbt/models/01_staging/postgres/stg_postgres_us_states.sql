with us_states as (

    select
    
          cast(state_id as int) as StateId
        , cast(state_name as string) as StateName
        , cast(state_abbr as string) as StateAbbr
        , cast(state_region as string) as StateRegion

    from {{ source('00_raw', 'us_states') }}

)

select
    *
from us_states