with source as (
    select * from {{ source('pokemon', 'generations__pokemon_species') }}
),

parent as (
    select id as generation_id, _dlt_id
    from {{ source('pokemon', 'generations') }}
)

select
    p.generation_id,
    s.name  as pokemon_name

from source s
inner join parent p
    on s._dlt_parent_id = p._dlt_id
