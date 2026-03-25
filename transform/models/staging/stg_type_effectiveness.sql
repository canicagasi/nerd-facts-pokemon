-- Unpacks all six damage relation child tables into a single
-- long-format model with (attacking_type, defending_type, multiplier).
-- Perspective: "attacking_type attacks defending_type → multiplier"

with parent as (
    select id as type_id, name as type_name, _dlt_id
    from {{ source('pokemon', 'types') }}
),

double_damage_to as (
    select
        _dlt_parent_id as type_dlt_id,
        value          as target_type_name,
        2.0            as multiplier
    from {{ source('pokemon', 'types__double_damage_to') }}
),

half_damage_to as (
    select
        _dlt_parent_id as type_dlt_id,
        value          as target_type_name,
        0.5            as multiplier
    from {{ source('pokemon', 'types__half_damage_to') }}
),

no_damage_to as (
    select
        _dlt_parent_id as type_dlt_id,
        value          as target_type_name,
        0.0            as multiplier
    from {{ source('pokemon', 'types__no_damage_to') }}
),

combined as (
    select * from double_damage_to
    union all
    select * from half_damage_to
    union all
    select * from no_damage_to
)

select
    p.type_name     as attacking_type,
    c.target_type_name as defending_type,
    c.multiplier

from combined c
inner join parent p
    on c.type_dlt_id = p._dlt_id
