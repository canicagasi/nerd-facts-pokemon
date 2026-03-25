with source as (
    select * from {{ source('pokemon', 'pokemon__abilities') }}
),

parent as (
    select id as pokemon_id, _dlt_id
    from {{ source('pokemon', 'pokemon') }}
)

select
    p.pokemon_id,
    s.ability_name,
    s.is_hidden,
    s.slot  as ability_slot

from source s
inner join parent p
    on s._dlt_parent_id = p._dlt_id
