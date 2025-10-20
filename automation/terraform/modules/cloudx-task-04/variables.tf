variable "container_app_location" {
  type        = string
  description = "The location of the Container App Environment."
}

variable "container_app_rg_name" {
  type        = string
  description = "The name of the Resource Group for the Container App Environment."
}

variable "container_app_env_name" {
  type        = string
  description = "The name of the Container App Environment."
}

variable "log_analytics_workspace_name" {
  type        = string
  description = "The name of the Log Analytics Workspace."
}

variable "container_app_name_prefix" {
  type        = string
  description = "Prefix for the Container App names."
}

variable "acr_managed_identity_id" {
  type        = string
  description = "ID of the ACR User Assigned Managed Identity."
}

variable "acr_name" {
  type        = string
  description = "Container Registry name where images come from."
}

variable "docker_image_tag" {
  type        = string
  description = "Image tag to deploy from Container Registry."
}