
output "app_plan_web_primary_id" {
  description = "ID of the primary App Service Plan for Web App"
  value       = azurerm_service_plan.app_plan_web_primary.id
}
