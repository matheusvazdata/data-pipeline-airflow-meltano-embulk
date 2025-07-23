#!/bin/bash
set -eu

# Diretórios fonte (host) e destino (Databricks)
SRC_DIR="/data"
DEST_DIR="dbfs:/Volumes/${DATABRICKS_CATALOG}/${DATABRICKS_SCHEMA}/${DATABRICKS_VOLUME}"

echo "[INFO] Enviando arquivos .parquet de ${SRC_DIR} para: ${DEST_DIR}"

# Garante que o diretório remoto existe
databricks fs mkdirs "$DEST_DIR"

# Sobe apenas arquivos .parquet do diretório /data (não recursivo)
for file in "$SRC_DIR"/*.parquet; do
  [ -f "$file" ] || continue
  fname=$(basename "$file")
  echo "[UPLOAD] $fname -> $DEST_DIR/$fname"
  databricks fs cp "$file" "$DEST_DIR/$fname" --overwrite
done

# Finalização
echo "[SUCESSO] Upload concluído para o DBFS em: $DEST_DIR"