locals {
  prefix = "${var.project_name}-${var.environment}"
  tags = merge(
    {
      environment = var.environment
      managed_by  = "terraform"
      project     = var.project_name
      data_class  = "synthetic"
    },
    var.tags
  )
}

resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

resource "azurerm_resource_group" "this" {
  name     = "rg-${local.prefix}-${random_string.suffix.result}"
  location = var.location
  tags     = local.tags
}

resource "azurerm_virtual_network" "this" {
  name                = "vnet-${local.prefix}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  address_space       = [var.vnet_cidr]
  tags                = local.tags
}

resource "azurerm_network_security_group" "databricks" {
  name                = "nsg-${local.prefix}-databricks"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  tags                = local.tags
}

resource "azurerm_subnet" "public" {
  name                 = "snet-${local.prefix}-public"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [cidrsubnet(var.vnet_cidr, 8, 0)]

  delegation {
    name = "databricks-public"
    service_delegation {
      name = "Microsoft.Databricks/workspaces"
    }
  }
}

resource "azurerm_subnet" "private" {
  name                 = "snet-${local.prefix}-private"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [cidrsubnet(var.vnet_cidr, 8, 1)]

  delegation {
    name = "databricks-private"
    service_delegation {
      name = "Microsoft.Databricks/workspaces"
    }
  }
}

resource "azurerm_subnet" "private_endpoints" {
  name                              = "snet-${local.prefix}-private-endpoints"
  resource_group_name               = azurerm_resource_group.this.name
  virtual_network_name              = azurerm_virtual_network.this.name
  address_prefixes                  = [cidrsubnet(var.vnet_cidr, 8, 2)]
  private_endpoint_network_policies = "Disabled"
}

resource "azurerm_subnet_network_security_group_association" "public" {
  subnet_id                 = azurerm_subnet.public.id
  network_security_group_id = azurerm_network_security_group.databricks.id
}

resource "azurerm_subnet_network_security_group_association" "private" {
  subnet_id                 = azurerm_subnet.private.id
  network_security_group_id = azurerm_network_security_group.databricks.id
}

resource "azurerm_storage_account" "lakehouse" {
  name                            = substr("st${var.project_name}${var.environment}${random_string.suffix.result}", 0, 24)
  resource_group_name             = azurerm_resource_group.this.name
  location                        = azurerm_resource_group.this.location
  account_tier                    = "Standard"
  account_replication_type        = var.environment == "prod" ? "ZRS" : "LRS"
  account_kind                    = "StorageV2"
  is_hns_enabled                  = true
  min_tls_version                 = "TLS1_2"
  public_network_access_enabled   = false
  shared_access_key_enabled       = false
  allow_nested_items_to_be_public = false
  tags                            = local.tags

  network_rules {
    default_action = "Deny"
    bypass         = ["AzureServices"]
  }

  blob_properties {
    delete_retention_policy {
      days = 14
    }
    container_delete_retention_policy {
      days = 14
    }
    versioning_enabled = true
  }
}

resource "azurerm_storage_container" "landing" {
  name                  = "landing"
  storage_account_id    = azurerm_storage_account.lakehouse.id
  container_access_type = "private"
}

resource "azurerm_databricks_access_connector" "this" {
  name                = "ac-${local.prefix}"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  tags                = local.tags

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_role_assignment" "access_connector_data" {
  scope                = azurerm_storage_account.lakehouse.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_databricks_access_connector.this.identity[0].principal_id
  principal_type       = "ServicePrincipal"
}

resource "azurerm_databricks_workspace" "this" {
  name                                  = "dbw-${local.prefix}"
  resource_group_name                   = azurerm_resource_group.this.name
  location                              = azurerm_resource_group.this.location
  sku                                   = "premium"
  managed_resource_group_name           = "rg-${local.prefix}-databricks-managed"
  public_network_access_enabled         = false
  network_security_group_rules_required = "NoAzureDatabricksRules"
  tags                                  = local.tags

  custom_parameters {
    no_public_ip                                         = true
    virtual_network_id                                   = azurerm_virtual_network.this.id
    public_subnet_name                                   = azurerm_subnet.public.name
    private_subnet_name                                  = azurerm_subnet.private.name
    public_subnet_network_security_group_association_id  = azurerm_subnet_network_security_group_association.public.id
    private_subnet_network_security_group_association_id = azurerm_subnet_network_security_group_association.private.id
  }
}

resource "azurerm_private_dns_zone" "databricks" {
  name                = "privatelink.azuredatabricks.net"
  resource_group_name = azurerm_resource_group.this.name
  tags                = local.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "databricks" {
  name                 = "link-${local.prefix}-databricks"
  private_dns_zone_id  = azurerm_private_dns_zone.databricks.id
  virtual_network_id   = azurerm_virtual_network.this.id
  registration_enabled = false
  tags                 = local.tags
}

resource "azurerm_private_endpoint" "databricks_ui" {
  name                = "pe-${local.prefix}-databricks-ui"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  subnet_id           = azurerm_subnet.private_endpoints.id
  tags                = local.tags

  private_service_connection {
    name                           = "psc-${local.prefix}-databricks-ui"
    private_connection_resource_id = azurerm_databricks_workspace.this.id
    subresource_names              = ["databricks_ui_api"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.databricks.id]
  }
}

resource "azurerm_private_dns_zone" "storage" {
  for_each = toset(["blob", "dfs"])

  name                = "privatelink.${each.key}.core.windows.net"
  resource_group_name = azurerm_resource_group.this.name
  tags                = local.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "storage" {
  for_each = azurerm_private_dns_zone.storage

  name                 = "link-${local.prefix}-${each.key}"
  private_dns_zone_id  = each.value.id
  virtual_network_id   = azurerm_virtual_network.this.id
  registration_enabled = false
  tags                 = local.tags
}

resource "azurerm_private_endpoint" "storage" {
  for_each = azurerm_private_dns_zone.storage

  name                = "pe-${local.prefix}-${each.key}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  subnet_id           = azurerm_subnet.private_endpoints.id
  tags                = local.tags

  private_service_connection {
    name                           = "psc-${local.prefix}-${each.key}"
    private_connection_resource_id = azurerm_storage_account.lakehouse.id
    subresource_names              = [each.key]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [each.value.id]
  }
}
