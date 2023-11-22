resource "azurerm_storage_account" "storage-account" {
	name                     = var.storage_account_name
	resource_group_name      = var.resource_group_name
	location                 = var.location
	account_tier             = var.account_tier
	account_replication_type = var.account_replication_type
	tags					 = var.tags
  
  
	network_rules {
		default_action       = "Allow" #Deny
		bypass               = [ "AzureServices", "Logging","Metrics"]
	}
}