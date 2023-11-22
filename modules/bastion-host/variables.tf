variable "bastion_host_name" {
  type        = string
  description = "The name of the resource group in which to create the virtual network peering."
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which to create the virtual network peering."
}

variable "location" {
  type        = string
  description = "The full Azure resource ID of the remote virtual network."
}

variable "sku" {
  type        = string
  description = "The sku for the Bastion Host."
}


variable "ipconfig_name" {
  type        = string
  description = "The full Azure resource ID of the remote virtual network."
}

variable "subnet_id" {
  type        = string
  description = "The full Azure resource ID of the remote virtual network."
}

variable "public_ip_address_id" {
  type        = string
  description = "The full Azure resource ID of the remote virtual network."
}

variable "create" {
  description = "Creation Flag"
  type        = bool
  default     = false
}

variable "tags" {
  description = "The tags to associate the resource we are creating"
  type        =  map(any)
  default     = {}
}
