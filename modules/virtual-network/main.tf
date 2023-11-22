resource "azurerm_virtual_network" "vnet" {
  resource_group_name = "${var.resource_group_name}"
  location            = "${var.location}"
  name                = "${var.vnet_name}"
  address_space       = "${var.address_space}"
  dns_servers         = "${var.dns_servers}"
  tags		          = merge(tomap({"type" = "network"}), var.tags)
}

resource "azurerm_subnet" "subnet" {
  for_each                                      = var.subnet_names
  
  name                                          = each.value.subnet_name
  virtual_network_name                          = azurerm_virtual_network.vnet.name
  resource_group_name                           = var.resource_group_name
  address_prefixes                              = each.value.address_prefixes
  #service_endpoints                            = each.value.service_endpoints

  dynamic "delegation" {
      for_each = { for delegate in var.delegations : delegate.name => delegate 
                    if each.value.snet_delegation == "appservice" }
      content {
        name = "delegation-appService"
        service_delegation {
        name    = "Microsoft.Web/serverFarms"
          actions = [
            "Microsoft.Network/virtualNetworks/subnets/action",
          ]
        }
      }
  }
  dynamic "delegation" {
      for_each = { for delegate in var.delegations : delegate.name => delegate 
                    if each.value.snet_delegation == "mysql" }
      content {
        name = "delegation-database"
        service_delegation {
        name    = "Microsoft.DBforMySQL/flexibleServers"
          actions = [
            "Microsoft.Network/virtualNetworks/subnets/join/action",
          ]
        }
      }
  }
  dynamic "delegation" {
    for_each = { for delegate in var.delegations : delegate.name => delegate 
                    if each.value.snet_delegation == "aci" }
      content {
      name = "aciDelegation"
      service_delegation {
        name    = "Microsoft.ContainerInstance/containerGroups"
        actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
      }
    }
  }
  dynamic "delegation" {
    for_each = { for delegate in var.delegations : delegate.name => delegate 
                    if each.value.snet_delegation == "postgresql" }
      content {
      name = "fs"
      service_delegation {
        name    = "Microsoft.DBforPostgreSQL/flexibleServers"
        actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
      }
    }
  }
}