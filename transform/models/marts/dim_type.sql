-- dim_type
-- Grain: one row per Pokemon type
-- Contains type attributes and aggregated damage relation counts

with types as (
    select * from {{ ref('stg_types') }}
),

effectiveness as (
    select * from {{ ref('stg_type_effectiveness') }}
),

offensive_strengths as (
    select
        attacking_type as type_name,
        count(*) filter (where multiplier = 2.0) as super_effective_against_count,
        count(*) filter (where multiplier = 0.5) as not_very_effective_against_count,
        count(*) filter (where multiplier = 0.0) as no_effect_against_count
    from effectiveness
    group by attacking_type
),

defensive_profile as (
    select
        defending_type as type_name,
        count(*) filter (where multiplier = 2.0) as weak_to_count,
        count(*) filter (where multiplier = 0.5) as resistant_to_count,
        count(*) filter (where multiplier = 0.0) as immune_to_count
    from effectiveness
    group by defending_type
)

select
    t.type_id,
    t.type_name,
    t.type_display_name,
    t.pokemon_count,
    coalesce(o.super_effective_against_count, 0)      as super_effective_against_count,
    coalesce(o.not_very_effective_against_count, 0)    as not_very_effective_against_count,
    coalesce(o.no_effect_against_count, 0)             as no_effect_against_count,
    coalesce(d.weak_to_count, 0)                       as weak_to_count,
    coalesce(d.resistant_to_count, 0)                  as resistant_to_count,
    coalesce(d.immune_to_count, 0)                     as immune_to_count,
    -- net advantage: more offensive strengths vs defensive weaknesses = better
    coalesce(o.super_effective_against_count, 0)
        - coalesce(d.weak_to_count, 0)                 as net_type_advantage

from types t
left join offensive_strengths o on t.type_name = o.type_name
left join defensive_profile d on t.type_name = d.type_name
