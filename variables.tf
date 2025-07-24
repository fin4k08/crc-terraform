variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
  default     = null
}

variable "tenant_id" {
  description = "Optional override for Azure Tenant ID"
  type        = string
  default     = null
}

variable "location" {
  description = "Azure region for resources"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "storage_account_prefix" {
  type        = string
  description = "Prefix for storage account name (lowercase alphanumeric ≤ 18 chars)"
}

variable "index_document" {
  type    = string
  default = "index.html"
}

variable "error_404_document" {
  type    = string
  default = "404.html"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all resources"
  default     = {}
}

variable "frontdoor_profile_name" {
  type        = string
  description = "The name of the Front Door profile"
}

variable "endpoint_name" {
  type        = string
  description = "The name of the Front Door endpoint"
}

variable "health_probe" {
  type = object({
    path                = string
    protocol            = string
    request_type        = string
    interval_in_seconds = number
  })
  default = {
    path                = "/"
    protocol            = "Https"
    request_type        = "GET"
    interval_in_seconds = 240
  }
  description = "Health probe settings for Front Door."
}

variable "load_balancing" {
  type = object({
    sample_size                        = number
    successful_samples_required        = number
    additional_latency_in_milliseconds = number
  })
  default = {
    sample_size                        = 4
    successful_samples_required        = 3
    additional_latency_in_milliseconds = 0
  }
  description = "Load balancing settings for Front Door."
}

variable "dns_zone_name" {
  type        = string
  description = "The name of the DNS zone (e.g. example.com)"
}

variable "cname_record_name" {
  type        = string
  description = "The name of the CNAME record (e.g. www)"
}

variable "frontdoor_custom_domain_name" {
  type        = string
  description = "Name of the custom domain resource for Front Door"
}

variable "frontdoor_custom_domain_hostname" {
  type        = string
  description = "Hostname to map the custom domain to (e.g. www.example.com)"
}

variable "function_app_name" {
  type        = string
  description = "The name of the Azure Function App"
}

variable "cosmos_account_name" {
  type        = string
  description = "Cosmos DB account name"
}

variable "cosmos_database_name" {
  type        = string
  description = "Cosmos DB database name"
}

variable "cosmos_container_name" {
  type        = string
  description = "Cosmos DB container name"
}

variable "app_service_plan_name" {
  type        = string
  description = "Name of the App Service Plan"
}

variable "function_storage_account_prefix" {
  type        = string
  description = "Prefix for the storage account used by the function app"
}

variable "key_vault_name" {
  description = "Name of the Azure Key Vault"
  type        = string
}

variable "enable_rbac_authorization" {
  description = "Enable RBAC authorization on Key Vault"
  type        = bool
  default     = true
}

variable "purge_protection_enabled" {
  description = "Enable purge protection"
  type        = bool
  default     = true
}

variable "app_settings_secrets" {
  description = "Map of Function App settings with Key Vault secret names"
  type        = map(string)

  default = {
    COSMOS-DB-ENDPOINT  = "COSMOS_DB_ENDPOINT"
    COSMOS-DB-KEY       = "COSMOS_DB_KEY"
    COSMOS-DB-DATABASE  = "COSMOS_DB_DATABASE"
    COSMOS-DB-CONTAINER = "COSMOS_DB_CONTAINER"
  }
}
