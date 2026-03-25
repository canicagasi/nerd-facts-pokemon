-- stg_pokemon_species
-- Grain: one row per Pokemon species with Pokedex flavor text

select
    pokemon_id,
    pokemon_name,
    flavor_text as pokedex_entry,
    version as game_version,
    language
from {{ source('pokemon', 'pokemon_species') }}
