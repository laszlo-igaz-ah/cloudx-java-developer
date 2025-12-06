variable "key_vault" {
  type = object({
    name = string
  })
  description = "Options for the Key Vault"
}

variable "servicebus" {
  type = object({
    namespace_name = string
    queue_name     = string
  })
  description = "Options for the Postgres Flex Server"
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
}

variable "app_function" {
  type = object({
    name                 = string
    storage_account_name = string
  })
  description = "Options for the Postgres Flex Server"
}


variable "app_services" {
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
  description = "Options for the Postgres Flex Server"
}

variable "managed_identity_id" {
  type        = string
  description = "Client ID of the User Assigned Managed Identity which has all the necessary roles we've added so far."
}

variable "managed_identity_client_id" {
  type        = string
  description = "Client ID of the User Assigned Managed Identity which has all the necessary roles we've added so far."
}

variable "managed_identity_principal_id" {
  type        = string
  description = "Principal ID of the User Assigned Managed Identity which has all the necessary roles we've added so far."
}
