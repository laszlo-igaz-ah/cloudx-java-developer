
resource "azurerm_resource_group" "rg_permanent" {
  name     = var.permanent_rg_name
  location = var.permanent_location
}

resource "azurerm_container_registry" "permanent_acr" {
  location            = var.permanent_location
  name                = var.permanent_acr_name
  resource_group_name = azurerm_resource_group.rg_permanent.name
  admin_enabled       = true
  sku                 = "Basic"
}

resource "azurerm_user_assigned_identity" "cloudx_managed_identity" {
  location            = var.permanent_location
  name                = var.permanent_managed_identity_name
  resource_group_name = var.permanent_rg_name
}

resource "azurerm_role_assignment" "role_acr_assigment_app_web_primary" {
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.cloudx_managed_identity.principal_id
  scope                = azurerm_container_registry.permanent_acr.id
}