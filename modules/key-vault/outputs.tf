output "kv_id" {
    description = "Key vault Resource ID"
    value = azurerm_key_vault.kv.id
}

output "kv_name" {
    description = "Key vault Resource name"
    value = azurerm_key_vault.kv.name
}

output "user_assigned_identity_id" {
    value = azurerm_user_assigned_identity.mi.id
}

output "user_assigned_principal_id" {
    value = azurerm_user_assigned_identity.mi.principal_id
}

output "user_assigned_name" {
    value = azurerm_user_assigned_identity.mi.name
}