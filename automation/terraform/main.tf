# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.49.0"
    }
  }

  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {}
}


module "permanent_resources" {
  source = "./modules/permanent"

  permanent_location              = var.permanent_location
  permanent_rg_name               = var.permanent_rg_name
  permanent_acr_name              = var.permanent_acr_name
  permanent_managed_identity_name = var.permanent_managed_identity_name
}


module "temporary_resources" {
  source = "./modules/temporary"

  temporary_location = var.temporary_location
  temporary_rg_name  = var.temporary_rg_name
}

/*
Excluding the module because this task is completed
module "cloudx_task_03" {
  source = "./modules/cloudx-task-03"

  app_plan_resource_group_name      = var.temporary_rg_name
  app_plan_web_primary_location     = var.app_plan_web_primary_location
  app_plan_web_primary_name         = var.app_plan_web_primary_name
  app_plan_web_secondary_location   = var.app_plan_web_secondary_location
  app_plan_web_secondary_name       = var.app_plan_web_secondary_name
  acr_name                          = var.permanent_acr_name
  acr_managed_identity_principal_id = module.permanent_resources.managed_identity_principal_id
  acr_managed_identity_client_id    = module.permanent_resources.managed_identity_client_id
  acr_managed_identity_id           = module.permanent_resources.managed_identity_id
  docker_image_tag                  = "build-14"
  app_plan_web_services_name        = var.app_plan_web_services_name
  app_plan_web_services_location    = var.app_plan_web_services_location
}

module "cloudx_task_04" {
  source = "./modules/cloudx-task-04"

  container_app_location       = var.temporary_location
  container_app_rg_name        = var.temporary_rg_name
  container_app_env_name       = var.container_app_env_name
  log_analytics_workspace_name = var.log_analytics_workspace_name
  container_app_name_prefix    = var.container_app_name_prefix
  acr_name                     = var.permanent_acr_name
  acr_managed_identity_id      = module.permanent_resources.managed_identity_id
  docker_image_tag             = "build-14"
}

module "cloudx_task_05" {
  source = "./modules/cloudx-task-05"

  app_plan_resource_group_name      = var.temporary_rg_name
  app_plan_web_primary_location     = var.app_plan_web_primary_location
  app_plan_web_primary_name         = var.app_plan_web_primary_name
  app_plan_web_secondary_location   = var.app_plan_web_secondary_location
  app_plan_web_secondary_name       = var.app_plan_web_secondary_name
  acr_name                          = var.permanent_acr_name
  acr_managed_identity_principal_id = module.permanent_resources.managed_identity_principal_id
  acr_managed_identity_client_id    = module.permanent_resources.managed_identity_client_id
  acr_managed_identity_id           = module.permanent_resources.managed_identity_id
  docker_image_tag                  = "build-23"
  app_plan_web_services_name        = var.app_plan_web_services_name
  app_plan_web_services_location    = var.app_plan_web_services_location
}

module "cloudx_task_06" {
  source = "./modules/cloudx-task-06"

  app_plan_resource_group_name      = var.temporary_rg_name
  app_plan_web_primary_location     = var.app_plan_web_primary_location
  app_plan_web_primary_name         = var.app_plan_web_primary_name
  app_plan_web_secondary_location   = var.app_plan_web_secondary_location
  app_plan_web_secondary_name       = var.app_plan_web_secondary_name
  acr_name                          = var.permanent_acr_name
  acr_managed_identity_principal_id = module.permanent_resources.managed_identity_principal_id
  acr_managed_identity_client_id    = module.permanent_resources.managed_identity_client_id
  acr_managed_identity_id           = module.permanent_resources.managed_identity_id
  docker_image_tag                  = "build-36"
  app_plan_web_services_name        = var.app_plan_web_services_name
  app_plan_web_services_location    = var.app_plan_web_services_location
}
*/

module "cloudx_task_07" {
  source = "./modules/cloudx-task-07"

  app_plan_resource_group_name      = var.temporary_rg_name
  app_plan_web_primary_location     = var.app_plan_web_primary_location
  app_plan_web_primary_name         = var.app_plan_web_primary_name
  app_plan_web_secondary_location   = var.app_plan_web_secondary_location
  app_plan_web_secondary_name       = var.app_plan_web_secondary_name
  acr_name                          = var.permanent_acr_name
  acr_managed_identity_principal_id = module.permanent_resources.managed_identity_principal_id
  acr_managed_identity_client_id    = module.permanent_resources.managed_identity_client_id
  acr_managed_identity_id           = module.permanent_resources.managed_identity_id
  docker_image_tag                  = "build-36"
  app_plan_web_services_name        = var.app_plan_web_services_name
  app_plan_web_services_location    = var.app_plan_web_services_location
  postgres_flex                     = var.postgres_flex
}