.PHONY: up down build extract_postgres logs_psql reset_all clean_data clean_jobs

# Sobe todos os serviços com rebuild forçado
up:
	docker compose up -d --build

# Derruba todos os serviços e remove volumes e orfãos
down:
	docker compose down -v --remove-orphans

# Rebuild do container de extração apenas
build:
	docker compose build --no-cache extract-postgres-embulk

# Executa a extração completa via Embulk (entrypoint padrão)
extract_postgres:
	docker exec -it extract-postgres-embulk sh ./entrypoint.sh

# Acessa o psql no banco Northwind
logs_psql:
	docker exec -it db psql -U northwind_user -d northwind

# Limpa a pasta de dados gerados (CSV)
clean_data:
	sudo rm -rf ./data/postgres

# Limpa os YAMLs de job gerados
clean_jobs:
	sudo rm -rf ./extract-postgres-embulk/config/jobs

# Reset completo: apaga volumes, dados e jobs
reset_all: down clean_data clean_jobs