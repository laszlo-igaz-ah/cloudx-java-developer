variable "services" {
  type = set(string)
  default = ["petstoreorderservice", "petstoreproductservice", "petstorepetservice"]
  description = "List of services to be deployed."
}

resource "azurerm_postgresql_flexible_server" "postgres_flexible" {
  name                   = var.postgres_flex.name
  resource_group_name    = var.postgres_flex.resource_group
  location               = var.postgres_flex.location
  version                = var.postgres_flex.version
  administrator_login    = var.postgres_flex.login
  administrator_password = var.postgres_flex.password

  storage_mb = 32768

  sku_name = "B_Standard_B2s"

  lifecycle {
    ignore_changes = [
      zone
    ]
  }
}

resource "azurerm_postgresql_flexible_server_firewall_rule" "fw_rule_postgres_flexible" {
  name             = "fw-rule-${var.postgres_flex.name}"
  server_id        = azurerm_postgresql_flexible_server.postgres_flexible.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

resource "azurerm_postgresql_flexible_server_database" "petstore_database" {
  name      = "igazl-cloudx-petstore"
  server_id = azurerm_postgresql_flexible_server.postgres_flexible.id
  charset   = "UTF8"
  collation = "en_US.utf8"
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "key_vault" {
  name                       = "igazl-cloudx-kv"
  location                   = var.app_plan_web_services_location
  resource_group_name        = var.app_plan_resource_group_name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  rbac_authorization_enabled = true
}

resource "azurerm_key_vault_secret" "postgres_host" {
  name         = "postgres-host"
  value        = azurerm_postgresql_flexible_server.postgres_flexible.fqdn
  key_vault_id = azurerm_key_vault.key_vault.id

  depends_on = [azurerm_key_vault.key_vault]
}

resource "azurerm_key_vault_secret" "postgres_port" {
  name         = "postgres-port"
  value        = "5432"
  key_vault_id = azurerm_key_vault.key_vault.id

  depends_on = [azurerm_key_vault.key_vault]
}

resource "azurerm_key_vault_secret" "postgres_username" {
  name         = "postgres-username"
  value        = var.postgres_flex.login
  key_vault_id = azurerm_key_vault.key_vault.id

  depends_on = [azurerm_key_vault.key_vault]
}

resource "azurerm_key_vault_secret" "postgres_password" {
  name         = "postgres-password"
  value        = var.postgres_flex.password
  key_vault_id = azurerm_key_vault.key_vault.id

  depends_on = [azurerm_key_vault.key_vault]
}

resource "azurerm_role_assignment" "key_vault_secrets_user" {
  scope                = azurerm_key_vault.key_vault.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = var.acr_managed_identity_principal_id

  depends_on = [azurerm_key_vault.key_vault]
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
    azurerm_postgresql_flexible_server.postgres_flexible,
    azurerm_postgresql_flexible_server_database.petstore_database,
    azurerm_postgresql_flexible_server_firewall_rule.fw_rule_postgres_flexible,
    azurerm_key_vault_secret.postgres_host,
    azurerm_key_vault_secret.postgres_port,
    azurerm_key_vault_secret.postgres_username,
    azurerm_key_vault_secret.postgres_password,
    azurerm_role_assignment.key_vault_secrets_user
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

  key_vault_reference_identity_id = var.acr_managed_identity_id

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
    POSTGRES_HOST                         = "@Microsoft.KeyVault(SecretUri=https://${azurerm_key_vault.key_vault.name}.vault.azure.net/secrets/${azurerm_key_vault_secret.postgres_host.name}/)"
    POSTGRES_PORT                         = "@Microsoft.KeyVault(SecretUri=https://${azurerm_key_vault.key_vault.name}.vault.azure.net/secrets/${azurerm_key_vault_secret.postgres_port.name}/)"
    POSTGRES_DATABASE                     = azurerm_postgresql_flexible_server_database.petstore_database.name
    POSTGRES_USERNAME                     = "@Microsoft.KeyVault(SecretUri=https://${azurerm_key_vault.key_vault.name}.vault.azure.net/secrets/${azurerm_key_vault_secret.postgres_username.name}/)"
    POSTGRES_PASSWORD                     = "@Microsoft.KeyVault(SecretUri=https://${azurerm_key_vault.key_vault.name}.vault.azure.net/secrets/${azurerm_key_vault_secret.postgres_password.name}/)"
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
    azurerm_postgresql_flexible_server.postgres_flexible,
    azurerm_postgresql_flexible_server_database.petstore_database,
    azurerm_postgresql_flexible_server_firewall_rule.fw_rule_postgres_flexible
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

