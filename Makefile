.PHONY: \
	up down build build_csv build_embulk build_jsonl build_csv_embulk build_all \
	extract_postgres extract_csv extract_all \
	load_jsonl load_csv_embulk load_all run_all \
	logs_psql logs_dest \
	clean_data clean_jsonl clean_csv_dir clean_jobs clean_csv_jobs clean_all \
	reset_all reset_csv count_tables_dest

# Infraestrutura

up:
	@echo "Subindo todos os containers com build atualizado..."
	docker compose up -d --build

down:
	@echo "Derrubando todos os containers e removendo volumes e órfãos..."
	docker compose down -v --remove-orphans

build:
	@echo "Executando build completo dos containers sem cache..."
	docker compose build --no-cache

build_all: build_csv build_embulk build_jsonl build_csv_embulk

build_csv:
	@echo "Build do container extract-csv-meltano (extração via Meltano)..."
	docker compose build --no-cache extract-csv-meltano

build_embulk:
	@echo "Build do container extract-postgres-embulk (extração via Embulk)..."
	docker compose build --no-cache extract-postgres-embulk

build_jsonl:
	@echo "Build do container load-jsonl-meltano (carga de arquivos JSONL via Meltano)..."
	docker compose build --no-cache load-jsonl-meltano

build_csv_embulk:
	@echo "Build do container load-csv-embulk (carga de arquivos CSV via Embulk)..."
	docker compose build --no-cache load-csv-embulk

# Execução da pipeline

extract_postgres:
	@echo "Executando extração de dados do banco PostgreSQL via Embulk..."
	docker exec extract-postgres-embulk sh ./entrypoint.sh

extract_csv:
	@echo "Executando extração do arquivo CSV via Meltano..."
	docker exec extract-csv-meltano sh ./entrypoint.sh

extract_all: extract_postgres extract_csv

load_jsonl:
	@echo "Executando carga dos arquivos JSONL no PostgreSQL de destino..."
	docker exec load-jsonl-meltano sh ./entrypoint.sh

load_csv_embulk:
	@echo "Executando carga dos arquivos CSV no PostgreSQL de destino via Embulk..."
	docker exec load-csv-embulk sh ./entrypoint.sh

load_all: load_jsonl load_csv_embulk

run_all: extract_all load_all

# Acesso aos bancos

logs_psql:
	@echo "Abrindo terminal do banco PostgreSQL de origem (db)..."
	docker exec -it db psql -U northwind_user -d northwind

logs_dest:
	@echo "Abrindo terminal do banco PostgreSQL de destino (db-dest)..."
	docker exec -it db-dest psql -U dest_user -d dest_db

count_tables_dest:
	@echo "Listando as tabelas presentes no banco de destino..."
	docker exec -it db-dest psql -U dest_user -d dest_db -c \
	"SELECT table_name FROM information_schema.tables WHERE table_schema='public';"

# Limpeza de artefatos locais

clean_data:
	@echo "Removendo diretório de dados extraídos do PostgreSQL..."
	sudo rm -rf ./data/postgres

clean_jsonl:
	@echo "Removendo arquivos .jsonl da extração CSV..."
	sudo find ./data/csv -type f -name "*.jsonl" -delete

clean_csv_dir:
	@echo "Removendo diretório completo da fonte CSV..."
	sudo rm -rf ./data/csv

clean_jobs:
	@echo "Nenhum job a limpar em extract-postgres-embulk (diretório removido ou não utilizado)."

clean_csv_jobs:
	@echo "Removendo jobs gerados dinamicamente para carga via Embulk (CSV)..."
	sudo rm -rf ./load-csv-embulk/config/jobs

clean_all: clean_data clean_jsonl clean_csv_dir clean_jobs clean_csv_jobs

# Reset completo da execução local

reset_all: down clean_all

reset_csv: down clean_jsonl clean_csv_dir