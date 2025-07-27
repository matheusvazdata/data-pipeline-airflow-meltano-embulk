#!/bin/bash
set -e

echo "[INFO] Iniciando processo no container transform-dbt..."

PROJECT_DIR="/app"

# Verifica e copia profile
if [ ! -f "$PROJECT_DIR/profiles.yml" ]; then
  echo "[ERRO] profiles.yml não encontrado em $PROJECT_DIR"
  exit 1
fi

mkdir -p ~/.dbt
cp "$PROJECT_DIR/profiles.yml" ~/.dbt/profiles.yml
echo "[INFO] Copiado profiles.yml para ~/.dbt/"

# Acessa diretório do projeto
cd "$PROJECT_DIR" || { echo "[ERRO] Diretório $PROJECT_DIR não encontrado."; exit 1; }
echo "[INFO] Diretório de projeto localizado com sucesso."

# Instala dependências
echo "[INFO] Instalando dependências via dbt deps..."
dbt deps || { echo "[ERRO] Falha ao instalar dependências."; exit 1; }

# Diagnóstico do ambiente
echo "[INFO] Executando dbt debug..."
dbt debug || { echo "[ERRO] dbt debug falhou."; exit 1; }

# Permite comandos customizados
if [ $# -eq 0 ]; then
  echo "[INFO] Nenhum argumento fornecido. Executando run + test padrão..."
  dbt run || { echo "[ERRO] dbt run falhou."; exit 1; }
  dbt test || { echo "[ERRO] dbt test falhou."; exit 1; }
else
  echo "[INFO] Executando comando customizado: dbt $*"
  dbt "$@" || { echo "[ERRO] dbt $* falhou."; exit 1; }
fi

echo "[INFO] Pipeline dbt finalizado com sucesso."