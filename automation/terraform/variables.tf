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
  default     = "westeurope"
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
  default     = "eastus"
  description = "Location of the App Service Plan for Services."
}

variable "app_plan_web_services_name" {
  type        = string
  default     = "app-plan-services"
  description = "Name of the App Service Plan for Services."
}

variable "app_plan_web_primary_location" {
  type        = string
  default     = "eastus"
  description = "Location of the primary App Service Plan for Web App."
}

variable "app_plan_web_primary_name" {
  type        = string
  default     = "app-plan-web-primary"
  description = "Name of the primary App Service Plan for Web App."
}

variable "app_plan_web_secondary_location" {
  type        = string
  default     = "westeurope"
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