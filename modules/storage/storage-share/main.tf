resource "azurerm_storage_account" "storage-account" {
	name							= "${var.storage_account_name}"
	resource_group_name				= "${var.resource_group_name}"
	location						= "${var.location}"
	account_tier					= "Premium"			
	account_kind					= "FileStorage"
	account_replication_type		= "LRS"
	tags							= var.tags

}

resource "azurerm_storage_share" "share" {
	name                  = "${var.share_storage_account_name}-share"
	storage_account_name  = azurerm_storage_account.storage-account.name
	quota                 = "${var.quota}"
}

resource "azurerm_role_assignment" "af_role" {
	count				= var.is_fslogic == true ? 1 : 0

	scope				= azurerm_storage_account.storage-account.id
	role_definition_id	= var.role_definition_id
	principal_id		= var.principal_id
}