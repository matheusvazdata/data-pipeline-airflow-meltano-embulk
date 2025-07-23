#!/bin/sh
set -eu

# ---------------------------------------------
# Limpa variável DATABRICKS_JOB_ID do .env após execução
# ---------------------------------------------
ENV_PATH="/app/.env"
if grep -q "^DATABRICKS_JOB_ID=" "$ENV_PATH"; then
  echo "[INFO] Removendo DATABRICKS_JOB_ID do .env..."
  sed -i '/^DATABRICKS_JOB_ID=/d' "$ENV_PATH"
fi

ACTION="${1:-apply}"

echo "[INFO] Ação: $ACTION"
echo "[INFO] Diretório atual: $(pwd)"

# Caminho do .env compartilhado
ENV_PATH="/infra/.env"

# -------------------------------
# Carrega variáveis do .env
# -------------------------------
if [ -f "$ENV_PATH" ]; then
  echo "[INFO] Carregando variáveis do .env..."
  set -a
  # shellcheck disable=SC1091
  . "$ENV_PATH"
  set +a
else
  echo "[ERRO] Arquivo .env não encontrado em $ENV_PATH"
  exit 1
fi

# -------------------------------
# Gera arquivo terraform.tfvars
# -------------------------------
echo "[INFO] Gerando arquivo terraform.tfvars..."

cat <<EOF > terraform.tfvars
databricks_host       = "${DATABRICKS_HOST}"
databricks_token      = "${DATABRICKS_TOKEN}"
catalog_name          = "${DATABRICKS_CATALOG}"
schema_name           = "${DATABRICKS_SCHEMA}"
volume_name           = "${DATABRICKS_VOLUME}"
databricks_email      = "${DATABRICKS_EMAIL}"
notebook_path         = "${DATABRICKS_NOTEBOOK_PATH}"
owner                 = "${DATABRICKS_OWNER}"
databricks_cluster_id = "${DATABRICKS_CLUSTER_ID}"
EOF

# -------------------------------
# Executa o Terraform
# -------------------------------
terraform init

if [ "$ACTION" = "destroy" ]; then
  terraform destroy -auto-approve
else
  terraform apply -auto-approve

  # -------------------------------
  # Atualiza Job ID no .env (sem sobrescrever)
  # -------------------------------
  echo "[INFO] Extraindo Job ID e atualizando variável DATABRICKS_JOB_ID no .env..."

  JOB_ID=$(terraform output -raw job_id)

  # Garante quebra de linha no final do arquivo, evitando concatenação
  tail -c1 "$ENV_PATH" | read -r _ || echo >> "$ENV_PATH"

  # Se a variável já existir, atualiza; senão, adiciona ao final
  if grep -q "^DATABRICKS_JOB_ID=" "$ENV_PATH"; then
    sed -i "s/^DATABRICKS_JOB_ID=.*/DATABRICKS_JOB_ID=${JOB_ID}/" "$ENV_PATH"
  else
    echo "DATABRICKS_JOB_ID=${JOB_ID}" >> "$ENV_PATH"
  fi

  echo "[INFO] DATABRICKS_JOB_ID atualizado no .env: $JOB_ID"
fi

# -------------------------------
# Fim do script
# -------------------------------
echo "[SUCESSO] Provisionamento finalizado com sucesso."