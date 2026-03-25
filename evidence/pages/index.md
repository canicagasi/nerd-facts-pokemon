---
title: Nerd Facts - Pokemon Intelligence Platform
description: Replacing Greta, one query at a time.
---
# Pokemon Nerd Facts Dashboard

_Greta is retiring, but the nerd facts live on. This dashboard serves Generation I (Kanto) Pokemon data extracted from PokeAPI with dlt, transformed with dbt & DuckDB, and served here via Evidence._

## At a Glance

<Grid cols=4>
<div>
<img src={fun_facts.filter(d => d.category === 'Highest BST')[0]?.sprite_url} alt="Strongest" width=72 height=72 />
<BigValue data={fun_facts.filter(d => d.category === 'Highest BST')} value="pokemon" title="Strongest" />
<p>BST: {fun_facts.filter(d => d.category === 'Highest BST')[0]?.stat_value ?? ''}</p>
</div>
<div>
<img src={fun_facts.filter(d => d.category === 'Fastest')[0]?.sprite_url} alt="Fastest" width=72 height=72 />
<BigValue data={fun_facts.filter(d => d.category === 'Fastest')} value="pokemon" title="Fastest" />
<p>Speed: {fun_facts.filter(d => d.category === 'Fastest')[0]?.stat_value ?? ''}</p>
</div>
<div>
<img src={fun_facts.filter(d => d.category === 'Heaviest')[0]?.sprite_url} alt="Heaviest" width=72 height=72 />
<BigValue data={fun_facts.filter(d => d.category === 'Heaviest')} value="pokemon" title="Heaviest" />
<p>Weight: {fun_facts.filter(d => d.category === 'Heaviest')[0]?.stat_value ?? ''}</p>
</div>
<div>
<img src={fun_facts.filter(d => d.category === 'Tallest')[0]?.sprite_url} alt="Tallest" width=72 height=72 />
<BigValue data={fun_facts.filter(d => d.category === 'Tallest')} value="pokemon" title="Tallest" />
<p>Height: {fun_facts.filter(d => d.category === 'Tallest')[0]?.stat_value ?? ''}</p>
</div>
</Grid>

## Record Holders

<DataTable data={fun_facts.filter(d => !['Highest BST', 'Fastest', 'Heaviest', 'Tallest'].includes(d.category))} rows=all>
    <Column id=sprite_url contentType=image height=40px align=center title=" " />
    <Column id=category title="Record" />
    <Column id=pokemon title="Pokemon" />
    <Column id=types title="Types" />
    <Column id=stat_value title="Value" />
</DataTable>


```sql fun_facts
with ranked as (
    select
        p.pokemon_display_name,
        p.type_combo,
        p.sprite_url,
        p.weight_kg,
        p.height_m,
        p.bmi,
        s.base_stat_total,
        s.speed,
        row_number() over (order by p.weight_kg desc) as heaviest_rank,
        row_number() over (order by p.weight_kg asc) as lightest_rank,
        row_number() over (order by p.height_m desc) as tallest_rank,
        row_number() over (order by p.height_m asc) as shortest_rank,
        row_number() over (order by s.base_stat_total desc) as highest_bst_rank,
        row_number() over (order by s.base_stat_total asc) as lowest_bst_rank,
        row_number() over (order by s.speed desc) as fastest_rank,
        row_number() over (order by s.speed asc) as slowest_rank,
        row_number() over (order by p.bmi desc) as highest_bmi_rank
    from pokemon.dim_pokemon p
    join pokemon.fct_pokemon_stats s on p.pokemon_id = s.pokemon_id
    where p.bmi is not null
)
select
    case
        when heaviest_rank = 1 then 'Heaviest'
        when lightest_rank = 1 then 'Lightest'
        when tallest_rank = 1 then 'Tallest'
        when shortest_rank = 1 then 'Shortest'
        when highest_bst_rank = 1 then 'Highest BST'
        when lowest_bst_rank = 1 then 'Lowest BST'
        when fastest_rank = 1 then 'Fastest'
        when slowest_rank = 1 then 'Slowest'
        when highest_bmi_rank = 1 then 'Highest BMI'
    end as category,
    pokemon_display_name as pokemon,
    type_combo as types,
    sprite_url,
    case
        when heaviest_rank = 1 or lightest_rank = 1 then cast(weight_kg as varchar) || ' kg'
        when tallest_rank = 1 or shortest_rank = 1 then cast(height_m as varchar) || ' m'
        when highest_bst_rank = 1 or lowest_bst_rank = 1 then cast(base_stat_total as varchar)
        when fastest_rank = 1 or slowest_rank = 1 then cast(speed as varchar)
        when highest_bmi_rank = 1 then cast(bmi as varchar)
    end as stat_value
from ranked
where heaviest_rank = 1 or lightest_rank = 1
    or tallest_rank = 1 or shortest_rank = 1
    or highest_bst_rank = 1 or lowest_bst_rank = 1
    or fastest_rank = 1 or slowest_rank = 1
    or highest_bmi_rank = 1
```

