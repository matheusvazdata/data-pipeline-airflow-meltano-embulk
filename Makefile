.PHONY: \
	up down build build_csv build_embulk build_load build_all \
	extract_postgres extract_csv extract_all \
	load_jsonl load_all run_all \
	logs_psql \
	clean_data clean_jsonl clean_jobs clean_csv_dir clean_all \
	reset_all reset_csv

# 🔧 Infraestrutura

up:
	docker compose up -d --build

down:
	docker compose down -v --remove-orphans

build:
	docker compose build --no-cache

build_all: build_csv build_embulk build_load

build_csv:
	docker compose build --no-cache extract-csv-meltano

build_embulk:
	docker compose build --no-cache extract-postgres-embulk

build_jsonl:
	docker compose build --no-cache load-jsonl-meltano

# 🚀 Execuções

extract_postgres:
	docker exec -it extract-postgres-embulk sh ./entrypoint.sh

extract_csv:
	docker exec -it extract-csv-meltano sh ./entrypoint.sh

extract_all: extract_postgres extract_csv

load_jsonl:
	docker exec -it load-jsonl-meltano sh ./entrypoint.sh

load_all: load_jsonl

run_all: extract_all load_all

# 🔍 Acesso ao banco

logs_psql:
	docker exec -it db psql -U northwind_user -d northwind

# 🧹 Limpeza

clean_data:
	sudo rm -rf ./data/postgres

clean_jsonl:
	sudo find ./data/csv -type f -name "*.jsonl" -delete

clean_csv_dir:
	sudo rm -rf ./data/csv

clean_jobs:
	sudo rm -rf ./extract-postgres-embulk/config/jobs

clean_all: clean_data clean_jsonl clean_csv_dir clean_jobs

# 💣 Reset

reset_all: down clean_all

reset_csv: down clean_jsonl clean_csv_dir