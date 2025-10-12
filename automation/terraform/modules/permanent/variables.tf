variable "permanent_rg_name" {
  type        = string
  description = "Location of the permanent resources."
}

variable "permanent_location" {
  type        = string
  description = "Location of the permanent resources."
}

variable "permanent_acr_name" {
  type        = string
  description = "Name of the Container Registry for CloudX Course"
}

variable "permanent_managed_identity_name" {
  type        = string
  description = "Name of the User Assigned Managed Identity."
}