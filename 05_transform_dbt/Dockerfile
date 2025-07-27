FROM python:3.10-slim

# Define diretório de trabalho
WORKDIR /app

# Instala dependências do sistema necessárias para dbt e Git
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    ca-certificates \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Copia arquivo de dependências Python e instala pacotes
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir -r requirements.txt

# Copia os demais arquivos do projeto dbt
COPY . .

# Cria o diretório de configuração do dbt e copia o profile
RUN mkdir -p /root/.dbt && cp profiles.yml /root/.dbt/profiles.yml

# Permite execução do script de entrada
RUN chmod +x entrypoint.sh

# Define o ponto de entrada do container
ENTRYPOINT ["bash", "entrypoint.sh"]