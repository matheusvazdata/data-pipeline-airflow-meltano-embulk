FROM python:3.10-slim

# Instala curl, unzip e bash (necessários para CLI e scripts)
RUN apt-get update && \
    apt-get install -y curl unzip bash && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Instala a CLI moderna do Databricks (v0.205+)
RUN curl -fsSL https://raw.githubusercontent.com/databricks/setup-cli/main/install.sh | bash

# Adiciona o executável da CLI ao PATH
ENV PATH="/root/.databricks/bin:$PATH"

# Define o diretório de trabalho padrão
WORKDIR /app

# Copia todos os arquivos do projeto para o container
COPY . .

# Garante permissões de execução nos scripts
RUN chmod +x entrypoint.sh ./scripts/*.sh

# Define o ponto de entrada do container
ENTRYPOINT ["sh", "./entrypoint.sh"]