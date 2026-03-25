with source as (
    select * from {{ source('pokemon', 'pokemon__types') }}
),

parent as (
    select id as pokemon_id, _dlt_id
    from {{ source('pokemon', 'pokemon') }}
)

select
    p.pokemon_id,
    s.slot      as type_slot,
    s.type_name

from source s
inner join parent p
    on s._dlt_parent_id = p._dlt_id
