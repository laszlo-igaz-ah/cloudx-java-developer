variable "services" {
  type = set(string)
  default = ["petstoreorderservice", "petstoreproductservice", "petstorepetservice"]
  description = "List of services to be deployed."
}
/*
    Creating KeyVault for all the secrets
 */

resource "azurerm_role_assignment" "key_vault_secrets_user" {
  scope                = azurerm_key_vault.key_vault.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = var.managed_identity_principal_id

  depends_on = [azurerm_key_vault.key_vault]
}

/*
    Creating Postgres Flexible and add secrets to KeyVault
 */
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

resource "azurerm_servicebus_namespace" "servicebus_namespace" {
  name                = var.servicebus.namespace_name
  location            = var.app_services.location
  resource_group_name = var.app_services.resource_group_name
  sku                 = "Standard"
}

resource "azurerm_servicebus_queue" "example" {
  name         = var.servicebus.queue_name
  namespace_id = azurerm_servicebus_namespace.servicebus_namespace.id

  partitioning_enabled = false
}

resource "azurerm_postgresql_flexible_server_firewall_rule" "fw_rule_postgres_flexible" {
  name             = "fw-rule-${var.postgres_flex.name}"
  server_id        = azurerm_postgresql_flexible_server.postgres_flexible.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

resource "azurerm_postgresql_flexible_server_database" "petstore_database" {
  name      = var.postgres_flex.database
  server_id = azurerm_postgresql_flexible_server.postgres_flexible.id
  charset   = "UTF8"
  collation = "en_US.utf8"
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "key_vault" {
  name                       = var.key_vault.name
  location                   = var.app_services.location
  resource_group_name        = var.app_services.resource_group_name
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

/*
  Cosmos DB and secrets
 */

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
  name                = "igazl-cloudx-petstore-db"
  account_name        = azurerm_cosmosdb_account.cosmosdb.name
  resource_group_name = var.cosmos_db.resource_group
}

resource "azurerm_key_vault_secret" "cosmosdb_endpoint" {
  name         = "cosmosdb-endpoint"
  value        = azurerm_cosmosdb_account.cosmosdb.endpoint
  key_vault_id = azurerm_key_vault.key_vault.id

  depends_on = [azurerm_key_vault.key_vault]
}

resource "azurerm_key_vault_secret" "cosmosdb_key" {
  name         = "cosmosdb-primary-key"
  value        = azurerm_cosmosdb_account.cosmosdb.primary_key
  key_vault_id = azurerm_key_vault.key_vault.id

  depends_on = [azurerm_key_vault.key_vault]
}

resource "azurerm_key_vault_secret" "cosmosdb_database" {
  name         = "cosmosdb-database-name"
  value        = azurerm_cosmosdb_sql_database.petstore_database.name
  key_vault_id = azurerm_key_vault.key_vault.id

  depends_on = [azurerm_key_vault.key_vault]
}

/*
    Creating App Insight
 */
resource "azurerm_application_insights" "app_insights" {
  application_type    = "java"
  location            = var.app_services.location
  name                = "appinsights-igazl"
  resource_group_name = var.app_services.resource_group_name
}

/*
    Creating App Service Plans for function, the services and the primary app
 */
resource "azurerm_service_plan" "app_plan_services" {
  name                = var.app_services.plan_services_name
  resource_group_name = var.app_services.resource_group_name
  location            = var.app_services.location
  os_type             = "Linux"
  sku_name            = "S2"
}

resource "azurerm_monitor_autoscale_setting" "autoscale_app_plan_service" {
  name                = "autoscale-${var.app_services.plan_services_name}"
  resource_group_name = var.app_services.resource_group_name
  target_resource_id  = azurerm_service_plan.app_plan_services.id
  location            = var.app_services.location

  profile {
    name = "defaultProfile"

    capacity {
      minimum = "1"
      maximum = "3"
      default = "1"
    }

    rule {
      metric_trigger {
        metric_name        = "CpuPercentage"
        metric_resource_id = azurerm_service_plan.app_plan_services.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT1M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 15 # For testing
        # threshold          = 70
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT2M"
      }
    }

    rule {
      metric_trigger {
        metric_name        = "CpuPercentage"
        metric_resource_id = azurerm_service_plan.app_plan_services.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT1M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = 10 # For testing
        # threshold          = 20
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT2M"
      }
    }
  }
}

resource "azurerm_service_plan" "app_plan_web_primary" {
  name                = var.app_services.plan_primary_name
  resource_group_name = var.app_services.resource_group_name
  location            = var.app_services.location
  os_type             = "Linux"
  sku_name            = "S3"
}

/*
        Creating function and required function
 */
resource "azurerm_storage_account" "storage_cloudx_igazl" {
  name                     = var.app_function.storage_account_name
  resource_group_name      = var.app_services.resource_group_name
  location                 = var.app_services.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_linux_function_app" "function_cloudx_igazl" {
  name                = "function-app-cloudx-igazl"
  resource_group_name = var.app_services.resource_group_name
  location            = var.app_services.location

  storage_account_name       = azurerm_storage_account.storage_cloudx_igazl.name
  storage_account_access_key = azurerm_storage_account.storage_cloudx_igazl.primary_access_key

  service_plan_id = azurerm_service_plan.app_plan_web_primary.id

  connection_string {
    name  = "cloudx-igazl-orders-connection"
    type  = "ServiceBus"
    value = azurerm_servicebus_namespace.servicebus_namespace.default_primary_connection_string
  }

  app_settings = {
    AzureWebJobsServiceBus                = azurerm_servicebus_namespace.servicebus_namespace.default_primary_connection_string
    EventHubConnectionString              = azurerm_servicebus_namespace.servicebus_namespace.default_primary_connection_string
    FUNCTIONS_EXTENSION_VERSION           = "~4"
    APPINSIGHTS_INSTRUMENTATIONKEY        = azurerm_application_insights.app_insights.instrumentation_key
    APPLICATIONINSIGHTS_CONNECTION_STRING = azurerm_application_insights.app_insights.connection_string
    AZURE_STORAGE_CONNECTION_STRING       = azurerm_storage_account.storage_cloudx_igazl.primary_connection_string
    SERVICE_BUS_CONNECTION_STRING         = azurerm_servicebus_namespace.servicebus_namespace.default_primary_connection_string
    SERVICE_BUS_NAMESPACE                 = var.servicebus.namespace_name
    SERVICE_BUS_QUEUE_NAME                = var.servicebus.queue_name
  }

  site_config {
    cors {
      # use for testing from azure portal
      allowed_origins = ["https://portal.azure.com"]
    }
    application_insights_connection_string = azurerm_application_insights.app_insights.connection_string
    application_insights_key               = azurerm_application_insights.app_insights.instrumentation_key
    always_on                              = true
    application_stack {
      java_version = "21"
    }
  }

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

/*
    Creating App Services for the services
 */
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
  location            = var.app_services.location
  name                = "igazl-${each.value}"
  resource_group_name = var.app_services.resource_group_name
  service_plan_id     = azurerm_service_plan.app_plan_services.id

  key_vault_reference_identity_id = var.managed_identity_id

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
    COSMOS_ENDPOINT                       = "@Microsoft.KeyVault(SecretUri=https://${azurerm_key_vault.key_vault.name}.vault.azure.net/secrets/${azurerm_key_vault_secret.cosmosdb_endpoint.name}/)"
    COSMOS_KEY                            = "@Microsoft.KeyVault(SecretUri=https://${azurerm_key_vault.key_vault.name}.vault.azure.net/secrets/${azurerm_key_vault_secret.cosmosdb_key.name}/)"
    COSMOS_DATABASE                       = "@Microsoft.KeyVault(SecretUri=https://${azurerm_key_vault.key_vault.name}.vault.azure.net/secrets/${azurerm_key_vault_secret.cosmosdb_database.name}/)"
  }

  identity {
    type = "UserAssigned"
    identity_ids = [var.managed_identity_id]
  }

  site_config {
    container_registry_use_managed_identity       = true
    container_registry_managed_identity_client_id = var.managed_identity_client_id
    application_stack {
      docker_image_name   = "${each.value}:${var.app_services.docker_image_tag}"
      docker_registry_url = "https://${var.app_services.acr_name}.azurecr.io"
    }
  }
}

/*
    Creating App Services for the primary Web App
 */
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
  location            = var.app_services.location
  name                = var.app_services.primary_web_name
  resource_group_name = var.app_services.resource_group_name
  service_plan_id     = azurerm_service_plan.app_plan_web_primary.id

  app_settings = {
    AZURE_CLIENT_ID                       = "change-me"
    AZURE_CLIENT_SECRET                   = "change-me"
    AZURE_TENANT_DOMAIN                   = "CloudXIgazlExternalTenants"
    PETSTORE_SECURITY_ENABLED             = true
    "WEBSITES_PORT"                       = 8080
    PETSTOREORDERSERVICE_URL              = azurerm_linux_web_app.app_services["petstoreorderservice"].default_hostname
    PETSTOREPETSERVICE_URL                = azurerm_linux_web_app.app_services["petstorepetservice"].default_hostname
    PETSTOREPRODUCTSERVICE_URL            = azurerm_linux_web_app.app_services["petstoreproductservice"].default_hostname
    PETSTOREAPP_SERVER_PORT               = 8080
    APPINSIGHTS_INSTRUMENTATIONKEY        = azurerm_application_insights.app_insights.instrumentation_key
    APPLICATIONINSIGHTS_CONNECTION_STRING = azurerm_application_insights.app_insights.connection_string
    SERVICE_BUS_CONNECTION_STRING         = azurerm_servicebus_namespace.servicebus_namespace.default_primary_connection_string
    SERVICE_BUS_NAMESPACE                 = var.servicebus.namespace_name
    SERVICE_BUS_QUEUE_NAME                = var.servicebus.queue_name
    ORDER_ITEM_RESERVER_FUNCTION_ENABLED  = true
  }

  identity {
    type = "UserAssigned"
    identity_ids = [var.managed_identity_id]
  }

  site_config {
    container_registry_use_managed_identity       = true
    container_registry_managed_identity_client_id = var.managed_identity_client_id
    application_stack {
      docker_image_name   = "${var.app_services.primary_image_name}:${var.app_services.docker_image_tag}"
      docker_registry_url = "https://${var.app_services.acr_name}.azurecr.io"
    }
  }
}

