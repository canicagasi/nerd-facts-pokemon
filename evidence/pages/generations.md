---
title: Generation Overview
---
> **Note:** This dashboard currently focuses on Gen I (Kanto) for detailed stats. The generation tables below show the full franchise scope — expanding the extraction to all generations is a natural next step. We absolutely love Kanto and the original 151 ❤️

```sql generations
select
    g.generation_numeral as generation,
    g.region_display_name as region,
    g.species_count
from pokemon.dim_generation g
order by g.generation_id
```

# Generation Overview

_How many Pokemon were introduced in each generation?_

## Species Introduced per Generation

<BarChart
    data={generations}
    x=generation
    y=species_count
    title="Pokemon Species Count by Generation"
    labels=true
/>

## Generation Details

<DataTable 
    data={generations} rows=all>
    <Column id=generation title="Gen" />
    <Column id=region title="Region" />
    <Column id=species_count title="Species Introduced" />
</DataTable>

