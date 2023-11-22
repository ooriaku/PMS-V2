output "nic_id" {
  description = "The id of the newly created nsg"
  value       = azurerm_network_interface.nic.id
}

output "vm_id" {
  description = "The id of the newly created vm"
  value       = azurerm_virtual_machine.vm.id
}

output "vm_name" {
  description = "The name of the newly created vm"
  value       = azurerm_virtual_machine.vm.name
}