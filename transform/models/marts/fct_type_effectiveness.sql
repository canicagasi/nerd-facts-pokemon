-- fct_type_effectiveness
-- Grain: one row per attacking_type × defending_type combination
-- Only non-neutral matchups (multiplier ≠ 1.0) are stored
-- Neutral matchups (1.0x) can be inferred as the absence of a row

with effectiveness as (
    select * from {{ ref('stg_type_effectiveness') }}
),

attacking_types as (
    select type_id, type_name from {{ ref('stg_types') }}
),

defending_types as (
    select type_id, type_name from {{ ref('stg_types') }}
)

select
    atk.type_id     as attacking_type_id,
    e.attacking_type as attacking_type_name,
    dt.type_id      as defending_type_id,
    e.defending_type as defending_type_name,
    e.multiplier,
    case
        when e.multiplier = 2.0 then 'super effective'
        when e.multiplier = 0.5 then 'not very effective'
        when e.multiplier = 0.0 then 'no effect'
    end as effectiveness_label

from effectiveness e
inner join attacking_types atk
    on e.attacking_type = atk.type_name
inner join defending_types dt
    on e.defending_type = dt.type_name
