-- dim_generation
-- Grain: one row per game generation

with generations as (
    select * from {{ ref('stg_generations') }}
),

species_counts as (
    select
        generation_id,
        count(*) as species_count
    from {{ ref('stg_generation_species') }}
    group by generation_id
)

select
    g.generation_id,
    g.generation_name,
    g.generation_numeral,
    g.region_name,
    {{ title_case('g.region_name') }} as region_display_name,
    coalesce(sc.species_count, 0) as species_count

from generations g
left join species_counts sc
    on g.generation_id = sc.generation_id
