#!/bin/bash
set -eu

# ---------------------------------------------
# Define a data de execução (argumento ou atual)
# ---------------------------------------------
EXECUTION_DATE="${1:-$(date +%F)}"

# ---------------------------------------------
# Carrega variáveis do .env (montado em /app/.env via volume)
# ---------------------------------------------
if [ -f "/app/.env" ]; then
  echo "[INFO] Carregando variáveis do .env..."
  export $(grep -v '^#' /app/.env | xargs)
else
  echo "[ERRO] Arquivo .env não encontrado em /app/.env"
  exit 1
fi

# ---------------------------------------------
# Valida variável obrigatória
# ---------------------------------------------
if [ -z "${DATABRICKS_JOB_ID:-}" ]; then
  echo "[ERRO] Variável DATABRICKS_JOB_ID não está definida no .env"
  exit 1
fi

# ---------------------------------------------
# Dispara execução do job no Databricks
# ---------------------------------------------
echo "[INFO] Executando Job ID ${DATABRICKS_JOB_ID} com data ${EXECUTION_DATE}..."

JSON_PAYLOAD=$(cat <<EOF
{
  "job_id": ${DATABRICKS_JOB_ID},
  "notebook_params": {
    "EXECUTION_DATE": "${EXECUTION_DATE}"
  }
}
EOF
)

run_response=$(databricks jobs run-now --json "${JSON_PAYLOAD}")

# ---------------------------------------------
# Mostra resultado da execução
# ---------------------------------------------
echo "[INFO] Resposta da execução:"
echo "$run_response"

echo "[SUCESSO] Job no Databricks disparado com sucesso."