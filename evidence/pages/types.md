---
title: Type Analysis
---

## Type Deep Dive

_Pick a type to see its full offensive and defensive profile, plus every Pokemon of that type. Don't worry, we handled the edge cases like Dark type too❤️_

<Dropdown
    data={type_list}
    name=type_dive
    value=type_name
    label=type_display_name
    title="Select a Type"
    defaultValue="fire"
/>

{#if dive_avg_stats.length > 0 && dive_avg_stats[0].pokemon_count > 0}

### Average Stat Profile

<p>{dive_avg_stats[0].pokemon_count} Pokemon — Average BST: {dive_avg_stats[0].avg_bst}</p>

<ECharts config={
    {
        radar: {
            radius: '60%',
            indicator: [
                { name: 'HP', max: 255 },
                { name: 'Attack', max: 255 },
                { name: 'Defense', max: 255 },
                { name: 'Sp. Atk', max: 255 },
                { name: 'Sp. Def', max: 255 },
                { name: 'Speed', max: 255 }
            ]
        },
        series: [{
            type: 'radar',
            data: [{
                value: [
                    dive_avg_stats[0].avg_hp,
                    dive_avg_stats[0].avg_attack,
                    dive_avg_stats[0].avg_defense,
                    dive_avg_stats[0].avg_sp_attack,
                    dive_avg_stats[0].avg_sp_defense,
                    dive_avg_stats[0].avg_speed
                ],
                areaStyle: { opacity: 0.3 }
            }]
        }]
    }
} />

{:else}

_No Pokemon of this type exist in the Gen 1 Pokedex. The type itself still appears in the game through moves — for example, Bite is a Dark-type move that several Gen 1 Pokemon can learn._

{/if}

### Offensive Profile

_What this type hits hard, what it struggles against, and what it can't touch._

<Grid cols=3>
<div>

**Super Effective Against**

{#each dive_offense.filter(r => r.multiplier === 2) as row}
<span style="display:inline-block;padding:4px 12px;margin:3px;border-radius:20px;font-size:13px;font-weight:600;color:white;background:{({bug:'#A6B91A',dark:'#735797',dragon:'#6F35FC',electric:'#F7D02C',fairy:'#D685AD',fighting:'#C22E28',fire:'#EE8130',flying:'#A98FF3',ghost:'#735797',grass:'#7AC74C',ground:'#E2BF65',ice:'#74CFF0',normal:'#A8A77A',poison:'#A33EA1',psychic:'#F95587',rock:'#B6A136',steel:'#B7B7CE',water:'#6390F0'})[row.type] || '#888'}">{row.type}</span>
{/each}

{#if dive_offense.filter(r => r.multiplier === 2).length === 0}

_None_

{/if}

</div>
<div>

**Resisted By**

{#each dive_offense.filter(r => r.multiplier === 0.5) as row}
<span style="display:inline-block;padding:4px 12px;margin:3px;border-radius:20px;font-size:13px;font-weight:600;color:white;background:{({bug:'#A6B91A',dark:'#735797',dragon:'#6F35FC',electric:'#F7D02C',fairy:'#D685AD',fighting:'#C22E28',fire:'#EE8130',flying:'#A98FF3',ghost:'#735797',grass:'#7AC74C',ground:'#E2BF65',ice:'#74CFF0',normal:'#A8A77A',poison:'#A33EA1',psychic:'#F95587',rock:'#B6A136',steel:'#B7B7CE',water:'#6390F0'})[row.type] || '#888'}">{row.type}</span>
{/each}

{#if dive_offense.filter(r => r.multiplier === 0.5).length === 0}

_None_

{/if}

</div>
<div>

**No Effect On**

{#each dive_offense.filter(r => r.multiplier === 0) as row}
<span style="display:inline-block;padding:4px 12px;margin:3px;border-radius:20px;font-size:13px;font-weight:600;color:white;background:{({bug:'#A6B91A',dark:'#735797',dragon:'#6F35FC',electric:'#F7D02C',fairy:'#D685AD',fighting:'#C22E28',fire:'#EE8130',flying:'#A98FF3',ghost:'#735797',grass:'#7AC74C',ground:'#E2BF65',ice:'#74CFF0',normal:'#A8A77A',poison:'#A33EA1',psychic:'#F95587',rock:'#B6A136',steel:'#B7B7CE',water:'#6390F0'})[row.type] || '#888'}">{row.type}</span>
{/each}

{#if dive_offense.filter(r => r.multiplier === 0).length === 0}

_None_

{/if}

</div>
</Grid>

### Defensive Profile

_What hits this type hard, what it shrugs off, and what it's immune to._

<Grid cols=3>
<div>

**Weak To**

{#each dive_defense.filter(r => r.multiplier === 2) as row}
<span style="display:inline-block;padding:4px 12px;margin:3px;border-radius:20px;font-size:13px;font-weight:600;color:white;background:{({bug:'#A6B91A',dark:'#735797',dragon:'#6F35FC',electric:'#F7D02C',fairy:'#D685AD',fighting:'#C22E28',fire:'#EE8130',flying:'#A98FF3',ghost:'#735797',grass:'#7AC74C',ground:'#E2BF65',ice:'#74CFF0',normal:'#A8A77A',poison:'#A33EA1',psychic:'#F95587',rock:'#B6A136',steel:'#B7B7CE',water:'#6390F0'})[row.type] || '#888'}">{row.type}</span>
{/each}

{#if dive_defense.filter(r => r.multiplier === 2).length === 0}

_None_

{/if}

</div>
<div>

**Resists**

{#each dive_defense.filter(r => r.multiplier === 0.5) as row}
<span style="display:inline-block;padding:4px 12px;margin:3px;border-radius:20px;font-size:13px;font-weight:600;color:white;background:{({bug:'#A6B91A',dark:'#735797',dragon:'#6F35FC',electric:'#F7D02C',fairy:'#D685AD',fighting:'#C22E28',fire:'#EE8130',flying:'#A98FF3',ghost:'#735797',grass:'#7AC74C',ground:'#E2BF65',ice:'#74CFF0',normal:'#A8A77A',poison:'#A33EA1',psychic:'#F95587',rock:'#B6A136',steel:'#B7B7CE',water:'#6390F0'})[row.type] || '#888'}">{row.type}</span>
{/each}

{#if dive_defense.filter(r => r.multiplier === 0.5).length === 0}

_None_

{/if}

</div>
<div>

**Immune To**

{#each dive_defense.filter(r => r.multiplier === 0) as row}
<span style="display:inline-block;padding:4px 12px;margin:3px;border-radius:20px;font-size:13px;font-weight:600;color:white;background:{({bug:'#A6B91A',dark:'#735797',dragon:'#6F35FC',electric:'#F7D02C',fairy:'#D685AD',fighting:'#C22E28',fire:'#EE8130',flying:'#A98FF3',ghost:'#735797',grass:'#7AC74C',ground:'#E2BF65',ice:'#74CFF0',normal:'#A8A77A',poison:'#A33EA1',psychic:'#F95587',rock:'#B6A136',steel:'#B7B7CE',water:'#6390F0'})[row.type] || '#888'}">{row.type}</span>
{/each}

{#if dive_defense.filter(r => r.multiplier === 0).length === 0}

_None_

{/if}

</div>
</Grid>



{#if dive_pokemon.length > 0}

### Pokemon of This Type

<DataTable data={dive_pokemon} rows=10 search=true>
    <Column id=sprite_url contentType=image height=40px align=center title=" " />
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
</DataTable>

{/if}


## Type Matchup Chart

_The classic type chart. Hover over any cell to see the matchup. Read as: Attacker (row) vs Defender (column)._

<Heatmap
    data={heatmap_data}
    x=defender
    y=attacker
    value=multiplier
    valueLabels=true
    valueFmt="num1"
    xLabelRotation=-45
    xAxisPosition=top
    cellHeight=25
    colorPalette={['#0d0d1a', '#8b1a1a', '#d4d4d4', '#1a7a3a']}
    min=0
    max=2
    title="Attacker (row) vs Defender (column)"
/>

```sql type_stats
select
    t.type_display_name as type,
    t.pokemon_count,
    t.super_effective_against_count,
    t.weak_to_count,
    t.resistant_to_count,
    t.immune_to_count,
    t.net_type_advantage
from pokemon.dim_type t
where t.pokemon_count > 0
order by t.net_type_advantage desc
```

```sql type_list
select distinct type_name, type_display_name
from pokemon.dim_type
where pokemon_count > 0
order by type_display_name
```

```sql type_effectiveness
select
    e.attacking_type_name as attacker,
    e.defending_type_name as defender,
    e.multiplier,
    e.effectiveness_label
from pokemon.fct_type_effectiveness e
order by e.attacking_type_name, e.defending_type_name
```

```sql heatmap_data
select
    e.attacking_type_name as attacker,
    e.defending_type_name as defender,
    e.multiplier
from pokemon.fct_type_effectiveness e
order by e.attacking_type_name, e.defending_type_name
```

# Type Analysis

_Which types dominate the meta? Where are the gaps in your team's coverage? Dig in._

## Type Tier List

_Types ranked by net type advantage (super effective matchups minus weaknesses). Higher is better._

<ECharts config={
    {
        grid: { left: 80, right: 30, top: 10, bottom: 30 },
        xAxis: {
            type: 'value',
            name: 'Net Advantage',
            axisLabel: { fontSize: 11 }
        },
        yAxis: {
            type: 'category',
            data: type_stats.map(r => r.type),
            inverse: true,
            axisLabel: { fontSize: 11 }
        },
        series: [{
            type: 'bar',
            data: type_stats.map(r => {
                const colors = {
                    Bug: '#A6B91A', Dark: '#735797', Dragon: '#6F35FC',
                    Electric: '#F7D02C', Fairy: '#D685AD', Fighting: '#C22E28',
                    Fire: '#EE8130', Flying: '#A98FF3', Ghost: '#735797',
                    Grass: '#7AC74C', Ground: '#E2BF65', Ice: '#74CFF0',
                    Normal: '#A8A77A', Poison: '#A33EA1', Psychic: '#F95587',
                    Rock: '#B6A136', Steel: '#B7B7CE', Water: '#6390F0'
                };
                return { value: r.net_type_advantage, itemStyle: { color: colors[r.type] || '#888' } };
            }),
            barWidth: '60%',
            label: {
                show: true,
                position: 'right',
                fontSize: 11,
                formatter: function(p) { return p.value > 0 ? '+' + p.value : p.value; }
            }
        }]
    }
} />



```sql dive_offense
select
    e.defending_type_name as type,
    e.multiplier,
    e.effectiveness_label
from pokemon.fct_type_effectiveness e
where e.attacking_type_name = '${inputs.type_dive.value}'
  and e.multiplier != 1.0
order by e.multiplier desc, e.defending_type_name
```

```sql dive_defense
select
    e.attacking_type_name as type,
    e.multiplier,
    e.effectiveness_label
from pokemon.fct_type_effectiveness e
where e.defending_type_name = '${inputs.type_dive.value}'
  and e.multiplier != 1.0
order by e.multiplier asc, e.attacking_type_name
```

```sql dive_pokemon
select
    p.pokemon_id,
    p.pokemon_display_name,
    p.type_combo,
    p.sprite_url,
    p.pokedex_entry,
    s.base_stat_total,
    s.hp,
    s.attack,
    s.defense,
    s.sp_attack,
    s.sp_defense,
    s.speed,
    s.stat_archetype
from pokemon.dim_pokemon p
join pokemon.fct_pokemon_stats s on p.pokemon_id = s.pokemon_id
where p.primary_type = '${inputs.type_dive.value}'
   or p.secondary_type = '${inputs.type_dive.value}'
order by s.base_stat_total desc
```

```sql dive_avg_stats
select
    round(avg(s.hp), 1) as avg_hp,
    round(avg(s.attack), 1) as avg_attack,
    round(avg(s.defense), 1) as avg_defense,
    round(avg(s.sp_attack), 1) as avg_sp_attack,
    round(avg(s.sp_defense), 1) as avg_sp_defense,
    round(avg(s.speed), 1) as avg_speed,
    round(avg(s.base_stat_total), 1) as avg_bst,
    count(*) as pokemon_count
from pokemon.dim_pokemon p
join pokemon.fct_pokemon_stats s on p.pokemon_id = s.pokemon_id
where p.primary_type = '${inputs.type_dive.value}'
   or p.secondary_type = '${inputs.type_dive.value}'
```
