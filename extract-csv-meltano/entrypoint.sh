#!/bin/bash
set -eu

EXECUTION_DATE=${1:-}
echo "Processing date: $EXECUTION_DATE"
echo "[ENTRYPOINT] Iniciando container: $(hostname)"

# Detecta se está rodando em /app ou /opt/airflow/scripts
if [ -d /app ]; then
  cd /app
elif [ -d /opt/airflow/scripts/extract-csv ]; then
  cd /opt/airflow/scripts/extract-csv
else
  echo "[ERRO] Não foi possível acessar diretório de trabalho (/app ou /opt/airflow/scripts/extract-csv)"
  exit 1
fi

echo "[INFO] Diretório de trabalho: $(pwd)"

# Carrega variáveis do .env (se existir)
if [ -f ".env" ]; then
  echo "[INFO] Carregando variáveis do .env..."
  set -a
  . .env
  set +a
fi

# Define data de processamento
if [ -z "$EXECUTION_DATE" ]; then
  EXEC_DATE=$(date +%F)
else
  EXEC_DATE="$EXECUTION_DATE"
fi

DEST_DIR="/data/csv/${EXEC_DATE}"

# Cria pasta destino com fallback se falhar permissões
mkdir -p "$DEST_DIR" || { echo "[ERRO] Falha ao criar diretório: $DEST_DIR"; exit 1; }
echo "[INFO] Pasta de destino criada: $DEST_DIR"

# Executa pipeline Meltano
echo "[INFO] Executando pipeline Meltano: CSV -> JSONL"
if ! command -v meltano >/dev/null 2>&1; then
  echo "[ERRO] Meltano não encontrado no PATH"
  exit 127
fi

meltano run tap-northwindcsv target-jsonl

# Move JSONL gerado
GENERATED=$(find . -maxdepth 1 -type f -name "order_details-*.jsonl" | head -n 1)
DEST_FILE="${DEST_DIR}/order_details.jsonl"

if [ -f "$GENERATED" ]; then
  mv "$GENERATED" "$DEST_FILE"
  echo "[INFO] Arquivo movido para: $DEST_FILE"
else
  echo "[ERRO] Nenhum JSONL encontrado para mover."
  exit 1
fi

# Remove arquivos temporários
rm -f ./order_details-*.jsonl || true

echo "[SUCESSO] Extração CSV -> JSONL concluída com sucesso."