resource "azurerm_linux_web_app_slot" "slot_app_plan_web_primary" {
  name           = "slot-staging"
  app_service_id = azurerm_linux_web_app.app_web_primary.id

  app_settings = {
    AZURE_CLIENT_ID                       = "change-me"
    AZURE_CLIENT_SECRET                   = "change-me"
    AZURE_TENANT_DOMAIN                   = "CloudXIgazlExternalTenants"
    PETSTORE_SECURITY_ENABLED             = true
    "WEBSITES_PORT"                       = 8080
    PETSTOREORDERSERVICE_URL              = azurerm_linux_web_app.app_services["petstoreorderservice"].default_hostname
    PETSTOREPETSERVICE_URL                = azurerm_linux_web_app.app_services["petstorepetservice"].default_hostname
    PETSTOREPRODUCTSERVICE_URL            = azurerm_linux_web_app.app_services["petstoreproductservice"].default_hostname
    PETSTOREAPP_SERVER_PORT               = 8080
    APPINSIGHTS_INSTRUMENTATIONKEY        = azurerm_application_insights.app_insights.instrumentation_key
    APPLICATIONINSIGHTS_CONNECTION_STRING = azurerm_application_insights.app_insights.connection_string
    SERVICE_BUS_CONNECTION_STRING         = azurerm_servicebus_namespace.servicebus_namespace.default_primary_connection_string
    SERVICE_BUS_NAMESPACE                 = var.servicebus.namespace_name
    SERVICE_BUS_QUEUE_NAME                = var.servicebus.queue_name
    ORDER_ITEM_RESERVER_FUNCTION_ENABLED  = true
  }

  identity {
    type = "UserAssigned"
    identity_ids = [var.managed_identity_id]
  }

  site_config {
    container_registry_use_managed_identity       = true
    container_registry_managed_identity_client_id = var.managed_identity_client_id
    application_stack {
      docker_image_name   = "${var.app_services.primary_image_name}:${var.app_services.docker_image_tag}"
      docker_registry_url = "https://${var.app_services.acr_name}.azurecr.io"
    }
  }
}

