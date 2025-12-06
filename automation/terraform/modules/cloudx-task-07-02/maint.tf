variable "services" {
  type = set(string)
  default = ["petstoreorderservice", "petstoreproductservice", "petstorepetservice"]
  description = "List of services to be deployed."
}

resource "azurerm_cosmosdb_account" "cosmosdb" {
  name                = var.cosmos_db.name
  location            = var.cosmos_db.location
  resource_group_name = var.cosmos_db.resource_group
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  consistency_policy {
    consistency_level = var.cosmos_db.consistency_level
  }

  geo_location {
    location          = var.cosmos_db.location
    failover_priority = 0
  }

  public_network_access_enabled = true

  capabilities {
    name = "EnableServerless"
  }
}

resource "azurerm_cosmosdb_sql_database" "petstore_database" {
  name                = "igazl-cloudx-petstore"
  account_name        = azurerm_cosmosdb_account.cosmosdb.name
  resource_group_name = var.cosmos_db.resource_group
}

resource "azurerm_cosmosdb_sql_container" "pets_container" {
  name                  = "pets"
  account_name          = azurerm_cosmosdb_account.cosmosdb.name
  database_name         = azurerm_cosmosdb_sql_database.petstore_database.name
  resource_group_name   = var.cosmos_db.resource_group
  partition_key_paths    = ["/id"]
  partition_key_version = 1
}

resource "azurerm_cosmosdb_sql_container" "products_container" {
  name                  = "products"
  account_name          = azurerm_cosmosdb_account.cosmosdb.name
  database_name         = azurerm_cosmosdb_sql_database.petstore_database.name
  resource_group_name   = var.cosmos_db.resource_group
  partition_key_paths    = ["/id"]
  partition_key_version = 1
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

resource "azurerm_linux_web_app" "app_services" {
  depends_on = [
    azurerm_cosmosdb_account.cosmosdb,
    azurerm_cosmosdb_sql_database.petstore_database,
    azurerm_cosmosdb_sql_container.pets_container,
    azurerm_cosmosdb_sql_container.products_container
  ]
  lifecycle {
    ignore_changes = [
      tags
    ]
  }
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
    PETSTOREORDERSERVICE_URL              = "http://igazl-petstoreorderservice.azurewebsites.net"
    PETSTOREPETSERVICE_URL                = "http://igazl-petstorepetservice.azurewebsites.net"
    PETSTOREPRODUCTSERVICE_URL            = "http://igazl-petstoreproductservice.azurewebsites.net"
    ORDER_ITEM_RESERVER_FUNCTION_KEY      = "update-me-from-azure-portal-function-api-key"
    COSMOS_ENDPOINT                       = azurerm_cosmosdb_account.cosmosdb.endpoint
    COSMOS_KEY                            = azurerm_cosmosdb_account.cosmosdb.primary_key
    COSMOS_DATABASE                       = azurerm_cosmosdb_sql_database.petstore_database.name
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
  depends_on = [
    azurerm_cosmosdb_account.cosmosdb,
    azurerm_cosmosdb_sql_database.petstore_database,
    azurerm_cosmosdb_sql_container.pets_container,
    azurerm_cosmosdb_sql_container.products_container
  ]
  lifecycle {
    ignore_changes = [
      tags
    ]
  }
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

