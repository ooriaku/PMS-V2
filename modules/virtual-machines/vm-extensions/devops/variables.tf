
variable "agent_count" {
	type	= number
	default = 1
}

variable "vsts_account" {
	description	=	"This is the name of the Azure DevOps Services organisation"
	type		= string
}

variable "pool" {
	type = string
}

variable "pat" {
	type = string
}

variable "virtual_machine_id" {
	type = string
}



variable "agent_name" {
	type = string
}

variable "url" {
	description = "The url to the storage account for the artefacts"
	type = string
}

variable "tags" {
  description = "The tags to associate the resource we are creating"
  type        = map(string)
  default     = {}
} 