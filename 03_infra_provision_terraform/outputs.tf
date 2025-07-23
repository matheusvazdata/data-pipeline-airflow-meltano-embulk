output "volume_uri" {
  value = "dbfs:/Volumes/${var.catalog_name}/${var.schema_name}/${var.volume_name}"
}