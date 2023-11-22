﻿resource "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.sku				#"Premium or Standard"
  admin_enabled       = var.admin_enabled	#false	

  tags                 = var.tags 
}