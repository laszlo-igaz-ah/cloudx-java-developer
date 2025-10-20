output "container_app_services_fqdn_list" {
  description = "FQDN list of container apps for services."
  value       = [
    for bd in azurerm_container_app.ca_cloudx_services : bd.latest_revision_fqdn
  ]
}

output "container_app_webapp_fqdn" {
  description = "FQDN of container app for webapp."
  value       = azurerm_container_app.ca_cloudx_webapp.latest_revision_fqdn
}