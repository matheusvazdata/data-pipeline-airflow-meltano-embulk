with categories as (

    select
          cast(category_id as int) as CategoryId
        , cast(category_name as string) as CategoryName
        , cast(description as string) as Description

    from {{ source('00_raw', 'categories') }}

)

select
    *
from categories