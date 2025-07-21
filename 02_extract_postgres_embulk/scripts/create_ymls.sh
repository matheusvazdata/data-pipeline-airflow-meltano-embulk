#!/bin/sh
set -eu

echo "[SCRIPT] Iniciando extração das tabelas do PostgreSQL..."

EXEC_DATE=$(date +%F)
EMBULK_BIN="embulk"
JOBS_DIR="./config/jobs"
mkdir -p "$JOBS_DIR"

TABLE_LIST="categories customer_customer_demo customer_demographics customers employee_territories employees orders products region shippers suppliers territories us_states"

for TABLE in $TABLE_LIST; do
  echo "[INFO] Processando tabela: $TABLE"

  case "$TABLE" in
    categories)
      SELECT='select: "category_id, category_name, description"'
      ;;
    employees)
      SELECT='select: "employee_id, first_name, last_name, title, birth_date"'
      ;;
    *)
      SELECT=""
      ;;
  esac

  OUTPUT_DIR="/data/postgres/${TABLE}/${EXEC_DATE}"
  mkdir -p "$OUTPUT_DIR"
  echo "[INFO] Criando saída em: ${OUTPUT_DIR}/${TABLE}.csv"

  JOB_FILE="${JOBS_DIR}/${TABLE}_job.yml"

  cat <<EOF > "$JOB_FILE"
in:
  type: postgresql
  host: ${POSTGRES_HOST}
  user: ${POSTGRES_USER}
  password: ${POSTGRES_PASSWORD}
  database: ${POSTGRES_DB}
  table: ${TABLE}
  ${SELECT}

out:
  type: file
  path_prefix: ${OUTPUT_DIR}/tmp_export
  file_ext: csv
  formatter:
    type: csv
    delimiter: ","
    newline: LF
    charset: UTF-8

exec:
  min_output_tasks: 1
EOF

  echo "[INFO] Executando job: $JOB_FILE"
  $EMBULK_BIN run "$JOB_FILE"

  echo "[INFO] Renomeando CSV final para: ${TABLE}.csv"
  mv "${OUTPUT_DIR}/tmp_export000.00.csv" "${OUTPUT_DIR}/${TABLE}.csv"

  echo "[INFO] Removendo YAML temporário: $JOB_FILE"
  rm -f "$JOB_FILE"
done