output "workspace_url" {
  description = "Azure Databricks workspace URL."
  value       = "https://${azurerm_databricks_workspace.this.workspace_url}"
}

output "workspace_id" {
  description = "Azure resource ID of the workspace."
  value       = azurerm_databricks_workspace.this.id
}

output "access_connector_id" {
  description = "Access connector used by Unity Catalog storage credentials."
  value       = azurerm_databricks_access_connector.this.id
}

output "storage_dfs_endpoint" {
  description = "Private ADLS Gen2 DFS endpoint."
  value       = azurerm_storage_account.lakehouse.primary_dfs_endpoint
}
