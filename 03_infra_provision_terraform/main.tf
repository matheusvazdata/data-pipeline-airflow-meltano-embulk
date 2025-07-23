terraform {
  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = "1.22.0"
    }
  }
}

provider "databricks" {
  host  = var.databricks_host
  token = var.databricks_token
}

# Schema dentro do catálogo
resource "databricks_schema" "schema" {
  name         = var.schema_name
  catalog_name = var.catalog_name
  comment      = "Schema bronze para ingestão"
}

# Volume dentro do schema
resource "databricks_volume" "volume" {
  name         = var.volume_name
  catalog_name = var.catalog_name
  schema_name  = databricks_schema.schema.name
  volume_type  = "MANAGED"
  comment      = "Volume para armazenamento de arquivos brutos"
}

# Notebook para ingestão de dados no volume bronze
resource "databricks_notebook" "ingest_bronze_delta" {
  path     = "/Users/${var.databricks_email}/ingest_bronze_delta"
  language = "PYTHON"
  source   = "${path.module}/notebooks/ingest_bronze_delta.py"
}

# Job para executar o notebook de ingestão
resource "databricks_job" "ingest_bronze_delta" {
  name = "Ingest bronze as Delta Tables (Serverless)"

  task {
    task_key = "ingest_bronze_delta"
    notebook_task {
      notebook_path = var.notebook_path
    }
  }

  tags = {
    environment = "dev"
    owner       = var.owner
  }
}

# Exporta o ID do job criado, utilizado posteriormente na execução com a Databricks CLI
output "job_id" {
  value = databricks_job.ingest_bronze_delta.id
}