.PHONY: \
	up down build \
	build_csv build_embulk build_databricks build_terraform build_all \
	extract_postgres extract_csv extract_all \
	load_databricks run_all \
	provision_infra destroy_infra \
	run_pipeline \
	logs_psql \
	clean_data reset_all

# Infraestrutura com Docker
up:
	@echo "🔧 Subindo todos os containers com build atualizado..."
	docker compose up -d --build

down:
	@echo "🧹 Derrubando todos os containers e removendo volumes e órfãos..."
	docker compose down -v --remove-orphans

build:
	@echo "🛠️ Build completo dos containers sem cache..."
	docker compose build --no-cache

build_all: build_csv build_embulk build_databricks build_terraform

build_csv:
	@echo "📦 Build do container 01_extract_csv_meltano (extração via Meltano)..."
	docker compose build --no-cache 01_extract_csv_meltano

build_embulk:
	@echo "📦 Build do container 02_extract_postgres_embulk (extração via Embulk)..."
	docker compose build --no-cache 02_extract_postgres_embulk

build_databricks:
	@echo "📦 Build do container 04_load_to_databricks (upload e job no Databricks)..."
	docker compose build --no-cache 04_load_to_databricks

build_terraform:
	@echo "📦 Build do container 03_infra_provision_terraform (provisionamento no Databricks)..."
	docker compose build --no-cache 03_infra_provision_terraform

# Extração de dados (fonte PostgreSQL e CSV)
extract_postgres:
	@echo "📤 Executando extração de dados do banco PostgreSQL via Embulk..."
	docker exec 02_extract_postgres_embulk sh ./entrypoint.sh

extract_csv:
	@echo "📤 Executando extração do arquivo CSV via Meltano..."
	docker exec 01_extract_csv_meltano sh ./entrypoint.sh

extract_all: extract_postgres extract_csv

# Carga e execução no Databricks (upload + job runner)
load_databricks:
	@echo "🚀 Executando carga para o Databricks (upload + execução de job)..."
	docker exec 04_load_to_databricks sh ./entrypoint.sh

run_all: extract_all load_databricks

# Provisionamento via Terraform (Databricks)
provision_infra:
	@echo "Provisionando catálogo, schema, volume, notebook e job no Databricks via Terraform..."
	docker exec 03_infra_provision_terraform sh ./entrypoint.sh apply

destroy_infra:
	@echo "Destruindo infraestrutura no Databricks via Terraform..."
	docker exec 03_infra_provision_terraform sh ./entrypoint.sh destroy

# Pipeline ponta a ponta (infra + extração + carga)
run_pipeline: provision_infra extract_all load_databricks
	@echo "[FINALIZADO] Pipeline completo executado com sucesso!"

# Acesso ao banco PostgreSQL de origem (modo interativo)
logs_psql:
	@echo "Acessando banco PostgreSQL de origem (db)..."
	docker exec -it db psql -U northwind_user -d northwind

# Limpeza de artefatos locais
clean_data:
	@echo "Removendo arquivos .parquet gerados no diretório /data..."
	sudo find ./data -maxdepth 1 -type f -name "*.parquet" -delete

reset_all: down clean_data