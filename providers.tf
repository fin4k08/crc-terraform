provider "azurerm" {
  features {}
  subscription_id = var.subscription_id != null ? var.subscription_id : null
  tenant_id       = var.tenant_id != null ? var.tenant_id : null
}


