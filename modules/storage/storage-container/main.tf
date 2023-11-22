resource "azurerm_storage_account" "storage-account" {
	name                     = var.storage_account_name
	resource_group_name      = var.resource_group_name
	location                 = var.location
	account_tier						= "Standard"
	account_kind						= "StorageV2"
	account_replication_type			= "LRS"
	enable_https_traffic_only			= true
	access_tier							= "Hot"
	allow_nested_items_to_be_public		= true
	tags								= var.tags

	network_rules {
		default_action        = "Deny"
		bypass                = [ "AzureServices" ]
	}
}

resource "azurerm_storage_container" "container" {
	name                  = "${var.storage_account_name}-container"
	storage_account_name  = azurerm_storage_account.storage-account.name
	container_access_type = "blob"
}
