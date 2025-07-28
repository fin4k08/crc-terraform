data "azurerm_client_config" "current" {}

module "resource_group" {
  source              = "git::https://github.com/fin4k08/andy-terraform-modules.git//azure/resource_group?ref=main"
  resource_group_name = var.resource_group_name
  location            = var.location
}

module "static_site" {
  source = "git::https://github.com/fin4k08/andy-terraform-modules.git//azure/storage_static_site?ref=main"

  storage_account_prefix = var.storage_account_prefix
  resource_group_name    = module.resource_group.resource_group_name
  location               = var.location
  index_document         = var.index_document
  error_404_document     = var.error_404_document
  tags                   = var.tags
}

module "frontdoor" {
  source = "git::https://github.com/fin4k08/andy-terraform-modules.git//azure/front_door_static_site?ref=main"

  resource_group_name    = module.resource_group.resource_group_name
  frontdoor_profile_name = var.frontdoor_profile_name
  endpoint_name          = var.endpoint_name

  origins = [
    {
      name                           = "static-origin"
      host_name                      = module.static_site.primary_web_host_clean
      certificate_name_check_enabled = false
    }
  ]

}

module "dns_zone" {
  source = "git::https://github.com/fin4k08/andy-terraform-modules.git//azure/dns_zone?ref=main"

  zone_name           = var.dns_zone_name
  resource_group_name = module.resource_group.resource_group_name
}

module "dns_cname_record" {
  source = "git::https://github.com/fin4k08/andy-terraform-modules.git//azure/dns_cname?ref=main"

  record_name         = var.cname_record_name
  zone_name           = module.dns_zone.zone_name
  resource_group_name = module.resource_group.resource_group_name
  ttl                 = 3600
  target_resource_id  = module.frontdoor.endpoint_id
}

resource "time_sleep" "wait_for_dns" {
  depends_on      = [module.dns_cname_record]
  create_duration = "90s" # or "2m", "1m30s", etc.
}

module "afd_public_route" {
  source = "git::https://github.com/fin4k08/andy-terraform-modules.git//azure/frontdoor_custom_domain?ref=main"

  profile_id             = module.frontdoor.profile_id
  endpoint_id            = module.frontdoor.endpoint_id
  origin_group_id        = module.frontdoor.origin_group_id
  origin_ids             = module.frontdoor.origin_ids

  route_name             = "${var.endpoint_name}-route"
  custom_domain_name     = var.frontdoor_custom_domain_name
  custom_domain_hostname = var.frontdoor_custom_domain_hostname
  certificate_type       = "ManagedCertificate"
  
  depends_on = [time_sleep.wait_for_dns]
}


module "cosmos_db" {
  source = "git::https://github.com/fin4k08/andy-terraform-modules.git//azure/cosmosdb?ref=main"

  account_name        = var.cosmos_account_name
  database_name       = var.cosmos_database_name
  container_name      = var.cosmos_container_name
  location            = var.location
  resource_group_name = module.resource_group.resource_group_name
  tags                = var.tags
}

module "app_service_plan" {
  source = "git::https://github.com/fin4k08/andy-terraform-modules.git//azure/app_service_plan?ref=main"

  name                = var.app_service_plan_name
  location            = var.location
  resource_group_name = module.resource_group.resource_group_name
  os_type             = "Linux"
  sku_name            = "Y1"
  tags                = var.tags
}

module "function_app" {
  source = "git::https://github.com/fin4k08/andy-terraform-modules.git//azure/function_app?ref=main"

  function_app_name      = var.function_app_name
  resource_group_name    = module.resource_group.resource_group_name
  location               = var.location
  app_service_plan_id    = module.app_service_plan.id
  kv_uri                 = module.key_vault.key_vault_uri
  app_settings_secrets   = var.app_settings_secrets
  storage_account_prefix = var.function_storage_account_prefix

  tags = var.tags
}


module "key_vault" {
  source = "git::https://github.com/fin4k08/andy-terraform-modules.git//azure/key_vault?ref=main"

  key_vault_name            = var.key_vault_name
  location                  = var.location
  resource_group_name       = module.resource_group.resource_group_name
  enable_rbac_authorization = true
  purge_protection_enabled  = true
  tags                      = var.tags

  rbac_admin_principal_ids = [data.azurerm_client_config.current.object_id]
}

module "kv_rbac_func" {
  source = "git::https://github.com/fin4k08/andy-terraform-modules.git//azure/key_vault_rbac_role_assignment?ref=main"

  key_vault_id         = module.key_vault.key_vault_id
  principal_id         = module.function_app.function_app_identity_principal_id
  role_definition_name = "Key Vault Secrets User"

  depends_on = [module.function_app]
}

resource "time_sleep" "wait_for_rbac" {
  depends_on      = [module.kv_rbac_func]
  create_duration = "60s" # or "2m", "1m30s", etc.
}

module "key_vault_secrets" {
  source = "git::https://github.com/fin4k08/andy-terraform-modules.git//azure/key_vault_secrets?ref=main"

  key_vault_id = module.key_vault.key_vault_id
  secrets = {
    COSMOS-DB-ENDPOINT  = module.cosmos_db.endpoint
    COSMOS-DB-KEY       = module.cosmos_db.primary_key
    COSMOS-DB-DATABASE  = module.cosmos_db.database_name
    COSMOS-DB-CONTAINER = module.cosmos_db.container_name
  }

  depends_on = [ time_sleep.wait_for_rbac ]
}
