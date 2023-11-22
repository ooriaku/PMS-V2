
variable "attr" {
}

variable "location" {
  description = ""
  default     = ""
}
variable "environment" {
  description = "" 
}

variable "vm_admin_username" {
	type = string
}
variable "subscription_id" {
	type = string
}

variable "vm_admin_password" {
	type = string
	default = ""
}


variable "tags" {
  description = ""
  type        = map(any)
  default     = {}
}

