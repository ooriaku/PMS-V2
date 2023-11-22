variable "server_name" {
	type = string
}
variable "locations" {
	type  = list(string)
}

variable "resource_group_name" {
  description = "Azure resource group name"
}

variable "resource_group_names" {
  description = "Azure resource resource group names"
  default = []
}


variable "admin_username" {
  type        = string
  description = "The administrator username of the SQL logical server."
  default     = "netb.admin"
}

variable "admin_password" {
  type        = string
  description = "The administrator password of the vm server."
  sensitive   = true
  default     = null
}

variable "db_name" {
	type = string
}

variable "sku_name" {
	type = string
	default = "S0"
}

variable "user_assigned_identity_id" {
	type = string
}

variable "user_assigned_principal_id" {
	type = string
}

variable "start_ip_address" {
	type = string
	default = "0.0.0.0"
}

variable "end_ip_address" {
	type = string
	default = "0.0.0.0"
}

variable "tags" {
  description = ""
  type        = map(any)
  default     = {}
}

variable "enable_auditing_policy" {
    description = "Audit policy for SQL server and database"
    default     = false
}

variable "enable_threat_detection_policy" {
    description = ""
    default     = false 
}

variable "storage_account_id" {
	type = string
}

variable "storage_primary_access_key" {
	type = string
}

variable "storage_primary_blob_endpoint" {
	type = string
}
variable "log_retention_days" {
	type = number
	default = 0
}

variable "email_addresses_for_alerts" {
	type        = list(string)
	default     = []
}