﻿variable "apim_name" {
  description = "The prefix which should be used for all resources in this example"
}

variable "location" {
  description   = "The Azure Region in which all resources in this example should be created."
  type          =   string
}

variable "resource_group_name" {
  description   = ""
  type          =   string
}

variable "publisher_name" {
  description   = ""
  type          =   string
}

variable "publisher_email" {
  description    = ""
   type          =   string
}

variable "sku_name" {
  description = ""
  type          =   string
  default       =   "Developer_1"
}

variable "open_api_spec_content_format" {
    description = "The format of the content from which the API Definition should be imported. Possible values are: openapi, openapi+json, openapi+json-link, openapi-link, swagger-json, swagger-link-json, wadl-link-json, wadl-xml, wsdl and wsdl-link."
}

variable "open_api_spec_content_value" {
    description = "The Content from which the API Definition should be imported. When a content_format of *-link-* is specified this must be a URL, otherwise this must be defined inline."
}

variable "tags" {
  description = ""
  type        = map(string)
  default     = {}
}