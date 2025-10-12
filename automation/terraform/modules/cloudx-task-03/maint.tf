variable "services" {
  type = set(string)
  default = ["petstoreorderservice", "petstoreproductservice", "petstorepetservice"]
  description = "List of services to be deployed."
}

resource "azurerm_service_plan" "app_plan_services" {
  name                = var.app_plan_web_services_name
  resource_group_name = var.app_plan_resource_group_name
  location            = var.app_plan_web_services_location
  os_type             = "Linux"
  sku_name            = "S2"
}

resource "azurerm_monitor_autoscale_setting" "autoscale_app_plan_service" {
  name                = "autoscale-${var.app_plan_web_services_name}"
  resource_group_name = var.app_plan_resource_group_name
  target_resource_id  = azurerm_service_plan.app_plan_services.id
  location            = var.app_plan_web_services_location

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
  name                = var.app_plan_web_primary_name
  resource_group_name = var.app_plan_resource_group_name
  location            = var.app_plan_web_primary_location
  os_type             = "Linux"
  sku_name            = "S3"
}

resource "azurerm_service_plan" "app_plan_web_secondary" {
  name                = var.app_plan_web_secondary_name
  resource_group_name = var.app_plan_resource_group_name
  location            = var.app_plan_web_secondary_location
  os_type             = "Linux"
  sku_name            = "S1"
}

resource "azurerm_linux_web_app" "app_services" {
  for_each            = var.services
  location            = var.app_plan_web_services_location
  name                = "igazl-${each.value}"
  resource_group_name = var.app_plan_resource_group_name
  service_plan_id     = azurerm_service_plan.app_plan_services.id

  app_settings = {
    WEBSITES_PORT                      = 8080
    PETSTOREORDERSERVICE_SERVER_PORT   = 8080
    PETSTOREPETSERVICE_SERVER_PORT     = 8080
    PETSTOREPRODUCTSERVICE_SERVER_PORT = 8080
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
    "WEBSITES_PORT"            = 8080
    PETSTOREORDERSERVICE_URL   = azurerm_linux_web_app.app_services["petstoreorderservice"].default_hostname
    PETSTOREPETSERVICE_URL     = azurerm_linux_web_app.app_services["petstorepetservice"].default_hostname
    PETSTOREPRODUCTSERVICE_URL = azurerm_linux_web_app.app_services["petstoreproductservice"].default_hostname
    PETSTOREAPP_SERVER_PORT    = 8080
    DOCKER_ENABLE_CI           = true
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

resource "azurerm_linux_web_app_slot" "slot_app_plan_web_primary" {
  name           = "slot-staging"
  app_service_id = azurerm_linux_web_app.app_web_primary.id

  app_settings = {
    "WEBSITES_PORT"            = 8080
    PETSTOREORDERSERVICE_URL   = azurerm_linux_web_app.app_services["petstoreorderservice"].default_hostname
    PETSTOREPETSERVICE_URL     = azurerm_linux_web_app.app_services["petstorepetservice"].default_hostname
    PETSTOREPRODUCTSERVICE_URL = azurerm_linux_web_app.app_services["petstoreproductservice"].default_hostname
    PETSTOREAPP_SERVER_PORT    = 8080
    DOCKER_ENABLE_CI           = true
  }

  identity {
    type = "UserAssigned"
    identity_ids = [var.acr_managed_identity_id]
  }

  site_config {
    container_registry_use_managed_identity       = true
    container_registry_managed_identity_client_id = var.acr_managed_identity_client_id
    application_stack {
      docker_image_name   = "${var.app_web_docker_image_name}:build-10"
      docker_registry_url = "https://${var.acr_name}.azurecr.io"
    }
  }
}

resource "azurerm_linux_web_app" "app_web_secondary" {
  location            = var.app_plan_web_secondary_location
  name                = var.app_web_secondary_name
  resource_group_name = var.app_plan_resource_group_name
  service_plan_id     = azurerm_service_plan.app_plan_web_secondary.id

  app_settings = {
    WEBSITES_PORT              = 8080
    PETSTOREORDERSERVICE_URL   = azurerm_linux_web_app.app_services["petstoreorderservice"].default_hostname
    PETSTOREPETSERVICE_URL     = azurerm_linux_web_app.app_services["petstorepetservice"].default_hostname
    PETSTOREPRODUCTSERVICE_URL = azurerm_linux_web_app.app_services["petstoreproductservice"].default_hostname
    PETSTOREAPP_SERVER_PORT    = 8080
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

resource "azurerm_traffic_manager_profile" "tm_app_web" {
  name                   = "tm-app-web-igazl"
  resource_group_name    = var.app_plan_resource_group_name
  traffic_routing_method = "Priority"

  dns_config {
    relative_name = "tm-app-web-igazl"
    ttl           = 100
  }

  monitor_config {
    protocol                     = "HTTP"
    port                         = 80
    path                         = "/"
    interval_in_seconds          = 30
    timeout_in_seconds           = 9
    tolerated_number_of_failures = 3
  }
}

resource "azurerm_traffic_manager_azure_endpoint" "tm_endpoint_web_app_primary" {
  name                 = "tm-endpoint-web-app"
  profile_id           = azurerm_traffic_manager_profile.tm_app_web.id
  always_serve_enabled = true
  priority = 1
  target_resource_id   = azurerm_linux_web_app.app_web_primary.id
}

resource "azurerm_traffic_manager_azure_endpoint" "tm_endpoint_web_app_secondary" {
  name                 = "tm-endpoint-web-app-secondary"
  profile_id           = azurerm_traffic_manager_profile.tm_app_web.id
  always_serve_enabled = true
  priority = 2
  target_resource_id   = azurerm_linux_web_app.app_web_secondary.id
}
