#!/bin/sh
set -eu

# ---------------------------------------------
# Remove DATABRICKS_JOB_ID da raiz do projeto (../.env)
# ---------------------------------------------
ROOT_ENV_PATH="../.env"
if [ -f "$ROOT_ENV_PATH" ]; then
  if grep -q "^DATABRICKS_JOB_ID=" "$ROOT_ENV_PATH"; then
    echo "[INFO] Limpando DATABRICKS_JOB_ID do .env da raiz do projeto..."
    sed -i '/^DATABRICKS_JOB_ID=/d' "$ROOT_ENV_PATH"
  fi
fi

# ---------------------------------------------
# Caminho interno no container
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
# Lê argumento passado (default = apply)
# -------------------------------
ACTION="${1:-apply}"
echo "[INFO] Ação: $ACTION"
echo "[INFO] Diretório atual: $(pwd)"

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
  # Atualiza Job ID no .env (modo compatível com bind mounts)
  # -------------------------------
  echo "[INFO] Extraindo Job ID e atualizando variável DATABRICKS_JOB_ID no .env..."

  JOB_ID=$(terraform output -raw job_id)

  # Garante quebra de linha no final do arquivo
  tail -c1 "$ENV_PATH" | read -r _ || echo >> "$ENV_PATH"

  echo "[INFO] Atualizando .env com redirecionamento via tee (100% seguro com bind mounts)..."

  awk -v job_id="$JOB_ID" '
    BEGIN { updated=0 }
    /^DATABRICKS_JOB_ID=/ {
      print "DATABRICKS_JOB_ID=" job_id
      updated=1
      next
    }
    { print }
    END {
      if (!updated) print "DATABRICKS_JOB_ID=" job_id
    }
  ' "$ENV_PATH" | tee "$ENV_PATH" > /dev/null

  echo "[INFO] DATABRICKS_JOB_ID atualizado no .env: $JOB_ID"
fi

# -------------------------------
# Fim do script
# -------------------------------
echo "[SUCESSO] Provisionamento finalizado com sucesso."