﻿resource "azurerm_data_lake_store" "data-lake-store" {
  name                = "${var.prefix}-dls"
  resource_group_name = "${azurerm_resource_group.example.name}"
  location            = "${azurerm_resource_group.example.location}"
  tier                = "Consumption"
}

resource "azurerm_data_lake_store_firewall_rule" "data-lake-store-fw" {
  name                = "${var.prefix}-dls-fwrule"
  account_name        = "${azurerm_data_lake_store.example.name}"
  resource_group_name = "${azurerm_resource_group.example.name}"
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}

resource "azurerm_data_lake_analytics_account" "data-lake-la" {
  name                       = "${var.prefix}-dla"
  resource_group_name        = "${azurerm_resource_group.example.name}"
  location                   = "${azurerm_resource_group.example.location}"
  tier                       = "Consumption"
  default_store_account_name = "${azurerm_data_lake_store.example.name}"
}

resource "azurerm_data_lake_analytics_firewall_rule" "data-lake-analytic-fw" {
  name                = "${var.prefix}-dlafwrule"
  account_name        = "${azurerm_data_lake_analytics_account.example.name}"
  resource_group_name = "${azurerm_resource_group.example.name}"
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}