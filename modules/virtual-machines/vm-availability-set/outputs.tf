output "avail_set_id" {
  description = "The id of the newly created vm"
  value       = azurerm_availability_set.avail-set.id
}