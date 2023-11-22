resource "azurerm_storage_account" "storage-account" {
	name                     = var.storage_account_name
	resource_group_name      = var.resource_group_name
	location                 = var.location

	account_tier             = "Standard"
	account_kind             = "StorageV2"
	account_replication_type = "LRS"
	is_hns_enabled           = true
    tags					 = var.tags
}

data "azurerm_client_config" "current" {}

resource "azurerm_role_assignment" "storage-account-role-assignment" {
	scope                = azurerm_storage_account.storage-account.id
	role_definition_name = "Storage Blob Data Contributor"
	principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_storage_data_lake_gen2_filesystem" "file-system" {
  name               = "${var.storage_account_name}-filesystem"
  storage_account_id = azurerm_storage_account.storage-account.id
  ace {
    type        = "user"
    permissions = "rwx"
  }
  ace {
    type        = "user"
    id          = azurerm_user_assigned_identity.storage-account-role-assignment.principal_id
    permissions = "--x"
  }
  ace {
    type        = "group"
    permissions = "r-x"
  }
  ace {
    type        = "mask"
    permissions = "r-x"
  }
  ace {
    type        = "other"
    permissions = "---"
  }
  depends_on = [
    azurerm_role_assignment.storage-account-role-assignment
  ]
}

resource "azurerm_storage_data_lake_gen2_path" "path" {
  storage_account_id = azurerm_storage_account.storage-account.id
  filesystem_name    = azurerm_storage_data_lake_gen2_filesystem.file-system.name
  path               = "testpath"
  resource           = "directory"
  ace {
    type        = "user"
    permissions = "r-x"
  }
  ace {
    type        = "user"
    id          = azurerm_user_assigned_identity.storage-account-role-assignment.principal_id
    permissions = "r-x"
  }
  ace {
    type        = "group"
    permissions = "-wx"
  }
  ace {
    type        = "mask"
    permissions = "--x"
  }
  ace {
    type        = "other"
    permissions = "--x"
  }
  ace {
    scope       = "default"
    type        = "user"
    permissions = "r-x"
  }
  ace {
    scope       = "default"
    type        = "user"
    id          = azurerm_user_assigned_identity.storage-account-role-assignment.principal_id
    permissions = "r-x"
  }
  ace {
    scope       = "default"
    type        = "group"
    permissions = "-wx"
  }
  ace {
    scope       = "default"
    type        = "mask"
    permissions = "--x"
  }
  ace {
    scope       = "default"
    type        = "other"
    permissions = "--x"
  }
}