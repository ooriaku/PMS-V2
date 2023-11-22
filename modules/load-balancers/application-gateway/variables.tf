


variable "user_assigned_identity_id" {
	type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "cert_name" {
}

variable "subnet_id" {
}

variable "public_ip_address_id" {
}

variable "application_gateway_name" {

}

variable "sku_name" {

}

variable "tier" {

}

variable "capacity" {

}

variable "zones" {
  description = "A collection of availability zones to spread the Application Gateway over."
  type        = list(string)
  default     = [] #["1", "2", "3"]
}


variable "min_autoscale_capacity" {

}

variable "max_autoscale_capacity" {

}

variable "gateway_ip_configuration_name" {

}
variable "frontend_port_name" {

}

variable "frontend_port_1" {

}

variable "probe_host_name" {

}

variable "backend_address_pool_name" {

}

variable "backend_ip_addresss" {

}

variable "frontend_ip_configuration_name" {
   
}
variable "http_setting_name" {

}
variable "https_setting_name" {

}
variable "listener_name" {

}
variable "request_routing_rule_name" {

}
variable "redirect_configuration_name" {

}

variable "tags" {
  description = ""
  type        = map(any)
  default     = {}
}