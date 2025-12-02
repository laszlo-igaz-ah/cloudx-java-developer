variable "postgres_flex" {
  type = object({
    name           = string
    resource_group = string
    location       = string
    version        = string
    login          = string
    password       = string
  })
  description = "Options for the Postgres Flex Server"
}

variable "app_plan_web_services_location" {
  type        = string
  description = "Location of the App Service Plan for Services."
}

variable "app_plan_web_services_name" {
  type        = string
  description = "Name of the App Service Plan for Services."
}

variable "app_plan_resource_group_name" {
  type        = string
  description = "Name of the Resource Group where the App Plan belongs to."
}

variable "app_plan_web_primary_location" {
  type        = string
  description = "Location of the primary App Service Plan for Web App."
}

variable "app_plan_web_primary_name" {
  type        = string
  description = "Name of the primary App Service Plan for Web App."
}

variable "app_plan_web_secondary_location" {
  type        = string
  description = "Location of the secondary App Service Plan for Web App."
}

variable "app_plan_web_secondary_name" {
  type        = string
  description = "Name of the secondary App Service Plan for Web App."
}

variable "acr_name" {
  type        = string
  description = "Name of the Container Registry for CloudX Course"
}

variable "acr_managed_identity_principal_id" {
  type        = string
  description = "Principal ID of the ACR User Assigned Managed Identity."
}

variable "acr_managed_identity_client_id" {
  type        = string
  description = "Client ID of the ACR User Assigned Managed Identity."
}

variable "acr_managed_identity_id" {
  type        = string
  description = "ID of the ACR User Assigned Managed Identity."
}

variable "app_web_primary_name" {
  type        = string
  default     = "app-web-primary"
  description = "Name of the primary Web App."
}

variable "app_web_secondary_name" {
  type        = string
  default     = "app-web-secondary"
  description = "Name of the secondary Web App."
}

variable "docker_image_tag" {
  type        = string
  default     = "build-31"
  description = "The common image tag of the used Docker images."
}

variable "app_web_docker_image_name" {
  type        = string
  default     = "petstoreapp"
  description = "Docker image name for the Web App."
}

