variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which to create the virtual network peering."
}

variable "location" {
  type = string
}

variable "os_type" {
  type = string
  default = "Windows"
  validation {
    condition     = contains(["Windows", "Linux", "WindowsContainer"], var.os_type)
    error_message = "Valid values for var: os_type are (Windows, Linux, WindowsContainer)."
  } 
}

variable "tags" {
  description = ""
  type        = map(string)
  default     = {}
}

variable "app_service_hosting_plan_name" {
  description = "App service plan name"
  default     = "wp-appsvc-plan"
}

variable "app_service_workers" {
    description = "App service Workers"
    type = number
    default = 1
}

variable "app_service_hosting_plan_sku" {
  description = "App service SKU"
  default     = "P1v2"
   validation {
    condition     = contains(["P1v2"], var.app_service_hosting_plan_sku)
    error_message = "Valid values for var: app_service_hosting_plan_sku are (P1v2)."
  }
}
