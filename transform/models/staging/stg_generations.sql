with source as (
    select * from {{ source('pokemon', 'generations') }}
)

select
    id          as generation_id,
    name        as generation_name,
    replace(name, 'generation-', '')
                as generation_numeral,
    region_name

from source
