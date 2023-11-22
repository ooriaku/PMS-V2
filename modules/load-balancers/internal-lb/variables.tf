variable "lb_name" {
	type = string
}
variable "location" {
	type = string
}
variable "resource_group_name" {
	type = string
}
variable "port" {
	type = string
}
variable "frontend_port" {
	type = string
}
variable "backend_port" {
	type = string
}
variable "enabled" {
  type    = bool
  default = true
}