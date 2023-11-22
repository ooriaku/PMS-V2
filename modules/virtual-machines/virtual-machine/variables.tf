variable "nic_name" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "ipconfig_name" {
 type = string
}

variable "availability_set_id" {
	type	=	string
	default = ""
}
variable "subnet_id" {
  description = "The full Azure resource ID of the remote virtual network."
}

variable "private_ip_address_allocation" {
  description = "The full Azure resource ID of the remote virtual network."
}

variable "private_ip_address" {
	description = "The private ip address for the virtual machine"
	default = null
}

variable "public_ip_address_id" {
  type    = string
  default = null
}

variable "virtual_machine_name" {
  description = "The full Azure resource ID of the remote virtual network."
}

variable "vm_size" {
  description = "The full Azure resource ID of the remote virtual network."
}

variable "delete_os_disk_on_termination" {
  description = "The full Azure resource ID of the remote virtual network."
}

variable "delete_data_disks_on_termination" {
  description = "The full Azure resource ID of the remote virtual network."
}

variable "publisher" {
  description = "The full Azure resource ID of the remote virtual network."
}

variable "offer" {
  description = "The full Azure resource ID of the remote virtual network."
}

variable "sku" {
  description = "The full Azure resource ID of the remote virtual network."
}

variable "storage_version" {
  description = "The full Azure resource ID of the remote virtual network."
}

variable "os_disk_name" {
  description = "The full Azure resource ID of the remote virtual network."
}

variable "caching" {
  description = "The full Azure resource ID of the remote virtual network."
}

variable "create_option" {
  description = "The full Azure resource ID of the remote virtual network."
}

variable "managed_disk_type" {
  description = "The full Azure resource ID of the remote virtual network."
}


variable "admin_username" {
  type        = string
  description = "The administrator username of the SQL logical server."
  default     = "azureadmin"
}

variable "admin_password" {
  type        = string
  description = "The administrator password of the vm server."
  sensitive   = true
  default     = null
}

variable "provision_vm_agent" {
  description = "The full Azure resource ID of the remote virtual network."
}

variable "tags" {
  description = "The tags to associate the resource we are creating"
  type        = map(string)
  default     = {}
}