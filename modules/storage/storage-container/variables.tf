variable "storage_account_name" {
	type = string
}
variable "location" {
	type  = string
}

variable "resource_group_name" {
	type = string
}
variable "tags" {
  description = ""
  type        = map(any)
  default     = {}
}