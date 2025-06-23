# Extração e Ingestão de Dados com Embulk, Meltano e Airflow

[![Embulk](https://img.shields.io/badge/Embulk-v0.9.25-blue?logo=embulk)](https://www.embulk.org/)
[![Meltano](https://img.shields.io/badge/Meltano-Custom%20Tap-orange?logo=meltano)](https://meltano.com/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-12.x-blue?logo=postgresql)](https://www.postgresql.org/)
[![Docker](https://img.shields.io/badge/Docker-Compose-blue?logo=docker)](https://docs.docker.com/compose/)
[![Shell Script](https://img.shields.io/badge/Shell-Bash-black?logo=gnu-bash)](https://www.gnu.org/software/bash/)
[![Airflow](https://img.shields.io/badge/Airflow-2.x-blue?logo=apache-airflow)](https://airflow.apache.org/)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)

Este projeto demonstra a construção de um pipeline modularizado de ingestão de dados utilizando ferramentas modernas de engenharia de dados. A arquitetura envolve extração de múltiplas fontes (banco relacional e arquivos CSV) e carga para um banco de destino, tudo em ambiente containerizado com Docker e orquestrado com Apache Airflow.

## 🔧 Tecnologias Utilizadas

- **Embulk**: extração de dados relacionais (PostgreSQL) e carga de CSVs para PostgreSQL
- **Meltano**: extração de arquivos CSV via tap customizado
- **PostgreSQL**: banco de origem e destino para ingestão
- **Docker Compose**: empacotamento dos serviços
- **Makefile**: automatização das execuções do pipeline
- **Apache Airflow**: orquestração das tarefas
- **Shell Script**: geração dinâmica dos jobs e controle de entrada

## 📦 Estrutura de Diretórios

```bash
.
├── extract-postgres-embulk/       # Container Embulk para extração relacional
│   ├── Dockerfile
│   ├── entrypoint.sh
│   └── scripts/create_ymls.sh
├── extract-csv-meltano/           # Container Meltano com tap customizado
│   ├── meltano.yml
│   └── plugins/extractors/tap-northwindcsv/...
├── load-jsonl-meltano/            # Carga de JSONL via Meltano (target customizado)
│   ├── entrypoint.sh
│   └── plugins/loaders/target-postgres-custom/...
├── load-csv-embulk/               # Carga de CSVs no PostgreSQL via Embulk
│   ├── Dockerfile
│   ├── entrypoint.sh
│   └── config/templates/base_template.yml
├── orchestrate-airflow/           # Orquestração com Airflow
│   ├── Dockerfile
│   └── dags/run_pipeline.py
├── data/
│   ├── northwind.sql              # Dump do banco de origem
│   ├── order_details.csv          # CSV extra para ingestão via Meltano
│   └── postgres/                  # Dados extraídos por tabela
├── Makefile
├── docker-compose.yml
└── docs/
    └── arquitetura_de_extracao_e_ingestao.jpg
````

## 📝 Configuração do Ambiente

1. Copie o arquivo de variáveis de ambiente de exemplo:

```bash
cp .env.example .env
```

2. Os valores padrão já funcionam com os containers definidos no `docker-compose.yml`, mas você pode customizá-los conforme necessário.

## ✅ Etapas Concluídas

### 1. Extração via Embulk

* 13 tabelas do PostgreSQL (Northwind) extraídas com sucesso
* Arquivos CSV organizados em `data/postgres/{tabela}/{data}/tabela.csv`
* Configuração dinâmica dos YAMLs com `create_ymls.sh`

### 2. Extração via Meltano (CSV)

* Tap customizado Singer (`tap-northwindcsv`)
* Geração de JSONL para ingestão padronizada

### 3. Carga via Meltano (JSONL → PostgreSQL)

* Target customizado com `psycopg2`
* Pipeline Meltano funcional

### 4. Carga via Embulk (CSV → PostgreSQL)

* Dockerfile com Embulk 0.9.25, plugins corretos e entrada dinâmica
* `entrypoint.sh` identifica arquivos, gera schema e executa carga
* Apaga arquivos temporários ao final

### 5. Orquestração com Apache Airflow

* DAG `run_pipeline_local` orquestra extração e carga ponta-a-ponta
* Airflow exposto via porta `8080` com interface web funcional
* Tarefas organizadas com dependências corretas

## 📊 Arquitetura do Pipeline

![Arquitetura do Pipeline](docs/arquitetura_de_extracao_e_ingestao.jpg)

## 🔁 Comandos Úteis

```bash
make up                 # Sobe todos os containers
make build_all          # Rebuild completo dos serviços
make extract_all        # Executa as extrações (Embulk + Meltano)
make load_all           # Executa as cargas (JSONL + CSV)
make run_all            # Executa tudo de ponta a ponta
make reset_all          # Remove tudo e reinicia do zero
make logs_psql          # Abre o terminal no banco de origem
make logs_dest          # Abre o terminal no banco de destino
make count_tables_dest  # Lista as tabelas do banco destino
```

## ✅ Execução da Orquestração com Airflow

Acesse a interface do Airflow em [http://localhost:8080](http://localhost:8080)
Login padrão: `admin` / `admin`

1. Habilite a DAG `run_pipeline_local`
2. Clique em “Trigger DAG” para iniciar a execução do pipeline completo

## ✍️ Autor

Matheus Vaz — [@matheusvazdata](https://github.com/matheusvazdata)