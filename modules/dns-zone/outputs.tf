output "private_dns_zone_id" {
    description = "Private DNS Zone Id"
    value = azurerm_private_dns_zone.private-dns-zone.id
}

output "private_dns_zone_name" {
    description = "Private DNS Zone Id"
    value = azurerm_private_dns_zone.private-dns-zone.name
}