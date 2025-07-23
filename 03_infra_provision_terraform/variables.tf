variable "databricks_host" {
  type        = string
  description = "URL do workspace Databricks"
}

variable "databricks_token" {
  type        = string
  description = "Token de acesso ao Databricks"
  sensitive   = true
}

variable "catalog_name" {
  type        = string
  description = "Nome do catálogo (Unity Catalog)"
  default     = "northwind"
}

variable "schema_name" {
  type        = string
  description = "Nome do schema dentro do catálogo"
  default     = "bronze"
}

variable "databricks_email" {
  type        = string
  description = "Email do usuário Databricks para criação de notebooks"
}

variable "volume_name" {
  type        = string
  description = "Nome do volume gerenciado no DBFS"
  default     = "source"
}

variable "databricks_cluster_id" {
  type        = string
  description = "ID do cluster Databricks onde o job será executado"
  default     = "/sql/1.0/warehouses/2904d10d5cd10de0"
}

variable "notebook_path" {
  type        = string
  description = "Caminho completo do notebook no workspace Databricks"
}

variable "owner" {
  type        = string
  description = "Responsável pelo job"
} 