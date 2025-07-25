location                         = "uksouth"
resource_group_name              = "crc-af-uks-001-rg"
subscription_id                  = "3889e478-73e3-49e2-a2f8-b853342b44ba"
storage_account_prefix           = "crcafuks001sto"
frontdoor_profile_name           = "crc-af-fd-profile-dev"
endpoint_name                    = "crc-af-fd-endpoint-dev"
dns_zone_name                    = "cv.adminaf.cloud"
cname_record_name                = "www"
frontdoor_custom_domain_name     = "adminaf-cloud"
frontdoor_custom_domain_hostname = "cv.adminaf.cloud"
index_document                   = "Andrew_Findlay_Cloud_Platform_Engineer.html"
error_404_document               = "error.html"
function_app_name                = "crc-func-dev"
cosmos_account_name              = "crccosmosdbdev"
cosmos_database_name             = "crcdb"
cosmos_container_name            = "visitors"
app_service_plan_name            = "crc-func-plan"
function_storage_account_prefix  = "crcfunctsto"
key_vault_name                   = "crc-af-dev-kv"
app_settings_secrets = {
  COSMOS_DB_ENDPOINT  = "COSMOS_DB_ENDPOINT"
  COSMOS_DB_KEY       = "COSMOS_DB_KEY"
  COSMOS_DB_DATABASE  = "COSMOS_DB_DATABASE"
  COSMOS_DB_CONTAINER = "COSMOS_DB_CONTAINER"
}

tags = {
  environment = "dev"
  project     = "cloud-resume"
}


