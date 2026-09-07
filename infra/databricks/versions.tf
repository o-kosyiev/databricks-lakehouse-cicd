terraform {
  required_version = ">= 1.10, < 2.0"

  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = ">= 1.70, < 2.0"
    }
  }

  backend "azurerm" {}
}

provider "databricks" {
  host      = var.databricks_host
  auth_type = "azure-cli"
}
