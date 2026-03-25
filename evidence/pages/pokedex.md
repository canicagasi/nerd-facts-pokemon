---
title: Pokedex Explorer
---

_Select a Pokemon to view its full profile._

<Dropdown
    data={filtered_pokemon}
    name=card_pokemon
    value=pokemon_display_name
    title="Pick a Pokemon"
    defaultValue={filtered_pokemon[0]?.pokemon_display_name}
/>

```sql selected_pokemon
SELECT *
FROM ${filtered_pokemon}
WHERE pokemon_display_name = '${inputs.card_pokemon.value}'
```

{#if selected_pokemon.length > 0}

<div class="card-header">
<img src={selected_pokemon[0].sprite_url} alt={selected_pokemon[0].pokemon_display_name} width=96 height=96 />
<p class="pokedex-text">{selected_pokemon[0].pokedex_entry}</p>
</div>

| Stat | Value |
|------|-------|
| **Type** | {selected_pokemon[0].type_combo} |
| **BST** | {selected_pokemon[0].base_stat_total} |
| **HP / Atk / Def** | {selected_pokemon[0].hp} / {selected_pokemon[0].attack} / {selected_pokemon[0].defense} |
| **SpA / SpD / Spe** | {selected_pokemon[0].sp_attack} / {selected_pokemon[0].sp_defense} / {selected_pokemon[0].speed} |
| **Archetype** | {selected_pokemon[0].stat_archetype} |
| **Strong against** | {selected_pokemon[0].strong_against} |
| **Weak to** | {selected_pokemon[0].weak_against} |

{/if}

```sql pokemon_matchups
WITH type_summary AS (
    -- Calculate the strings for all types once here
    SELECT 
        attacking_type_name AS type_name,
        STRING_AGG(DISTINCT defending_type_name, ', ' ORDER BY defending_type_name) 
            FILTER (WHERE multiplier = 2.0) AS strong_against,
        -- We can do both in one pass by swapping the logic
        NULL AS weak_against 
    FROM pokemon.fct_type_effectiveness
    GROUP BY 1
),
weakness_summary AS (
    SELECT 
        defending_type_name AS type_name,
        STRING_AGG(DISTINCT attacking_type_name, ', ' ORDER BY attacking_type_name) 
            FILTER (WHERE multiplier = 2.0) AS weak_against
    FROM pokemon.fct_type_effectiveness
    GROUP BY 1
)
SELECT
    p.pokemon_id,
    p.pokemon_display_name,
    p.primary_type,
    p.secondary_type,
    p.type_combo,
    p.sprite_url,
    p.height_m,
    p.weight_kg,
    s.base_stat_total,
    s.hp,
    s.attack,
    s.defense,
    s.sp_attack,
    s.sp_defense,
    s.speed,
    s.stat_archetype,
    p.pokedex_entry,
    ts.strong_against,
    ws.weak_against
FROM pokemon.dim_pokemon p
JOIN pokemon.fct_pokemon_stats s ON p.pokemon_id = s.pokemon_id
LEFT JOIN type_summary ts ON p.primary_type = ts.type_name
LEFT JOIN weakness_summary ws ON p.primary_type = ws.type_name
ORDER BY 1
```

# Gen I Pokedex Explorer

_All 151 original Pokemon with sprites, stats, and type matchup data. Use the sliders to filter by stat thresholds._

## Filter by Stats

<Slider
    title="Minimum Base Stat Total"
    name=min_bst
    min=150
    max=700
    defaultValue=150
    step=10
    size=large
/>

<Slider
    title="Minimum Speed"
    name=min_speed
    min=0
    max=160
    defaultValue=0
    step=5
    size=medium
/>

<Slider
    title="Minimum Attack (Physical + Special)"
    name=min_attack
    min=0
    max=200
    defaultValue=0
    step=5
    size=medium
/>

```sql type_list
select distinct type_name
from (
    select primary_type as type_name from pokemon.dim_pokemon
    union
    select secondary_type as type_name from pokemon.dim_pokemon where secondary_type is not null
)
order by type_name
```

<Dropdown
    data={type_list}
    name=type_filter
    value=type_name
    title="Type"
    defaultValue="All"
>
    <DropdownOption value="All" valueLabel="All Types" />
</Dropdown>

```sql filtered_pokemon
SELECT *
FROM ${pokemon_matchups}
WHERE base_stat_total >= ${inputs.min_bst}
  AND speed >= ${inputs.min_speed}
  AND (attack + sp_attack) >= ${inputs.min_attack}
  AND ('${inputs.type_filter.value}' = 'All' OR primary_type = '${inputs.type_filter.value}' OR secondary_type = '${inputs.type_filter.value}')
ORDER BY 1
```

<BigValue data={filtered_pokemon} value=pokemon_id title="Pokemon Matching" agg=count />

## Results

<DataTable data={filtered_pokemon} rows=15 search=true>
    <Column id=sprite_url contentType=image height=40px align=center title=" " />
    <Column id=pokemon_id title="#" />
    <Column id=pokemon_display_name title="Pokemon" />
    <Column id=type_combo title="Types" />
    <Column id=base_stat_total title="BST" />
    <Column id=stat_archetype title="Archetype" />
    <Column id=hp title="HP" />
    <Column id=attack title="Atk" />
    <Column id=defense title="Def" />
    <Column id=sp_attack title="SpA" />
    <Column id=sp_defense title="SpD" />
    <Column id=speed title="Spe" />
    <Column id=strong_against title="Strong Against" />
    <Column id=weak_against title="Weak To" />
</DataTable>



## Base Stat Total Distribution

<Histogram
    data={filtered_pokemon}
    x=base_stat_total
    title="Distribution of BST (Filtered)"
    xAxisTitle="Base Stat Total"
/>

## Height vs Weight

<ScatterPlot
    data={filtered_pokemon}
    x=height_m
    y=weight_kg
    pointLabel=pokemon_display_name
    title="Size Comparison — Filtered Pokemon"
    xAxisTitle="Height (m)"
    yAxisTitle="Weight (kg)"
/>

<style>
    .card-header {
        display: flex;
        align-items: center;
        gap: 16px;
    }
    .pokedex-text {
        font-style: italic;
        margin: 0;
        opacity: 0.85;
    }
</style>

