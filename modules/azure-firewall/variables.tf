variable "location" {
	type	=	string
}

variable "firewall_name" {
	type	=	string
}

variable "sku_name" {
	type	=	string
	default =	"AZFW_VNet"
}

variable "sku_tier" {
	type	=	string
	default =	"Standard"
}



variable "resource_group_name" {
	type	=	string
}

variable "subnet_id" {
	type = string
}

variable "public_ip_address_id" {
	type = string
}