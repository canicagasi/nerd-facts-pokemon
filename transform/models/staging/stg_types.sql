with source as (
    select * from {{ source('pokemon', 'types') }}
)

select
    id              as type_id,
    name            as type_name,
    {{ title_case('name') }}   as type_display_name,
    pokemon_count

from source
