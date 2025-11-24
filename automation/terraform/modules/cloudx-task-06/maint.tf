variable "services" {
  type = set(string)
  default = ["petstoreorderservice", "petstoreproductservice", "petstorepetservice"]
  description = "List of services to be deployed."
}

resource "azurerm_storage_account" "storage_cloudx_igazl" {
  name                     = "storageaccountigazl"
  resource_group_name      = var.app_plan_resource_group_name
  location                 = var.app_plan_web_primary_location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_application_insights" "app_insights" {
  application_type    = "java"
  location            = var.app_plan_web_services_location
  name                = "appinsights-igazl"
  resource_group_name = var.app_plan_resource_group_name
}

resource "azurerm_service_plan" "app_plan_services" {
  name                = var.app_plan_web_services_name
  resource_group_name = var.app_plan_resource_group_name
  location            = var.app_plan_web_services_location
  os_type             = "Linux"
  sku_name            = "B2"
}

resource "azurerm_service_plan" "app_plan_web_primary" {
  name                = var.app_plan_web_primary_name
  resource_group_name = var.app_plan_resource_group_name
  location            = var.app_plan_web_primary_location
  os_type             = "Linux"
  sku_name            = "B2"
}

resource "azurerm_linux_function_app" "function_cloudx_igazl" {
  name                = "function-app-cloudx-igazl"
  resource_group_name = var.app_plan_resource_group_name
  location            = var.app_plan_web_services_location

  storage_account_name       = azurerm_storage_account.storage_cloudx_igazl.name
  # storage_account_access_key = azurerm_storage_account.storage_cloudx_igazl.primary_access_key
  storage_uses_managed_identity = true

  service_plan_id            = azurerm_service_plan.app_plan_web_primary.id

  identity {
    type = "UserAssigned"
    identity_ids = [var.acr_managed_identity_id]
  }

  app_settings = {
    FUNCTIONS_EXTENSION_VERSION           = "~4"
    APPINSIGHTS_INSTRUMENTATIONKEY        = azurerm_application_insights.app_insights.instrumentation_key
    APPLICATIONINSIGHTS_CONNECTION_STRING = azurerm_application_insights.app_insights.connection_string
  }

  site_config {

  }
}

resource "azurerm_linux_web_app" "app_services" {
  for_each            = var.services
  location            = var.app_plan_web_services_location
  name                = "igazl-${each.value}"
  resource_group_name = var.app_plan_resource_group_name
  service_plan_id     = azurerm_service_plan.app_plan_services.id

  app_settings = {
    WEBSITES_PORT                         = 8080
    PETSTOREORDERSERVICE_SERVER_PORT      = 8080
    PETSTOREPETSERVICE_SERVER_PORT        = 8080
    PETSTOREPRODUCTSERVICE_SERVER_PORT    = 8080
    APPINSIGHTS_INSTRUMENTATIONKEY        = azurerm_application_insights.app_insights.instrumentation_key
    APPLICATIONINSIGHTS_CONNECTION_STRING = azurerm_application_insights.app_insights.connection_string
  }

  identity {
    type = "UserAssigned"
    identity_ids = [var.acr_managed_identity_id]
  }

  site_config {
    container_registry_use_managed_identity       = true
    container_registry_managed_identity_client_id = var.acr_managed_identity_client_id
    application_stack {
      docker_image_name   = "${each.value}:${var.docker_image_tag}"
      docker_registry_url = "https://${var.acr_name}.azurecr.io"
    }
  }
}

resource "azurerm_linux_web_app" "app_web_primary" {
  location            = var.app_plan_web_primary_location
  name                = var.app_web_primary_name
  resource_group_name = var.app_plan_resource_group_name
  service_plan_id     = azurerm_service_plan.app_plan_web_primary.id

  app_settings = {
    "WEBSITES_PORT"                       = 8080
    PETSTOREORDERSERVICE_URL              = azurerm_linux_web_app.app_services["petstoreorderservice"].default_hostname
    PETSTOREPETSERVICE_URL                = azurerm_linux_web_app.app_services["petstorepetservice"].default_hostname
    PETSTOREPRODUCTSERVICE_URL            = azurerm_linux_web_app.app_services["petstoreproductservice"].default_hostname
    PETSTOREAPP_SERVER_PORT               = 8080
    APPINSIGHTS_INSTRUMENTATIONKEY        = azurerm_application_insights.app_insights.instrumentation_key
    APPLICATIONINSIGHTS_CONNECTION_STRING = azurerm_application_insights.app_insights.connection_string
  }

  identity {
    type = "UserAssigned"
    identity_ids = [var.acr_managed_identity_id]
  }

  site_config {
    container_registry_use_managed_identity       = true
    container_registry_managed_identity_client_id = var.acr_managed_identity_client_id
    application_stack {
      docker_image_name   = "${var.app_web_docker_image_name}:${var.docker_image_tag}"
      docker_registry_url = "https://${var.acr_name}.azurecr.io"
    }
  }
}
