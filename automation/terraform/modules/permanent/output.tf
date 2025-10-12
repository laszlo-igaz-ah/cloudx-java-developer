output "permanent_rg_id" {
  description = "ARN of the bucket"
  value       = azurerm_resource_group.rg_permanent.id
}

output "acr_id" {
  description = "ID of the Azure Container Registry"
  value       = azurerm_container_registry.permanent_acr.id
}

output "managed_identity_principal_id" {
  description = "ID of the User Assigned Managed Identity"
  value       = azurerm_user_assigned_identity.cloudx_managed_identity.principal_id
}

output "managed_identity_client_id" {
  description = "ID of the User Assigned Managed Identity"
  value       = azurerm_user_assigned_identity.cloudx_managed_identity.client_id
}

output "managed_identity_id" {
  description = "ID of the User Assigned Managed Identity"
  value       = azurerm_user_assigned_identity.cloudx_managed_identity.id
}