FROM python:3.10-slim

WORKDIR /app

# Instala dependências nativas para compilar psycopg2 e outros plugins
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      gcc \
      libpq-dev \
      python3-dev \
      build-essential \
      git \
    && rm -rf /var/lib/apt/lists/*

# Instala o Meltano
RUN pip install --upgrade pip && pip install meltano

# Copia arquivos do projeto
COPY logging.conf /app/logging.conf
COPY . .

# Instala dependências do loader customizado
RUN pip install -r plugins/loaders/target-postgres-custom/requirements.txt

# Define variável de logging
ENV LOGGING_CONF_FILE=/app/logging.conf

# Permissão de execução do entrypoint
RUN chmod +x entrypoint.sh

# Atualiza lockfile e instala os plugins
RUN meltano lock --update --all && meltano install

ENTRYPOINT ["sh", "./entrypoint.sh"]