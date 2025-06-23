#!/bin/bash
set -eu

EXECUTION_DATE=${1:-}
echo "Processing date: $EXECUTION_DATE"
echo "[ENTRYPOINT] Iniciando ingestão JSONL via target-postgres-custom..."
echo "[INFO] Hostname: $(hostname)"

# Detecta caminho base
if [ -d /app ]; then
  BASE_DIR="/app"
elif [ -d /opt/airflow/scripts/load-jsonl ]; then
  BASE_DIR="/opt/airflow/scripts/load-jsonl"
else
  echo "[ERRO] Diretório base não encontrado (/app ou /opt/airflow/scripts/load-jsonl)"
  exit 1
fi

echo "[INFO] Diretório de trabalho: $BASE_DIR"

# Define data default se não passada
if [ -z "$EXECUTION_DATE" ]; then
  EXECUTION_DATE=$(date +%F)
fi

FILE="/data/csv/${EXECUTION_DATE}/order_details.jsonl"

if [ ! -f "$FILE" ]; then
  echo "[ERRO] Arquivo não encontrado: $FILE"
  exit 1
fi

echo "[INFO] Carregando arquivo: $FILE"
python3 "$BASE_DIR/plugins/loaders/target-postgres-custom/target_postgres_custom/main.py" "$FILE"

echo "[SUCESSO] Dados carregados no PostgreSQL com sucesso!"