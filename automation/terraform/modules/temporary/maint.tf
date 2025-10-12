
resource "azurerm_resource_group" "rg_temporary" {
  name     = var.temporary_rg_name
  location = var.temporary_location
}

