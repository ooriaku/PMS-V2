output "location" {
  description = "The Azure region"
  value       = azurerm_resource_group.sig.location
}

output "compute_gallery" {
  description = "Azure Compute Gallery"
  value       = azurerm_shared_image_gallery.sig.name
}