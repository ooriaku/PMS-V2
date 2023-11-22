variable "la_name" {
  type = string
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which to create the virtual network peering."
}

variable "location" {
  type = string
}

variable "retention_in_days" {
    type = number
    description = "The retention period for data stored in the Log Analytics Workspace"
    default = 30
}


variable "sku" {
	type	=	string
	default	=	"PerGB2018"
}

variable "solutions" {
    type = list(object({ name = string, publisher = string, product = string }))
    description = "Solutions to install in to the log analytics workspace."
    default = []
}

variable "tags" {
  description = ""
  type        = map(string)
  default     = {}
}