```sql stats_by_type
select
    p.primary_type as type,
    round(avg(s.base_stat_total), 1) as avg_bst,
    round(avg(s.hp), 1) as avg_hp,
    round(avg(s.attack), 1) as avg_attack,
    round(avg(s.defense), 1) as avg_defense,
    round(avg(s.sp_attack), 1) as avg_sp_attack,
    round(avg(s.sp_defense), 1) as avg_sp_defense,
    round(avg(s.speed), 1) as avg_speed,
    count(*) as pokemon_count
from pokemon.dim_pokemon p
join pokemon.fct_pokemon_stats s on p.pokemon_id = s.pokemon_id
group by p.primary_type
order by avg_bst desc
```

```sql archetypes
select
    s.stat_archetype,
    count(*) as pokemon_count
from pokemon.fct_pokemon_stats s
group by s.stat_archetype
order by pokemon_count desc
```

```sql top_pokemon
select
    p.pokemon_display_name as pokemon,
    p.type_combo as types,
    p.sprite_url,
    s.base_stat_total as bst,
    s.hp,
    s.attack,
    s.defense,
    s.sp_attack,
    s.sp_defense,
    s.speed,
    s.stat_archetype as archetype
from pokemon.dim_pokemon p
join pokemon.fct_pokemon_stats s on p.pokemon_id = s.pokemon_id
order by s.base_stat_total desc
limit 10
```

## Pokemon by Type (Primary)

<BarChart
    data={stats_by_type}
    x=type
    y=pokemon_count
    series=type
    title="Number of Gen I Pokemon by Primary Type"
    sort=false
    colorPalette={['#74CFF0', '#F95587', '#EE8130', '#F7D02C', '#6F35FC', '#B6A136', '#C22E28', '#6390F0', '#7AC74C', '#735797', '#D685AD', '#A33EA1', '#A8A77A', '#E2BF65', '#A6B91A', '#A98FF3']}
    legend=false
/>

## Average Base Stat Total by Type

<BarChart
    data={stats_by_type}
    x=type
    y=avg_bst
    series=type
    title="Average BST by Primary Type"
    sort=false
    colorPalette={['#74CFF0', '#F95587', '#EE8130', '#F7D02C', '#6F35FC', '#B6A136', '#C22E28', '#6390F0', '#7AC74C', '#735797', '#D685AD', '#A33EA1', '#A8A77A', '#E2BF65', '#A6B91A', '#A98FF3']}
    legend=false
/>

## Stat Archetype Distribution

_Each Pokemon is classified by their highest base stat into an archetype._

<BarChart
    data={archetypes}
    x=stat_archetype
    y=pokemon_count
    title="How Gen I Pokemon Are Built"
    sort=false
/>

## Top 10 Strongest Pokemon (by Base Stat Total)

<DataTable data={top_pokemon} rows=10>
    <Column id=sprite_url contentType=image height=40px align=center title=" " />
    <Column id=pokemon title="Pokemon" />
    <Column id=types title="Types" />
    <Column id=bst title="BST" />
    <Column id=hp />
    <Column id=attack title="Atk" />
    <Column id=defense title="Def" />
    <Column id=sp_attack title="SpA" />
    <Column id=sp_defense title="SpD" />
    <Column id=speed title="Spe" />
    <Column id=archetype />
</DataTable>

## Explore More

- [**Compare Pokemon →**](/compare) — pick two Pokemon and compare stats with a radar chart
- [**Pokedex Explorer →**](/pokedex) — searchable table with sprites, stat sliders, and type matchup data
- [Type Analysis →](/types) — offensive/defensive profiles and type matchup data
- [Generation Overview →](/generations) — species counts by generation and region
