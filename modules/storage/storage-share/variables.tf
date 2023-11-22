variable "storage_account_name" {
	type = string
}
variable "location" {
	type  = string
}
variable "resource_group_name" {
	type = string
}

variable "share_storage_account_name" {
	type = string
}

variable "quota" {
	type- = number
	default = 100
}

variable "is_fslogic" {
	type = bool
	default = false
}

variable "principal_id" {
	type = string
	default = ""
}

variable "role_definition_id" {
	type = string
	default = ""
}

variable "tags" {
  description = ""
  type        = map(any)
  default     = {}
}