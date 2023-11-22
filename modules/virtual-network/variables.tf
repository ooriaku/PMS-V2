variable "resource_group_name" {
  description = "The name of the resource group we want to use" 
}

variable "location" {
  description = "The location/region where we are crrating the resource"  
}

variable "tags" {
  description = "The tags to associate the resource we are creating"
  type        = map(string)
  default     = {}
}

# Everything below is for the module

variable "vnet_name" {
  description = "Name of the vnet to create" 
}

variable "address_space" {
  description = "The address space that is used by the virtual network." 
}

variable "subnet_names" {
  description = "name of the virtual network"
}

variable "delegations" {
  type = map(object({
    name             = string
    service_delegation = object({
      name    = string
      actions = list(string)
    })
  }))
  default = {
    delegation-appService = {
      name = "delegation-appService"
      service_delegation = {
        name    = "Microsoft.Web/serverFarms"
        actions = [
          "Microsoft.Network/virtualNetworks/subnets/action",
        ]
      }
    }
  }
}

variable "dns_servers" {
  description = "The DNS servers to be used with vNet."
  default     = []
}