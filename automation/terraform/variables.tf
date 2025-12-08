variable "permanent_location" {
  type        = string
  default     = "eastus"
  description = "Location of the permanent resources."
}

variable "permanent_rg_name" {
  type        = string
  default     = "rg_permanent1"
  description = "Name of the permanent Resource Group."
}

variable "permanent_acr_name" {
  type        = string
  default     = "igazlcloudxpermanentacr"
  description = "Name of the Container Registry for CloudX Course"
}

variable "permanent_managed_identity_name" {
  type        = string
  default     = "cloudx-managed-identity"
  description = "Name of the User Assigned Managed Identity."
}

variable "temporary_location" {
  type        = string
  default     = "northeurope"
  description = "Location of the temporary resources."
}

variable "temporary_rg_name" {
  type        = string
  default     = "rg_temporary1"
  description = "Name of the temporary Resource Group."
}

/**
Variables for CloudX Task 03
 */

variable "app_plan_web_services_location" {
  type        = string
  default     = "northeurope"
  description = "Location of the App Service Plan for Services."
}

variable "app_plan_web_services_name" {
  type        = string
  default     = "app-plan-services"
  description = "Name of the App Service Plan for Services."
}

variable "app_plan_web_primary_location" {
  type        = string
  default     = "northeurope"
  description = "Location of the primary App Service Plan for Web App."
}

variable "app_plan_web_primary_name" {
  type        = string
  default     = "app-plan-web-primary"
  description = "Name of the primary App Service Plan for Web App."
}

variable "app_plan_web_secondary_location" {
  type        = string
  default     = "northeurope"
  description = "Location of the secondary App Service Plan for Web App."
}

variable "app_plan_web_secondary_name" {
  type        = string
  default     = "app-plan-web-secondary"
  description = "Name of the secondary App Service Plan for Web App."
}

/**
Variables for CloudX Task 04
 */

variable "container_app_env_name" {
  type        = string
  default     = "igazl-cloudx-container-app-env"
  description = "The name of the Container App Environment."
}

variable "log_analytics_workspace_name" {
  type        = string
  default     = "igazl-cloudx-log-analytics"
  description = "The name of the Log Analytics Workspace."
}

variable "container_app_name_prefix" {
  type        = string
  default     = "igazl"
  description = "Prefix for the Container App names."
}

variable "key_vault_defaults" {
  type = object({
    name = string
  })
  description = "Options for the Key Vault"
  default = {
    name = "igazl-cloudx-kv"
  }
}

variable "servicebus_defaults" {
  type = object({
    namespace_name = string
    queue_name     = string
  })
  description = "Options for Service Bus"
  default = {
    namespace_name = "cloudx-igazl-servicebus"
    queue_name     = "cloudx-igazl-orders"
  }
}

variable "postgres_flex" {
  type = object({
    name           = string
    resource_group = string
    location       = string
    version        = string
    login          = string
    password       = string
    database       = string
  })
  description = "Options for the Postgres Flex Server"
  default = {
    name           = "igazl-cloudx-postgres-flexible"
    location       = "northeurope"
    resource_group = "rg_temporary1"
    version        = "17"
    login          = "igazladmin"
    password       = "P3tSt0r3DB"
    database       = "igazl-cloudx-petstore"
  }
}

variable "app_function_defaults" {
  type = object({
    name                 = string
    storage_account_name = string
  })
  description = "Options for the Postgres Flex Server"
  default = {
    name                 = "function-app-cloudx-igazl"
    storage_account_name = "storageaccountigazl"
  }
}

variable "app_services_defaults" {
  type = object({
    resource_group_name = string
    plan_primary_name   = string
    plan_services_name  = string
    primary_web_name    = string
    primary_image_name  = string
    location            = string
    acr_name            = string
    docker_image_tag    = string
  })
  description = "Options for the App Services with primary name and the required settings for all the resources"
  default = {
    resource_group_name = "rg_temporary1"
    plan_primary_name   = "app-plan-web-primary"
    plan_services_name  = "app-plan-services"
    primary_web_name    = "igazl-petstoreapp"
    primary_image_name  = "petstoreapp"
    location            = "northeurope"
    acr_name            = "igazlcloudxpermanentacr"
    docker_image_tag    = "build-61"
  }
}