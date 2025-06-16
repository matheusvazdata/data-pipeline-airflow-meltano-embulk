#!/bin/sh
set -eu

echo "[ENTRYPOINT] Inicializando container de extração via Embulk..."

cd /app || {
  echo "[ERRO] Não foi possível acessar /app"
  exit 1
}

# Aguarda o PostgreSQL estar disponível antes de seguir
echo "[INFO] Aguardando disponibilidade do PostgreSQL..."

MAX_RETRIES=30
COUNT=0
until pg_isready -h "$POSTGRES_HOST" -p 5432 -U "$POSTGRES_USER" > /dev/null 2>&1; do
  COUNT=$((COUNT + 1))
  if [ "$COUNT" -ge "$MAX_RETRIES" ]; then
    echo "[ERRO] Timeout ao aguardar conexão com PostgreSQL (${POSTGRES_HOST}:5432)"
    exit 1
  fi
  echo "[INFO] PostgreSQL não disponível ainda em ${POSTGRES_HOST}:5432. Aguardando..."
  sleep 2
done

echo "[INFO] PostgreSQL disponível. Iniciando processo..."

# Garante permissões corretas no volume compartilhado
chown -R "$(id -u):$(id -g)" /data

# Execução padrão se nenhum argumento for passado
if [ $# -eq 0 ]; then
  echo "[INFO] Rodando script de extração padrão..."
  sh ./scripts/create_ymls.sh
else
  echo "[INFO] Executando comando customizado: $@"
  exec "$@"
fi