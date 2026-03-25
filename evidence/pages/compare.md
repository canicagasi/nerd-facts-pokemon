---
title: Compare Pokemon
---

_Pick two Pokemon and compare their base stats head-to-head._

<Grid cols=2 gapSize=lg>
<Dropdown
  data={all_pokemon}
  name=pokemon_a
  value="pokemon_display_name"
  title="Pokemon 1"
  defaultValue="Pikachu"
/>
<Dropdown
  data={all_pokemon}
  name=pokemon_b
  value="pokemon_display_name"
  title="Pokemon 2"
  defaultValue="Charizard"
/>
</Grid>

{#if pokemon_1.length > 0 && pokemon_2.length > 0}

<Grid cols=2 gapSize=lg>

<div>

<img class=sprite-p1 src={pokemon_1[0].sprite_url} alt={pokemon_1[0].pokemon_display_name} width=96 height=96 />

<BigValue 
  data={pokemon_1} 
  value=pokemon_display_name 
  title="Pokemon 1" 
/>

<BigValue 
  data={pokemon_1} 
  value=base_stat_total 
  title="BST" 
/>

<BigValue 
  data={pokemon_1} 
  value=type_combo 
  title="Type" 
/>

</div>
<div>

<img class=sprite-p2 src={pokemon_2[0].sprite_url} alt={pokemon_2[0].pokemon_display_name} width=96 height=96 />

<BigValue 
  data={pokemon_2} 
  value=pokemon_display_name 
  title="Pokemon 2" 
/>

<BigValue 
  data={pokemon_2} 
  value=base_stat_total 
  title="BST" 
/>

<BigValue 
  data={pokemon_2} 
  value=type_combo 
  title="Type" 
/>
</div>
</Grid>

## Type Matchup

{#if pokemon_1[0].pokemon_display_name === pokemon_2[0].pokemon_display_name}

It's a mirror match! Neither side has a type advantage, so this one comes down to who has the better moveset (or who gets lucky with crits).

{:else if pokemon_1[0].type_combo === pokemon_2[0].type_combo}

Both Pokemon share the **{pokemon_1[0].type_combo}** typing, so neither has a clear type advantage in this matchup. The battle comes down to stats and movesets.

{:else}

**{pokemon_1[0].pokemon_display_name}** is a **{pokemon_1[0].type_combo}** type, while **{pokemon_2[0].pokemon_display_name}** is a **{pokemon_2[0].type_combo}** type.

{#each p1_attacks_p2 as row}
{#if row.multiplier === 2}

**{pokemon_1[0].pokemon_display_name}** has the edge here — {row.attacking_type} moves deal **super effective** damage against {pokemon_2[0].pokemon_display_name}'s {row.defending_type} type.

{:else if row.multiplier === 0.5}

**{pokemon_2[0].pokemon_display_name}** can shrug off {pokemon_1[0].pokemon_display_name}'s {row.attacking_type} attacks — they're **not very effective** against {row.defending_type}.

{:else if row.multiplier === 0}

**{pokemon_1[0].pokemon_display_name}**'s {row.attacking_type} moves have **no effect** on {pokemon_2[0].pokemon_display_name}'s {row.defending_type} type — a complete wall.

{/if}
{/each}

{#each p1_attacks_p2_secondary as row}
{#if row.multiplier === 2}

Additionally, {pokemon_1[0].primary_type} is **super effective** against {pokemon_2[0].pokemon_display_name}'s secondary {row.defending_type} type, amplifying the damage further.

{:else if row.multiplier === 0.5}

However, {pokemon_2[0].pokemon_display_name}'s {row.defending_type} typing provides extra resistance against {pokemon_1[0].primary_type} moves.

{:else if row.multiplier === 0}

{pokemon_2[0].pokemon_display_name}'s {row.defending_type} typing grants full immunity to {pokemon_1[0].primary_type} attacks.

{/if}
{/each}

{#each p2_attacks_p1 as row}
{#if row.multiplier === 2}

On the flip side, **{pokemon_2[0].pokemon_display_name}**'s {row.attacking_type} moves hit {pokemon_1[0].pokemon_display_name}'s {row.defending_type} type for **super effective** damage.

{:else if row.multiplier === 0.5}

Meanwhile, {pokemon_1[0].pokemon_display_name} resists {pokemon_2[0].pokemon_display_name}'s {row.attacking_type} moves — they're **not very effective** against {row.defending_type}.

{:else if row.multiplier === 0}

{pokemon_1[0].pokemon_display_name}'s {row.defending_type} type is completely **immune** to {pokemon_2[0].pokemon_display_name}'s {row.attacking_type} attacks.

{/if}
{/each}

{#each p2_attacks_p1_secondary as row}
{#if row.multiplier === 2}

{pokemon_2[0].pokemon_display_name}'s {row.attacking_type} is also **super effective** against {pokemon_1[0].pokemon_display_name}'s secondary {row.defending_type} typing.

{:else if row.multiplier === 0.5}

{pokemon_1[0].pokemon_display_name}'s {row.defending_type} typing gives it extra resistance against {pokemon_2[0].pokemon_display_name}'s {row.attacking_type} moves.

{:else if row.multiplier === 0}

{pokemon_1[0].pokemon_display_name}'s {row.defending_type} typing grants full immunity to {pokemon_2[0].pokemon_display_name}'s {row.attacking_type} attacks.

{/if}
{/each}

{#if p1_attacks_p2.length === 0 && p1_attacks_p2_secondary.length === 0 && p2_attacks_p1.length === 0 && p2_attacks_p1_secondary.length === 0}

Neither type has a special advantage over the other — all type interactions are neutral. This matchup is decided purely by stats and movesets.

{/if}

{/if}

## Stat Radar

<ECharts config={
    {
        legend: {
            data: [pokemon_1[0].pokemon_display_name, pokemon_2[0].pokemon_display_name],
            orient: 'vertical',
            right: 0,
            top: 0
        },
        radar: {
            radius: '60%',
            center: ['40%', '55%'],
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
            data: [
                {
                    value: [
                        pokemon_1[0].hp,
                        pokemon_1[0].attack,
                        pokemon_1[0].defense,
                        pokemon_1[0].sp_attack,
                        pokemon_1[0].sp_defense,
                        pokemon_1[0].speed
                    ],
                    name: pokemon_1[0].pokemon_display_name,
                    areaStyle: { opacity: 0.2 }
                },
                {
                    value: [
                        pokemon_2[0].hp,
                        pokemon_2[0].attack,
                        pokemon_2[0].defense,
                        pokemon_2[0].sp_attack,
                        pokemon_2[0].sp_defense,
                        pokemon_2[0].speed
                    ],
                    name: pokemon_2[0].pokemon_display_name,
                    areaStyle: { opacity: 0.2 }
                }
            ]
        }]
    }
} />

## Stat Breakdown

| Stat | {pokemon_1[0].pokemon_display_name} | {pokemon_2[0].pokemon_display_name} | Diff |
|------|-----------|-----------|------|
| HP | {pokemon_1[0].hp} | {pokemon_2[0].hp} | {pokemon_1[0].hp - pokemon_2[0].hp} |
| Attack | {pokemon_1[0].attack} | {pokemon_2[0].attack} | {pokemon_1[0].attack - pokemon_2[0].attack} |
| Defense | {pokemon_1[0].defense} | {pokemon_2[0].defense} | {pokemon_1[0].defense - pokemon_2[0].defense} |
| Sp. Attack | {pokemon_1[0].sp_attack} | {pokemon_2[0].sp_attack} | {pokemon_1[0].sp_attack - pokemon_2[0].sp_attack} |
| Sp. Defense | {pokemon_1[0].sp_defense} | {pokemon_2[0].sp_defense} | {pokemon_1[0].sp_defense - pokemon_2[0].sp_defense} |
| Speed | {pokemon_1[0].speed} | {pokemon_2[0].speed} | {pokemon_1[0].speed - pokemon_2[0].speed} |
| BST | {pokemon_1[0].base_stat_total} | {pokemon_2[0].base_stat_total} | {pokemon_1[0].base_stat_total - pokemon_2[0].base_stat_total} |
| Archetype | {pokemon_1[0].stat_archetype} | {pokemon_2[0].stat_archetype} | |

{/if}



```sql all_pokemon
select pokemon_display_name, pokemon_id
from pokemon.dim_pokemon
order by pokemon_id
```

```sql pokemon_1
select
    p.pokemon_display_name,
    p.type_combo,
    p.primary_type,
    p.secondary_type,
    p.sprite_url,
    s.hp,
    s.attack,
    s.defense,
    s.sp_attack,
    s.sp_defense,
    s.speed,
    s.base_stat_total,
    s.stat_archetype
from pokemon.dim_pokemon p
join pokemon.fct_pokemon_stats s on p.pokemon_id = s.pokemon_id
where p.pokemon_display_name = '${inputs.pokemon_a.value}'
```

```sql pokemon_2
select
    p.pokemon_display_name,
    p.type_combo,
    p.primary_type,
    p.secondary_type,
    p.sprite_url,
    s.hp,
    s.attack,
    s.defense,
    s.sp_attack,
    s.sp_defense,
    s.speed,
    s.base_stat_total,
    s.stat_archetype
from pokemon.dim_pokemon p
join pokemon.fct_pokemon_stats s on p.pokemon_id = s.pokemon_id
where p.pokemon_display_name = '${inputs.pokemon_b.value}'
```

```sql p1_attacks_p2
select
    e.attacking_type_name as attacking_type,
    e.defending_type_name as defending_type,
    e.multiplier,
    e.effectiveness_label
from pokemon.fct_type_effectiveness e
where e.attacking_type_name in (
    select primary_type from pokemon.dim_pokemon where pokemon_display_name = '${inputs.pokemon_a.value}'
)
and e.defending_type_name in (
    select primary_type from pokemon.dim_pokemon where pokemon_display_name = '${inputs.pokemon_b.value}'
)
```

```sql p1_attacks_p2_secondary
select
    e.attacking_type_name as attacking_type,
    e.defending_type_name as defending_type,
    e.multiplier,
    e.effectiveness_label
from pokemon.fct_type_effectiveness e
where e.attacking_type_name in (
    select primary_type from pokemon.dim_pokemon where pokemon_display_name = '${inputs.pokemon_a.value}'
)
and e.defending_type_name in (
    select secondary_type from pokemon.dim_pokemon where pokemon_display_name = '${inputs.pokemon_b.value}'
)
```

```sql p2_attacks_p1
select
    e.attacking_type_name as attacking_type,
    e.defending_type_name as defending_type,
    e.multiplier,
    e.effectiveness_label
from pokemon.fct_type_effectiveness e
where e.attacking_type_name in (
    select primary_type from pokemon.dim_pokemon where pokemon_display_name = '${inputs.pokemon_b.value}'
)
and e.defending_type_name in (
    select primary_type from pokemon.dim_pokemon where pokemon_display_name = '${inputs.pokemon_a.value}'
)
```

```sql p2_attacks_p1_secondary
select
    e.attacking_type_name as attacking_type,
    e.defending_type_name as defending_type,
    e.multiplier,
    e.effectiveness_label
from pokemon.fct_type_effectiveness e
where e.attacking_type_name in (
    select primary_type from pokemon.dim_pokemon where pokemon_display_name = '${inputs.pokemon_b.value}'
)
and e.defending_type_name in (
    select secondary_type from pokemon.dim_pokemon where pokemon_display_name = '${inputs.pokemon_a.value}'
)
```

<style>
    .sprite-p1 {
        margin-left: 24px;
    }
    .sprite-p2 {
        margin-left: 24px;
    }
</style>

