.PHONY: help all extract transform test evidence clean

.DEFAULT_GOAL := help

DBT_DIR  := transform
EVI_DIR  := evidence
DB_FILE  := data/nerd_facts.duckdb

help: ## Show available commands
	@grep -E '^[a-zA-Z_-]+:.*##' $(MAKEFILE_LIST) | awk -F ':.*## ' '{printf "  make %-16s %s\n", $$1, $$2}'

all: extract transform test sync-evidence evidence-dev ## Full pipeline

deps: ## Install Evidence dependencies (first time only)
	cd evidence && npm install && cd ..

extract: ## Extract from PokeAPI via dlt
	@mkdir -p data
	cd extract && uv run python pokemon_pipeline.py

transform: ## Run dbt models
	cd $(DBT_DIR) && uv run dbt deps && uv run dbt run --profiles-dir .

test: ## Run dbt tests
	cd $(DBT_DIR) && uv run dbt test --profiles-dir .

sync-evidence: ## Copy DuckDB + regenerate Evidence sources
	cp $(DB_FILE) $(EVI_DIR)/sources/pokemon/nerd_facts.duckdb
	cd $(EVI_DIR) && npm run sources

evidence-dev: sync-evidence ## Start Evidence dev server
	cd $(EVI_DIR) && npx evidence dev

evidence-build: sync-evidence ## Build Evidence static site
	cd $(EVI_DIR) && npx evidence build

docs: ## Generate dbt docs
	cd $(DBT_DIR) && uv run dbt docs generate --profiles-dir .

clean: ## Remove generated artifacts
	rm -f $(DB_FILE)
	rm -rf $(DBT_DIR)/target $(DBT_DIR)/dbt_packages
	rm -rf $(EVI_DIR)/.evidence $(EVI_DIR)/build
	rm -f $(EVI_DIR)/sources/pokemon/nerd_facts.duckdb
	rm -f extract/.dlt/*.lock
	rm -rf extract/.dlt/pipeline extract/.dlt/pipelines
	rm -rf extract/pokemon
