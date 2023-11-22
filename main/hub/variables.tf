variable "location" {
  description = "" 
}

variable "vm_admin_username" {
	type = string
}

variable "vm_admin_password" {
	type = string
	default = ""
}

variable "permissions" {
	type = string
	default = "racwdlup"
}

variable "expiry_hours" {
	type = number
	default = 24
}


variable "hub" {	
}

variable "dev" {	
}

variable "qa" {	
}

variable "prd" {	
}

variable "avd" {	
}

variable "tags" {
  description = ""
  type        = map(string)
  default     = {}
}




