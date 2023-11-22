resource "azurerm_availability_set" "avail-set" {
	name                         = "${var.availability_set_name}"
	resource_group_name          = "${var.resource_group_name}"
	location                     = "${var.location}"
	platform_fault_domain_count  = 2
	# platform_update_domain_count = 5
	managed                      = true
	tags						 = "${var.tags}"
}
