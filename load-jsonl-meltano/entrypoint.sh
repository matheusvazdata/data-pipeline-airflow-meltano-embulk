#!/bin/sh
set -eu

echo "[ENTRYPOINT] Iniciando ingestão JSONL manual via target-postgres-custom..."

DATA=$(date +%F)
FILE="/data/csv/${DATA}/order_details.jsonl"

if [ ! -f "$FILE" ]; then
  echo "[ERRO] Arquivo não encontrado: $FILE"
  exit 1
fi

echo "[INFO] Carregando arquivo: $FILE"
python3 plugins/loaders/target-postgres-custom/target_postgres_custom/main.py "$FILE"

echo "[SUCESSO] Dados carregados no PostgreSQL com sucesso!"