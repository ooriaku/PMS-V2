output "pe_id" {
  description = "The id of the newly created private endpoint"
  value       = azurerm_private_endpoint.private-endpoint.id
}
