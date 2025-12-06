variable "services" {
  type = set(string)
  default = ["petstoreorderservice", "petstoreproductservice", "petstorepetservice"]
  description = "List of services to be deployed."
}

data "azurerm_client_config" "current" {}

resource "azurerm_postgresql_flexible_server" "postgres_flexible" {
  name                   = var.postgres_flex.name
  resource_group_name    = var.postgres_flex.resource_group
  location               = var.postgres_flex.location
  version                = var.postgres_flex.version
  administrator_login    = var.postgres_flex.login
  administrator_password = var.postgres_flex.password

  storage_mb = 32768
  sku_name   = "B_Standard_B2s"

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

resource "azurerm_key_vault" "key_vault" {
  name                      = "igazl-cloudx-kv"
  location                  = var.app_plan_web_services_location
  resource_group_name       = var.app_plan_resource_group_name
  tenant_id                 = data.azurerm_client_config.current.tenant_id
  sku_name                  = "standard"
  enable_rbac_authorization = true
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

resource "azurerm_servicebus_namespace" "servicebus_namespace" {
  name                = var.servicebus_namespace_name
  location            = var.app_plan_web_services_location
  resource_group_name = var.app_plan_resource_group_name
  sku                 = "Standard"
  capacity            = 1
}

resource "azurerm_servicebus_queue" "orders_queue" {
  name                = var.servicebus_queue_name
  namespace_id        = azurerm_servicebus_namespace.servicebus_namespace.id
  partitioning_enabled = false
  max_delivery_count  = 10
}

resource "azurerm_servicebus_namespace_authorization_rule" "servicebus_auth_rule" {
  name         = "RootManageSharedAccessKey"
  namespace_id = azurerm_servicebus_namespace.servicebus_namespace.id
  listen       = true
  send         = true
  manage       = true
}

resource "azurerm_key_vault_secret" "servicebus_connection_string" {
  name         = "servicebus-connection-string"
  value        = azurerm_servicebus_namespace_authorization_rule.servicebus_auth_rule.primary_connection_string
  key_vault_id = azurerm_key_vault.key_vault.id

  depends_on = [azurerm_servicebus_namespace_authorization_rule.servicebus_auth_rule]
}


data "azurerm_application_insights" "app_insights" {
  name                = "appinsights-igazl"
  resource_group_name = var.app_plan_resource_group_name
}

data "azurerm_storage_account" "storage_cloudx_igazl" {
  name                = "storageaccountigazl"
  resource_group_name = var.app_plan_resource_group_name
}

data "azurerm_service_plan" "app_plan_services" {
  name                = var.app_plan_web_services_name
  resource_group_name = var.app_plan_resource_group_name
}

data "azurerm_service_plan" "app_plan_web_primary" {
  name                = var.app_plan_web_primary_name
  resource_group_name = var.app_plan_resource_group_name
}

data "azurerm_linux_function_app" "function_cloudx_igazl" {
  name                = "function-app-cloudx-igazl"
  resource_group_name = var.app_plan_resource_group_name
}

resource "azurerm_linux_function_app" "function_cloudx_igazl_updated" {
  name                = data.azurerm_linux_function_app.function_cloudx_igazl.name
  resource_group_name = data.azurerm_linux_function_app.function_cloudx_igazl.resource_group_name
  location            = data.azurerm_linux_function_app.function_cloudx_igazl.location

  storage_account_name       = data.azurerm_storage_account.storage_cloudx_igazl.name
  storage_account_access_key = data.azurerm_storage_account.storage_cloudx_igazl.primary_access_key

  service_plan_id = data.azurerm_service_plan.app_plan_web_primary.id

  app_settings = {
    FUNCTIONS_EXTENSION_VERSION           = "~4"
    APPINSIGHTS_INSTRUMENTATIONKEY        = data.azurerm_application_insights.app_insights.instrumentation_key
    APPLICATIONINSIGHTS_CONNECTION_STRING = data.azurerm_application_insights.app_insights.connection_string
    AZURE_STORAGE_CONNECTION_STRING       = data.azurerm_storage_account.storage_cloudx_igazl.primary_connection_string
    AZURE_SERVICE_BUS_CONNECTION_STRING   = "@Microsoft.KeyVault(SecretUri=https://${data.azurerm_key_vault.key_vault.name}.vault.azure.net/secrets/${azurerm_key_vault_secret.servicebus_connection_string.name}/)"
    EventHubConnectionString              = "@Microsoft.KeyVault(SecretUri=https://${data.azurerm_key_vault.key_vault.name}.vault.azure.net/secrets/${azurerm_key_vault_secret.servicebus_connection_string.name}/)"
  }

  site_config {
    cors {
      allowed_origins = ["https://portal.azure.com"]
    }
    application_insights_connection_string = data.azurerm_application_insights.app_insights.connection_string
    application_insights_key               = data.azurerm_application_insights.app_insights.instrumentation_key
    always_on                              = true
    application_stack {
      java_version = "21"
    }
  }

  depends_on = [azurerm_key_vault_secret.servicebus_connection_string]
}

data "azurerm_linux_web_app" "app_services" {
  for_each            = var.services
  name                = "igazl-${each.value}"
  resource_group_name = var.app_plan_resource_group_name
}

resource "azurerm_linux_web_app" "app_services_updated" {
  for_each            = var.services
  location            = var.app_plan_web_services_location
  name                = data.azurerm_linux_web_app.app_services[each.key].name
  resource_group_name = var.app_plan_resource_group_name
  service_plan_id     = data.azurerm_service_plan.app_plan_services.id

  app_settings = merge(
    data.azurerm_linux_web_app.app_services[each.key].app_settings,
    {
      AZURE_SERVICE_BUS_CONNECTION_STRING = "@Microsoft.KeyVault(SecretUri=https://${data.azurerm_key_vault.key_vault.name}.vault.azure.net/secrets/${azurerm_key_vault_secret.servicebus_connection_string.name}/)"
    }
  )

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

  depends_on = [azurerm_key_vault_secret.servicebus_connection_string]
}

data "azurerm_linux_web_app" "app_web_primary" {
  name                = var.app_web_primary_name
  resource_group_name = var.app_plan_resource_group_name
}

resource "azurerm_linux_web_app" "app_web_primary_updated" {
  location            = var.app_plan_web_primary_location
  name                = data.azurerm_linux_web_app.app_web_primary.name
  resource_group_name = var.app_plan_resource_group_name
  service_plan_id     = data.azurerm_service_plan.app_plan_web_primary.id

  app_settings = merge(
    data.azurerm_linux_web_app.app_web_primary.app_settings,
    {
      AZURE_SERVICE_BUS_CONNECTION_STRING = "@Microsoft.KeyVault(SecretUri=https://${data.azurerm_key_vault.key_vault.name}.vault.azure.net/secrets/${azurerm_key_vault_secret.servicebus_connection_string.name}/)"
    }
  )

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

  depends_on = [azurerm_key_vault_secret.servicebus_connection_string]
}

