FROM openjdk:8

WORKDIR /app

# Instala dependências básicas
RUN apt-get update && apt-get install -y --fix-missing \
    wget \
    unzip \
    gettext \
    ruby \
    build-essential \
    postgresql-client \
    bash \
    && rm -rf /var/lib/apt/lists/*

# Instala Embulk e JRuby
RUN mkdir -p /opt/embulk && \
    wget -q https://github.com/embulk/embulk/releases/download/v0.9.25/embulk-0.9.25.jar -O /opt/embulk/embulk.jar && \
    wget -q https://repo1.maven.org/maven2/org/jruby/jruby-complete/9.1.15.0/jruby-complete-9.1.15.0.jar -O /opt/embulk/jruby-complete.jar && \
    chmod +x /opt/embulk/*.jar

RUN ln -s /opt/embulk/embulk.jar /usr/local/bin/embulk && chmod +x /usr/local/bin/embulk

# Instala os plugins necessários
RUN java -jar /opt/embulk/embulk.jar gem install \
    embulk-output-postgresql \
    embulk-input-local_file

# Copia os arquivos do projeto
COPY . /app

RUN chmod +x /app/entrypoint.sh

ENTRYPOINT ["sh", "/app/entrypoint.sh"]