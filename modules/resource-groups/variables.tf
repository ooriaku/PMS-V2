variable "resource_group_name" {
  description = "The name of the resource group we want to use" 
}

variable "location" {
  description = "Location in which to deploy resources"
  type        = string
}


variable "tags" {
  description = "A mapping of tags which should be assigned to all resources"
  type        = map(string)
  default     = {}
}