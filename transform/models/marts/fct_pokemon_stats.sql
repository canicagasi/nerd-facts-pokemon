-- fct_pokemon_stats
-- Grain: one row per Pokemon
-- Pivots the six base stats into columns plus derived totals and rankings

with stats as (
    select * from {{ ref('stg_pokemon_stats') }}
),

pivoted as (
    select
        pokemon_id,
        max(case when stat_name = 'hp'              then base_stat end) as hp,
        max(case when stat_name = 'attack'           then base_stat end) as attack,
        max(case when stat_name = 'defense'          then base_stat end) as defense,
        max(case when stat_name = 'special-attack'   then base_stat end) as sp_attack,
        max(case when stat_name = 'special-defense'  then base_stat end) as sp_defense,
        max(case when stat_name = 'speed'            then base_stat end) as speed

    from stats
    group by pokemon_id
)

select
    pokemon_id,
    hp,
    attack,
    defense,
    sp_attack,
    sp_defense,
    speed,
    (hp + attack + defense + sp_attack + sp_defense + speed) as base_stat_total,

    -- classify stat archetype based on highest stat
    case
        when greatest(hp, attack, defense, sp_attack, sp_defense, speed) = attack     then 'physical attacker'
        when greatest(hp, attack, defense, sp_attack, sp_defense, speed) = sp_attack   then 'special attacker'
        when greatest(hp, attack, defense, sp_attack, sp_defense, speed) = defense     then 'physical tank'
        when greatest(hp, attack, defense, sp_attack, sp_defense, speed) = sp_defense  then 'special tank'
        when greatest(hp, attack, defense, sp_attack, sp_defense, speed) = speed       then 'speedster'
        when greatest(hp, attack, defense, sp_attack, sp_defense, speed) = hp          then 'hp wall'
        else 'balanced'
    end as stat_archetype,

    -- offensive vs defensive ratio
    round((attack + sp_attack)::double / nullif(defense + sp_defense, 0), 2) as offensive_ratio

from pivoted
