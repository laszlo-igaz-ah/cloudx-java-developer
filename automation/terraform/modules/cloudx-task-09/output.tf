output "servicebus_namespace_id" {
  description = "ID of the Azure Service Bus Namespace"
  value       = azurerm_servicebus_namespace.servicebus_namespace.id
}

output "servicebus_queue_id" {
  description = "ID of the Service Bus Queue"
  value       = azurerm_servicebus_queue.orders_queue.id
}

output "servicebus_connection_string" {
  description = "Connection string for the Service Bus Namespace"
  value       = azurerm_servicebus_namespace_authorization_rule.servicebus_auth_rule.primary_connection_string
  sensitive   = true
}

output "key_vault_secret_id" {
  description = "ID of the Key Vault secret containing the Service Bus connection string"
  value       = azurerm_key_vault_secret.servicebus_connection_string.id
}

