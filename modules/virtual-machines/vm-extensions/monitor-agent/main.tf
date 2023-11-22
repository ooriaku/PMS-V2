resource "azurerm_virtual_machine_extension" "vm-extensions" {  
	name                       = "${var.virtual_machine_name}"
	virtual_machine_id         = "${var.virtual_machine_id}"
	publisher                  = "Microsoft.Azure.Monitor"
	type                       = "AzureMonitorWindowsAgent"
	type_handler_version       = "1.10"
	auto_upgrade_minor_version = "true" 

	tags                       = merge(var.tags, tomap({ "firstapply" = timestamp() }))

	lifecycle {
		ignore_changes = [tags]
	}
}