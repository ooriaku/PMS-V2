

# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

output "login_server" {
  value = "${azurerm_container_registry.acr.login_server}"
}

output "acr_id" {
    description = "ACR Resource ID"
    value = azurerm_container_registry.acr.id
}

output "acr_name" {
    value = azurerm_container_registry.acr.name
}