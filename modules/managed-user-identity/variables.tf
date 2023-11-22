variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which to create the virtual network peering."
}

variable "location" {
  type        = string
  description = "The full Azure resource ID of the remote virtual network."
}

variable "managed_identity_name" {
  type        = string
  description = "The full Azure resource ID of the remote virtual network."
}
