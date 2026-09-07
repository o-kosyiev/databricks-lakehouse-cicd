variable "project_name" {
  description = "Short lowercase name used in Azure resources."
  type        = string
  default     = "telemetry"

  validation {
    condition     = can(regex("^[a-z][a-z0-9]{2,10}$", var.project_name))
    error_message = "project_name must be 3-11 lowercase alphanumeric characters."
  }
}

variable "environment" {
  description = "Environment identifier."
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "stage", "prod"], var.environment)
    error_message = "environment must be dev, stage, or prod."
  }
}

variable "location" {
  description = "Azure region."
  type        = string
  default     = "northeurope"
}

variable "vnet_cidr" {
  description = "CIDR assigned to the injected Databricks VNet."
  type        = string
  default     = "10.60.0.0/16"
}

variable "tags" {
  description = "Additional governance tags."
  type        = map(string)
  default     = {}
}
