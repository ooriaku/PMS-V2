variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which to create the virtual network peering."
}

variable "private_dns_zone_name" {
  type        = string
  description = "The name of the resource group in which to create the virtual network peering."
}

variable "tags" {
  description = "The tags to associate the resource we are creating"
  type        = map(any)
  default     = {}
}