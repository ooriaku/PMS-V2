variable "virtual_machine_name" {
	type = string
}

variable "virtual_machine_id" {
	type = string
}

variable "tags" {
  description = "The tags to associate the resource we are creating"
  type        = map(any)
  default     = {}
}