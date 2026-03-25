-- dim_pokemon
-- Grain: one row per Pokemon
-- Includes denormalized primary type and generation for ease of use

with pokemon as (
    select * from {{ ref('stg_pokemon') }}
),

primary_type as (
    select
        pokemon_id,
        type_name as primary_type
    from {{ ref('stg_pokemon_types') }}
    where type_slot = 1
),

secondary_type as (
    select
        pokemon_id,
        type_name as secondary_type
    from {{ ref('stg_pokemon_types') }}
    where type_slot = 2
),

generation_species as (
    select * from {{ ref('stg_generation_species') }}
),

generations as (
    select * from {{ ref('stg_generations') }}
),

pokemon_generation as (
    select
        p_lookup.pokemon_id,
        g.generation_id,
        g.generation_numeral,
        g.region_name
    from generation_species gs
    inner join generations g
        on gs.generation_id = g.generation_id
    inner join pokemon p_lookup
        on gs.pokemon_name = p_lookup.pokemon_name
),

species as (
    select * from {{ ref('stg_pokemon_species') }}
)

select
    p.pokemon_id,
    p.pokemon_name,
    p.pokemon_display_name,
    p.height_m,
    p.weight_kg,
    p.base_experience,
    p.pokedex_order,
    p.sprite_url,
    p.sprite_shiny_url,
    pt.primary_type,
    st.secondary_type,
    case
        when st.secondary_type is not null
        then pt.primary_type || ' / ' || st.secondary_type
        else pt.primary_type
    end as type_combo,
    pg.generation_id,
    pg.generation_numeral,
    pg.region_name,
    -- derived: BMI-like stat (fun fact material)
    round(p.weight_kg / nullif(p.height_m * p.height_m, 0), 2) as bmi,
    sp.pokedex_entry

from pokemon p
left join primary_type pt
    on p.pokemon_id = pt.pokemon_id
left join secondary_type st
    on p.pokemon_id = st.pokemon_id
left join pokemon_generation pg
    on p.pokemon_id = pg.pokemon_id
left join species sp
    on p.pokemon_id = sp.pokemon_id
