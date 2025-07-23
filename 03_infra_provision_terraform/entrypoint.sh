#!/bin/sh
set -eu

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
  # Salva o Job ID no .env de forma segura
  # -------------------------------
  echo "[INFO] Extraindo Job ID e atualizando variável DATABRICKS_JOB_ID no .env..."

  JOB_ID=$(terraform output -raw job_id)

  # Garante quebra de linha final para evitar concatenação de variáveis
  tail -c1 "$ENV_PATH" | read -r _ || echo >> "$ENV_PATH"

  # Atualiza a variável DATABRICKS_JOB_ID diretamente no arquivo
  awk -v jobid="$JOB_ID" '
  BEGIN { updated = 0 }
  {
    if ($0 ~ /^DATABRICKS_JOB_ID=/) {
      print "DATABRICKS_JOB_ID=" jobid
      updated = 1
    } else {
      print $0
    }
  }
  END {
    if (updated == 0) {
      print "DATABRICKS_JOB_ID=" jobid
    }
  }' "$ENV_PATH" | tee "$ENV_PATH" > /dev/null

  echo "[INFO] DATABRICKS_JOB_ID atualizado com sucesso: $JOB_ID"
fi

# -------------------------------
# Fim do script
# -------------------------------
echo "[SUCESSO] Provisionamento finalizado com sucesso."