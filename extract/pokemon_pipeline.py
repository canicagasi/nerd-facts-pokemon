"""
Pokemon dlt pipeline — extracts data from PokeAPI into DuckDB.

Resources: pokemon, generations, types, pokemon_species.
"""

import logging
from collections.abc import Iterator

import dlt
from dlt.extract.source import DltSource
from dlt.sources.helpers.requests import RequestException, get as http_get
from dlt.sources.rest_api import RESTAPIConfig, rest_api_resources

logger = logging.getLogger("pokemon_pipeline")

SKIP_TYPES: frozenset[str] = frozenset({"shadow", "unknown"})


def _flatten_pokemon(item: dict) -> Iterator[dict]:
    """Flatten pokemon detail into base info + nested stats/types/abilities."""
    sprites = item.get("sprites") or {}
    yield {
        "id": item["id"],
        "name": item["name"],
        "height": item["height"],
        "weight": item["weight"],
        "base_experience": item["base_experience"],
        "order": item["order"],
        "is_default": item["is_default"],
        "sprite_front_default": sprites.get("front_default"),
        "sprite_front_shiny": sprites.get("front_shiny"),
        "stats": [
            {
                "stat_name": s["stat"]["name"],
                "base_stat": s["base_stat"],
                "effort": s["effort"],
            }
            for s in item.get("stats") or []
        ],
        "types": [
            {
                "slot": t["slot"],
                "type_name": t["type"]["name"],
            }
            for t in item.get("types") or []
        ],
        "abilities": [
            {
                "ability_name": a["ability"]["name"],
                "is_hidden": a["is_hidden"],
                "slot": a["slot"],
            }
            for a in item.get("abilities") or []
        ],
    }


def _flatten_generation(item: dict) -> Iterator[dict]:
    """Flatten generation detail into metadata + species list."""
    yield {
        "id": item["id"],
        "name": item["name"],
        "region_name": item["main_region"]["name"] if item.get("main_region") else None,
        "pokemon_species": [
            {"name": s["name"]} for s in item.get("pokemon_species") or []
        ],
    }


def _flatten_type(item: dict) -> Iterator[dict]:
    """Flatten type detail into damage relations, skipping shadow/unknown."""
    if item["name"] in SKIP_TYPES:
        return

    relations = item.get("damage_relations") or {}
    yield {
        "id": item["id"],
        "name": item["name"],
        "pokemon_count": len(item.get("pokemon") or []),
        "double_damage_to": [t["name"] for t in relations.get("double_damage_to") or []],
        "half_damage_to": [t["name"] for t in relations.get("half_damage_to") or []],
        "no_damage_to": [t["name"] for t in relations.get("no_damage_to") or []],
        "double_damage_from": [t["name"] for t in relations.get("double_damage_from") or []],
        "half_damage_from": [t["name"] for t in relations.get("half_damage_from") or []],
        "no_damage_from": [t["name"] for t in relations.get("no_damage_from") or []],
    }


@dlt.resource(name="pokemon_species", write_disposition="replace", primary_key="pokemon_id")
def pokemon_species_resource(
    base_url: str = dlt.config.value,
    pokemon_limit: int = dlt.config.value,
) -> Iterator[dict]:
    """Extract Pokedex flavor text (English, Yellow version).

    Uses a per-ID loop because pokemon-species doesn't support
    the list→detail chaining pattern.
    """
    for pokemon_id in range(1, pokemon_limit + 1):
        try:
            data = http_get(f"{base_url}/pokemon-species/{pokemon_id}").json()
        except RequestException:
            logger.warning("Failed to fetch species %d, skipping", pokemon_id)
            continue

        flavor_entry = next(
            (
                e
                for e in data.get("flavor_text_entries", [])
                if e["language"]["name"] == "en"
                and e["version"]["name"] == "yellow"
            ),
            None,
        )

        if not flavor_entry:
            continue

        yield {
            "pokemon_id": data["id"],
            "pokemon_name": data["name"],
            "flavor_text": (
                flavor_entry["flavor_text"]
                .replace("\f", " ")
                .replace("\n", " ")
                .strip()
            ),
            "version": "yellow",
            "language": "en",
        }


@dlt.source(name="pokeapi")
def pokeapi_source(
    base_url: str = dlt.config.value,
    pokemon_limit: int = dlt.config.value,
) -> DltSource:
    """Load data from PokeAPI.

    Args:
        base_url: PokeAPI base URL.
        pokemon_limit: Number of Pokemon to extract.
        Both auto-loaded from .dlt/config.toml [sources.pokeapi].
    """
    config: RESTAPIConfig = {
        "client": {
            "base_url": base_url,
            "paginator": {
                "type": "json_link",
                "next_url_path": "next",
            },
        },
        "resource_defaults": {
            "write_disposition": "replace",
            "endpoint": {
                "params": {"limit": pokemon_limit},
                "data_selector": "results",
            },
        },
        "resources": [
            {
                "name": "pokemon_list",
                "selected": False,
                "endpoint": {
                    "path": "pokemon",
                    "paginator": "single_page",
                },
            },
            {
                "name": "pokemon",
                "primary_key": "id",
                "endpoint": {
                    "path": "pokemon/{resources.pokemon_list.name}/",
                    "data_selector": "$",
                },
                "processing_steps": [{"yield_map": _flatten_pokemon}],
            },
            {
                "name": "generation_list",
                "selected": False,
                "endpoint": {
                    "path": "generation",
                    "params": {"limit": 20},
                },
            },
            {
                "name": "generations",
                "primary_key": "id",
                "endpoint": {
                    "path": "generation/{resources.generation_list.name}/",
                    "data_selector": "$",
                },
                "processing_steps": [{"yield_map": _flatten_generation}],
            },
            {
                "name": "type_list",
                "selected": False,
                "endpoint": {
                    "path": "type",
                    "params": {"limit": 30},
                },
                "processing_steps": [
                    {"filter": lambda item: item["name"] not in SKIP_TYPES},
                ],
            },
            {
                "name": "types",
                "primary_key": "id",
                "endpoint": {
                    "path": "type/{resources.type_list.name}/",
                    "data_selector": "$",
                },
                "processing_steps": [{"yield_map": _flatten_type}],
            },
        ],
    }

    yield from rest_api_resources(config)
    yield pokemon_species_resource(base_url, pokemon_limit)


def run() -> None:
    pipeline = dlt.pipeline(
        pipeline_name="catchem_all",
        destination=dlt.destinations.duckdb("../data/nerd_facts.duckdb"),
        dataset_name="pokemon",
        pipelines_dir=".dlt/pipelines",
    )

    source = pokeapi_source()
    source.max_table_nesting = 1
    load_info = pipeline.run(source)
    print(load_info)


if __name__ == "__main__":
    run()
