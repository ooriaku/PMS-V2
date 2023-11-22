#Associate the NSG to the resource subnet
resource "azurerm_subnet_network_security_group_association" "nsg-snet-associate" {
	network_security_group_id	= var.network_security_group_id
	subnet_id					= var.subnet_id
}