variable "services" {
  type = set(string)
  default = ["petstoreorderservice", "petstoreproductservice", "petstorepetservice"]
  description = "List of services to be deployed."
}

locals {
  petstoreapp_name = "petstoreapp"
}

resource "azurerm_log_analytics_workspace" "law_cloudx" {
  name                = var.log_analytics_workspace_name
  location            = var.container_app_location
  resource_group_name = var.container_app_rg_name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_container_app_environment" "cae_cloudx" {
  name                       = var.container_app_env_name
  location                   = var.container_app_location
  resource_group_name        = var.container_app_rg_name
  logs_destination           = "log-analytics"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law_cloudx.id
}

resource "azurerm_container_app" "ca_cloudx_services" {
  for_each                     = var.services
  name                         = "${var.container_app_name_prefix}-${each.value}"
  container_app_environment_id = azurerm_container_app_environment.cae_cloudx.id

  identity {
    type = "UserAssigned"
    identity_ids = [var.acr_managed_identity_id]
  }

  ingress {
    allow_insecure_connections = true
    client_certificate_mode    = "ignore"
    external_enabled           = true
    target_port                = 8080
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }

  registry {
    server   = "${var.acr_name}.azurecr.io"
    identity = var.acr_managed_identity_id
  }

  resource_group_name = var.container_app_rg_name
  revision_mode       = "Single"

  template {
    container {
      name   = each.value
      image  = "${var.acr_name}.azurecr.io/${each.value}:${var.docker_image_tag}"
      cpu    = 0.25
      memory = "0.5Gi"
    }

    http_scale_rule {
      concurrent_requests = "10"
      name                = "${var.container_app_name_prefix}-${each.value}-http-scale-rule"
    }

    min_replicas = 1
    max_replicas = 3
  }
}

resource "azurerm_container_app" "ca_cloudx_webapp" {
  name                         = "${var.container_app_name_prefix}-${local.petstoreapp_name}"
  container_app_environment_id = azurerm_container_app_environment.cae_cloudx.id

  depends_on = [
    azurerm_container_app.ca_cloudx_services
  ]

  identity {
    type = "UserAssigned"
    identity_ids = [var.acr_managed_identity_id]
  }

  ingress {
    allow_insecure_connections = true
    client_certificate_mode    = "ignore"
    external_enabled           = true
    target_port                = 8080

    traffic_weight {
      percentage      = 50
      # latest_revision = true
      revision_suffix = "v4"
    }

    traffic_weight {
      percentage      = 50
      # latest_revision = true
      revision_suffix = "v2"
    }
  }

  registry {
    server   = "${var.acr_name}.azurecr.io"
    identity = var.acr_managed_identity_id
  }

  resource_group_name = var.container_app_rg_name
  revision_mode       = "Multiple"

  template {
    container {
      env {
        name  = "PETSTOREORDERSERVICE_URL"
        value = "https://${azurerm_container_app.ca_cloudx_services["petstoreorderservice"].latest_revision_fqdn}"
      }
      env {
        name  = "PETSTOREPETSERVICE_URL"
        value = "https://${azurerm_container_app.ca_cloudx_services["petstorepetservice"].latest_revision_fqdn}"
      }
      env {
        name  = "PETSTOREPRODUCTSERVICE_URL"
        value = "https://${azurerm_container_app.ca_cloudx_services["petstoreproductservice"].latest_revision_fqdn}"
      }
      name   = local.petstoreapp_name
      image  = "${var.acr_name}.azurecr.io/${local.petstoreapp_name}:build-17"
      cpu    = 0.25
      memory = "0.5Gi"
    }

    http_scale_rule {
      concurrent_requests = "10"
      name                = "${var.container_app_name_prefix}-${local.petstoreapp_name}-http-scale-rule"
    }

    min_replicas = 1
    max_replicas = 3
    revision_suffix = "v4"
  }
}


/*

https://igazl-petstoreorderservice.calmgrass-55b43418.westeurope.azurecontainerapps.io/swagger-ui/index.html
igazl-petstoreorderservice--dn5od2d.calmgrass-55b43418.westeurope.azurecontainerapps.io
 */