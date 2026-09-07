resource "databricks_storage_credential" "this" {
  name           = "${var.catalog_name}-managed-identity"
  isolation_mode = "ISOLATION_MODE_ISOLATED"
  comment        = "Managed by Terraform for the synthetic telemetry workload"

  azure_managed_identity {
    access_connector_id = var.access_connector_id
  }
}

resource "databricks_external_location" "catalog" {
  name            = "${var.catalog_name}-external-location"
  url             = "${trimsuffix(var.storage_dfs_endpoint, "/")}/landing"
  credential_name = databricks_storage_credential.this.id
  isolation_mode  = "ISOLATION_MODE_ISOLATED"
  read_only       = false
  comment         = "Storage root for synthetic portfolio data"
}

resource "databricks_catalog" "this" {
  name           = var.catalog_name
  storage_root   = databricks_external_location.catalog.url
  isolation_mode = "ISOLATED"
  comment        = "Synthetic telemetry catalog managed by Terraform"

  depends_on = [databricks_external_location.catalog]
}

resource "databricks_schema" "this" {
  catalog_name = databricks_catalog.this.name
  name         = var.schema_name
  comment      = "Medallion tables and landing assets"
}

resource "databricks_grants" "catalog" {
  catalog = databricks_catalog.this.name

  grant {
    principal  = var.operator_group
    privileges = ["USE_CATALOG"]
  }
}

resource "databricks_grants" "schema" {
  schema = "${databricks_catalog.this.name}.${databricks_schema.this.name}"

  grant {
    principal = var.operator_group
    privileges = [
      "CREATE_TABLE",
      "CREATE_VOLUME",
      "MODIFY",
      "SELECT",
      "USE_SCHEMA",
    ]
  }
}

resource "databricks_volume" "landing" {
  name             = "landing"
  catalog_name     = databricks_catalog.this.name
  schema_name      = databricks_schema.this.name
  volume_type      = "EXTERNAL"
  storage_location = "${trimsuffix(databricks_external_location.catalog.url, "/")}/landing"
  comment          = "Synthetic JSON landing zone"
}
