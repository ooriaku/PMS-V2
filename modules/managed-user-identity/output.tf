output "user_assigned_identity_id" {
    value = azurerm_user_assigned_identity.mi.id
}

output "user_assigned_principal_id" {
    value = azurerm_user_assigned_identity.mi.principal_id
}

output "user_assigned_name" {
    value = azurerm_user_assigned_identity.mi.name
}