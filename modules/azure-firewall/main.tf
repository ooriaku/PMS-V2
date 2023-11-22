# Azure Firewall
resource "azurerm_firewall" "fw" {
  name                = var.firewall_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku_name            = var.sku_name                #"AZFW_VNet"
  sku_tier            = var.sku_tier                #"Standard"

  ip_configuration {
    name                 = "configuration"
    subnet_id            = var.subnet_id
    public_ip_address_id = var.public_ip_address_id
  }
}

# Azure Firewall Application Rule
resource "azurerm_firewall_application_rule_collection" "fw-app-rule" {
  name                = "appRc1"
  azure_firewall_name = azurerm_firewall.fw.name
  resource_group_name = var.resource_group_name
  priority            = 101
  action              = "Allow"

  rule {
    name = "appRule1"

    source_addresses = [
      "10.0.0.0/24",
    ]

    target_fqdns = [
      "www.microsoft.com",
    ]

    protocol {
      port = "80"
      type = "Http"
    }
  }
}

# Azure Firewall Network Rule
resource "azurerm_firewall_network_rule_collection" "fw-network-rule" {
  name                = "testcollection"
  azure_firewall_name = azurerm_firewall.fw.name
  resource_group_name = var.resource_group_name
  priority            = 200
  action              = "Allow"

  rule {
    name = "netRc1"

    source_addresses = [
      "10.0.0.0/24",
    ]

    destination_ports = [
      "8000-8999",
    ]

    destination_addresses = [
      "*",
    ]

    protocols = [
      "TCP",
    ]
  }
}
