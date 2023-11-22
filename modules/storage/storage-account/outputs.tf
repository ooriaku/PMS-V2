output "storage_id" {
  description = ""
  value       = azurerm_storage_account.storage-account.id
}

output "storage_primary_blob_endpoint" {
  description = ""
  value       = azurerm_storage_account.storage-account.primary_blob_endpoint
}

output "storage_primary_access_key" {
  description	= ""
  value			= azurerm_storage_account.storage-account.primary_access_key
  sensitive		= true
}



