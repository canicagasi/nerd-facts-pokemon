-- bridge_pokemon_types
-- Grain: one row per Pokemon–Type assignment
-- Resolves the many-to-many between dim_pokemon and dim_type

with pokemon_types as (
    select * from {{ ref('stg_pokemon_types') }}
),

types as (
    select type_id, type_name
    from {{ ref('stg_types') }}
)

select
    pt.pokemon_id,
    t.type_id,
    pt.type_name,
    pt.type_slot,
    case pt.type_slot
        when 1 then true
        else false
    end as is_primary_type

from pokemon_types pt
inner join types t
    on pt.type_name = t.type_name
