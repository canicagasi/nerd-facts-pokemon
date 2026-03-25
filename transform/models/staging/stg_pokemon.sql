with source as (
    select * from {{ source('pokemon', 'pokemon') }}
)

select
    id                      as pokemon_id,
    name                    as pokemon_name,
    {{ title_case("replace(name, '-', ' ')") }}
                            as pokemon_display_name,
    height * 0.1            as height_m,
    weight * 0.1            as weight_kg,
    base_experience,
    "order"                 as pokedex_order,
    is_default,
    sprite_front_default    as sprite_url,
    sprite_front_shiny      as sprite_shiny_url

from source
