
output "temporary_rg_id" {
  description = "Resource Group ID for temporary resources"
  value       = azurerm_resource_group.rg_temporary.id
}