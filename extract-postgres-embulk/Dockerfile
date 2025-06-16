FROM openjdk:8

# Define diretório padrão de trabalho
WORKDIR /app

# Instala dependências, incluindo cliente PostgreSQL
RUN apt-get update && apt-get install -y \
    wget \
    unzip \
    gettext \
    ruby \
    build-essential \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# Cria diretório seguro e baixa Embulk + JRuby
RUN mkdir -p /opt/embulk && \
    wget -q https://github.com/embulk/embulk/releases/download/v0.9.25/embulk-0.9.25.jar -O /opt/embulk/embulk.jar && \
    wget -q https://repo1.maven.org/maven2/org/jruby/jruby-complete/9.1.15.0/jruby-complete-9.1.15.0.jar -O /opt/embulk/jruby-complete.jar && \
    chmod +x /opt/embulk/*.jar

# Symlink global para embulk
RUN ln -s /opt/embulk/embulk.jar /usr/local/bin/embulk && chmod +x /usr/local/bin/embulk

# Instala yq para manipular YAML
RUN wget -q https://github.com/mikefarah/yq/releases/download/v4.40.5/yq_linux_amd64 -O /usr/bin/yq && \
    chmod +x /usr/bin/yq

# Instala plugins do Embulk
RUN java -jar /opt/embulk/embulk.jar gem install \
    embulk-input-postgresql \
    embulk-output-parquet

# Copia arquivos do projeto
COPY . /app

# Permissão de execução
RUN chmod +x /app/entrypoint.sh /app/scripts/*.sh

# Define o entrypoint
ENTRYPOINT ["sh", "/app/entrypoint.sh"]