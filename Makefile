.PHONY: \
	up down build \
	build_csv build_db build_databricks build_terraform build_dbt build_all \
	extract_db extract_csv extract_all \
	load_databricks run_transform \
	dbt_debug dbt_run dbt_test dbt_build \
	run_staging run_intermediate run_marts \
	test_staging test_intermediate test_marts \
	run_all run_pipeline \
	provision_infra destroy_infra \
	logs_psql clean_data reset_all

# Infraestrutura com Docker
up:
	@echo "Subindo todos os containers com build atualizado..."
	docker compose up -d --build

down:
	@echo "Derrubando todos os containers e removendo volumes e órfãos..."
	docker compose down -v --remove-orphans

build:
	@echo "Build completo dos containers sem cache..."
	docker compose build --no-cache

build_all: build_csv build_db build_databricks build_terraform build_dbt

build_csv:
	@echo "Build do container 01_extract_csv_meltano (extração via Meltano)..."
	docker compose build --no-cache 01_extract_csv_meltano

build_db:
	@echo "Build do container 02_extract_postgres_embulk (extração via Embulk)..."
	docker compose build --no-cache 02_extract_postgres_embulk

build_databricks:
	@echo "Build do container 04_load_to_databricks (upload e execução de job no Databricks)..."
	docker compose build --no-cache 04_load_to_databricks

build_terraform:
	@echo "Build do container 03_infra_provision_terraform (provisionamento no Databricks)..."
	docker compose build --no-cache 03_infra_provision_terraform

build_dbt:
	@echo "Build do container 05_transform_dbt (transformações com dbt)..."
	docker compose build --no-cache 05_transform_dbt

# Extração de dados
extract_db:
	@echo "Executando extração de dados do banco de origem via Embulk..."
	docker exec 02_extract_postgres_embulk sh ./entrypoint.sh

extract_csv:
	@echo "Executando extração do arquivo CSV via Meltano..."
	docker exec 01_extract_csv_meltano sh ./entrypoint.sh

extract_all: extract_db extract_csv

# Carga no Databricks
load_databricks:
	@echo "Executando carga para o Databricks (upload de arquivos e execução de job)..."
	docker exec 04_load_to_databricks sh ./entrypoint.sh

# Transformações com dbt
transform_dbt:
	@echo "Executando transformações com dbt (run + test)..."
	docker exec 05_transform_dbt bash ./entrypoint.sh

dbt_debug:
	@echo "Executando dbt debug..."
	docker exec 05_transform_dbt dbt debug

dbt_deps:
	@echo "Instalando dependências dos pacotes definidos em packages.yml..."
	docker exec 05_transform_dbt dbt deps

dbt_run:
	@echo "Executando dbt run em todos os modelos..."
	docker exec 05_transform_dbt dbt run

dbt_test:
	@echo "Executando dbt test em todos os modelos..."
	docker exec 05_transform_dbt dbt test

dbt_build:
	@echo "Executando dbt build em todos os modelos..."
	docker exec 05_transform_dbt dbt build

# Execução por camada (via tags)
dbt_run_staging:
	@echo "Executando dbt run nos modelos com tag: stg (staging)..."
	docker exec 05_transform_dbt dbt run --select tag:stg

dbt_run_intermediate:
	@echo "Executando dbt run nos modelos com tag: int (intermediate)..."
	docker exec 05_transform_dbt dbt run --select tag:int

dbt_run_marts:
	@echo "Executando dbt run nos modelos com tag: marts..."
	docker exec 05_transform_dbt dbt run --select tag:marts

dbt_test_staging:
	@echo "Executando dbt test nos modelos com tag: stg (staging)..."
	docker exec 05_transform_dbt dbt test --select tag:stg

dbt_test_intermediate:
	@echo "Executando dbt test nos modelos com tag: int (intermediate)..."
	docker exec 05_transform_dbt dbt test --select tag:int

dbt_test_marts:
	@echo "Executando dbt test nos modelos com tag: marts..."
	docker exec 05_transform_dbt dbt test --select tag:marts

# Execução ponta-a-ponta (sem provisionamento)
run_all: extract_all load_databricks run_transform

# Pipeline completo (inclui provisionamento)
run_pipeline: provision_infra extract_all load_databricks run_transform
	@echo "Pipeline completo executado com sucesso."

# Provisionamento via Terraform
provision_infra:
	@echo "Provisionando catálogo, schema, volume, notebook e job no Databricks via Terraform..."
	docker exec 03_infra_provision_terraform sh ./entrypoint.sh apply

destroy_infra:
	@echo "Destruindo infraestrutura no Databricks via Terraform..."
	docker exec 03_infra_provision_terraform sh ./entrypoint.sh destroy

# Acesso ao banco PostgreSQL de origem (modo interativo)
logs_psql:
	@echo "Acessando banco PostgreSQL de origem (container db)..."
	docker exec -it db psql -U northwind_user -d northwind

# Limpeza de artefatos locais
clean_data:
	@echo "Removendo arquivos .parquet do diretório /data..."
	sudo find ./data -maxdepth 1 -type f -name "*.parquet" -delete

reset_all: down clean_data