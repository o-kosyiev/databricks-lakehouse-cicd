output "catalog_name" {
  value = databricks_catalog.this.name
}

output "schema_name" {
  value = databricks_schema.this.name
}

output "landing_volume_path" {
  value = "/Volumes/${databricks_catalog.this.name}/${databricks_schema.this.name}/${databricks_volume.landing.name}"
}
