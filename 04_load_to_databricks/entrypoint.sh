#!/bin/bash
set -eu

# Define a data de execução (argumento ou atual)
EXECUTION_DATE="${1:-$(date +%F)}"
echo "[INFO] Iniciando carga para o Databricks | Data: ${EXECUTION_DATE}"

# Define diretório base e navega para ele
cd /app || {
  echo "[ERRO] Diretório /app não encontrado."
  exit 1
}

# Carrega variáveis de ambiente do .env da raiz
if [ -f ".env" ]; then
  echo "[INFO] Carregando variáveis de ambiente..."
  export $(grep -v '^#' .env | xargs)
else
  echo "[ERRO] .env não encontrado!"
  exit 1
fi

# Chama script de upload para o DBFS
echo "[INFO] Iniciando upload de arquivos .parquet para o Databricks..."
sh ./scripts/upload_to_dbfs.sh "$EXECUTION_DATE"

# Chama script de execução do job (se necessário)
if [ -f "./scripts/run_databricks_job.sh" ]; then
  echo "[INFO] Executando notebook via job..."
  sh ./scripts/run_databricks_job.sh "$EXECUTION_DATE"
else
  echo "[AVISO] Script de job não encontrado. Upload concluído, mas sem execução."
fi

# Finalização
echo "[SUCESSO] Processo completo: upload de arquivos .parquet realizado com sucesso."