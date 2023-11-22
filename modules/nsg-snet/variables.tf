variable "subnet_id" {
  type        = string
  description = "The full Azure resource ID of the subnet."
}

variable "network_security_group_id" {
  type        = string
  description = "The name of the resource group in which to create the virtual network peering."
}