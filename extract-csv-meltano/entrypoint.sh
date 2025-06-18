#!/bin/sh
set -eu

echo "[ENTRYPOINT] Iniciando container: $HOSTNAME"

cd /app || {
  echo "[ERRO] Não foi possível acessar /app"
  exit 1
}

# Carrega variáveis do .env (se existir)
if [ -f "/app/.env" ]; then
  echo "[INFO] Carregando variáveis do .env..."
  set -a
  . /app/.env
  set +a
fi

# Define a data atual (YYYY-MM-DD)
EXEC_DATE=$(date +%F)
DEST_DIR="/data/csv/${EXEC_DATE}"

# Cria dinamicamente a pasta destino
mkdir -p "$DEST_DIR"

# Executa a pipeline Meltano
if [ $# -eq 0 ]; then
  echo "[INFO] Executando pipeline Meltano: CSV -> JSONL"
  meltano run tap-northwindcsv target-jsonl

  # Procura JSONL gerado na raiz do projeto
  GENERATED=$(find . -maxdepth 1 -type f -name "order_details-*.jsonl" | head -n 1)
  DEST_FILE="${DEST_DIR}/order_details.jsonl"

  if [ -f "$GENERATED" ]; then
    mv "$GENERATED" "$DEST_FILE"
    echo "[INFO] Arquivo movido para: $DEST_FILE"
  else
    echo "[ERRO] Nenhum JSONL encontrado para mover."
    exit 1
  fi
else
  echo "[INFO] Executando comando customizado: $@"
  exec "$@"
fi

# Remove sobras de JSONL na raiz, se houver
rm -f ./order_details-*.jsonl