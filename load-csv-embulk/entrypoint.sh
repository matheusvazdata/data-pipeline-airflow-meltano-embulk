#!/bin/sh
set -eu

DATA_DIR="data/postgres"
DATE_DIR=$(date +%Y-%m-%d)
TEMPLATE_PATH="config/templates/base_template.yml"
JOBS_PATH="config/jobs"

echo "========================================"
echo "Iniciando carga CSV → PostgreSQL com Embulk"
echo "========================================"

mkdir -p "$JOBS_PATH"

for TABLE_PATH in ${DATA_DIR}/*; do
  TABLE_NAME=$(basename "$TABLE_PATH")
  CSV_FILE="${TABLE_PATH}/${DATE_DIR}/${TABLE_NAME}.csv"

  if [ -f "$CSV_FILE" ]; then
    LINE_COUNT=$(wc -l < "$CSV_FILE" | tr -d ' ')
    FILE_SIZE=$(stat -c %s "$CSV_FILE")

    if [ "$LINE_COUNT" -le 1 ] || [ "$FILE_SIZE" -eq 0 ]; then
      echo "CSV ignorado (vazio ou com apenas cabeçalho): $CSV_FILE"
      continue
    fi

    echo "Processando tabela: $TABLE_NAME"

    export CSV_FILE="$CSV_FILE"
    export TABLE_NAME="$TABLE_NAME"
    export PG_HOST PG_USER PG_PASSWORD PG_DATABASE

    FINAL_JOB="${JOBS_PATH}/${TABLE_NAME}.yml"

    # Extrai cabeçalho do CSV
    HEADER=$(head -n 1 "$CSV_FILE")

    # Separa partes do template
    awk '/^out:/ { exit } { print }' "$TEMPLATE_PATH" | envsubst > "$FINAL_JOB"

    echo "    columns:" >> "$FINAL_JOB"
    echo "$HEADER" | awk -F',' '{ for (i = 1; i <= NF; i++) printf "      - {name: \"%s\", type: string}\n", $i }' >> "$FINAL_JOB"

    awk '/^out:/,0' "$TEMPLATE_PATH" | envsubst >> "$FINAL_JOB"

    embulk run "$FINAL_JOB"

    echo "Carga concluída para a tabela: $TABLE_NAME"
    echo "----------------------------------------"

  else
    echo "CSV não encontrado: $CSV_FILE"
  fi
done

echo "Removendo arquivos temporários gerados..."
rm -rf "$JOBS_PATH"

echo "Pipeline concluído com sucesso."