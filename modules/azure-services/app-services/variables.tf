variable "app_serv_name" {
	type = string
}

variable "user_assigned_identity_id" {
	type = string
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which to create the virtual network peering."
}

variable "location" {
  type = string
}

variable "service_plan_id" {
	type = string
}

variable "app_insight_instrumentation_key" {
	type = string
}

variable "app_insight_connection_string" {
	type = string
}


variable "subnet_id" {
	type = string
	default  = ""
}

variable "app_service_alwayson" {
	type = bool
	default = true
}

variable "tags" {
  description = ""
  type        = map(string)
  default     = {}
}