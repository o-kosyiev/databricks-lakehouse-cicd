variable "databricks_host" {
  description = "Workspace URL from the Azure infrastructure stack."
  type        = string

  validation {
    condition     = can(regex("^https://[^/]+$", var.databricks_host))
    error_message = "databricks_host must be an HTTPS origin without a path."
  }
}

variable "access_connector_id" {
  description = "Azure resource ID of the managed identity access connector."
  type        = string
}

variable "storage_dfs_endpoint" {
  description = "ADLS Gen2 DFS endpoint, including trailing slash."
  type        = string
}

variable "catalog_name" {
  description = "Unity Catalog catalog name."
  type        = string
  default     = "telemetry_dev"
}

variable "schema_name" {
  description = "Schema that contains the medallion tables and landing volume."
  type        = string
  default     = "platform_demo"
}

variable "operator_group" {
  description = "Existing Databricks group that operates the workload."
  type        = string
  default     = "data-platform-operators"
}
