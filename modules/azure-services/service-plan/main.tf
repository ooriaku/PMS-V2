resource "azurerm_service_plan" "service-plan" {
	
	name                = var.app_service_hosting_plan_name
	os_type             = var.os_type							# WindowsContainer, Windows or Linux
	resource_group_name = var.resource_group_name
	location            = var.location
	sku_name            = var.app_service_hosting_plan_sku
	worker_count        = var.app_service_workers

	tags		        = merge(tomap({"type" = "web"}), var.tags)
}
