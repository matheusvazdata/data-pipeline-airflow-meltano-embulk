FROM python:3.10-slim

WORKDIR /app

# Instala dependências de sistema
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      build-essential \
      gcc \
    && rm -rf /var/lib/apt/lists/*

# Instala dependências Python
RUN pip install --upgrade pip && pip install meltano

# Copia os arquivos do projeto
COPY . .

# Garante permissão de execução do entrypoint
RUN chmod +x entrypoint.sh

# Instala plugin custom local (com layout src/)
RUN pip install -e plugins/extractors/tap-northwindcsv

# Executa instalação dos plugins do meltano.yml
RUN meltano install

ENTRYPOINT ["sh", "./entrypoint.sh"]