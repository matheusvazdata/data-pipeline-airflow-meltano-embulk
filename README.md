# Extração e Ingestão de Dados com Embulk, Meltano e Airflow

[![Embulk](https://img.shields.io/badge/Embulk-v0.9.25-blue?logo=embulk)](https://www.embulk.org/)
[![Meltano](https://img.shields.io/badge/Meltano-Custom%20Tap-orange?logo=meltano)](https://meltano.com/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-12.x-blue?logo=postgresql)](https://www.postgresql.org/)
[![Docker](https://img.shields.io/badge/Docker-Compose-blue?logo=docker)](https://docs.docker.com/compose/)
[![Shell Script](https://img.shields.io/badge/Shell-Bash-black?logo=gnu-bash)](https://www.gnu.org/software/bash/)
[![Airflow (em breve)](https://img.shields.io/badge/Airflow-Coming%20Soon-lightgrey?logo=apache-airflow)](https://airflow.apache.org/)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)

Este projeto demonstra a construção de um pipeline modularizado de ingestão de dados utilizando ferramentas modernas de engenharia de dados. A arquitetura atual envolve extração de múltiplas fontes (banco relacional e arquivos CSV) e carga para um banco de destino, tudo em ambiente containerizado com Docker.

## 🔧 Tecnologias Utilizadas

- **Embulk**: extração de dados relacionais (PostgreSQL) e carga de CSVs para PostgreSQL
- **Meltano**: extração de arquivos CSV via tap customizado
- **PostgreSQL**: banco de origem e destino para ingestão
- **Docker Compose**: empacotamento dos serviços
- **Makefile**: automatização das execuções do pipeline
- **Shell Script**: geração dinâmica dos jobs e controle de entrada
- **(Futuro)** Apache Airflow: orquestração dos pipelines

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
├── data/
│   ├── northwind.sql              # Dump do banco de origem
│   ├── order_details.csv          # CSV extra para ingestão via Meltano
├── docker-compose.yml
├── Makefile
└── docs/
    └── arquitetura_de_extracao_e_ingestao.jpg
````

## ✅ Etapas Concluídas

### 1. Extração via Embulk

* 13 tabelas do PostgreSQL (Northwind) extraídas com sucesso
* Arquivos CSV organizados em `data/postgres/{tabela}/{data}/tabela.csv`
* Configuração dinâmica dos YAMLs com `create_ymls.sh`

### 2. Extração via Meltano (CSV)

* Tap customizado Singer (`tap-northwindcsv`)
* Geração de JSONL para ingestão padronizada

### 3. Carga via Meltano (JSONL → PostgreSQL)

* Target customizado com psycopg2
* Pipeline Meltano funcional

### 4. Carga via Embulk (CSV → PostgreSQL)

* Dockerfile com Embulk 0.9.25, plugins corretos e entrada dinâmica
* `entrypoint.sh` identifica arquivos, gera schema e executa carga
* Apaga arquivos temporários ao final

## 📊 Arquitetura do Pipeline

![Arquitetura do Pipeline](docs/arquitetura_de_extracao_e_ingestao.jpg)

## 🔁 Comandos Úteis

```bash
make up                 # Sobe containers
make build_all          # Rebuild completo dos serviços
make extract_all        # Executa as extrações (Embulk + Meltano)
make load_all           # Executa as cargas (JSONL + CSV)
make run_all            # Pipeline ponta-a-ponta
make logs_psql          # Acessa o banco de origem
make logs_dest          # Acessa o banco de destino
make reset_all          # Limpa tudo e reinicia
```

## 🧭 Próximos Passos

* [ ] Criar container `airflow-orchestrator` com DAGs de extração + carga
* [ ] Expor Airflow via porta 8080
* [ ] Consolidar orquestração com dependências entre tarefas
* [ ] Implementar monitoramento e testes automatizados

## ✍️ Autor

Matheus Vaz — [@matheusvazdata](https://github.com/matheusvazdata)