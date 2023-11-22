

resource "azurerm_windows_web_app" "web" {
	name                = "${var.app_serv_name}"
	resource_group_name = "${var.resource_group_name}"
	location            = "${var.location}"
	tags		        = merge(tomap({"type" = "web"}), var.tags)

	service_plan_id				= var.service_plan_id 
	client_affinity_enabled		= false
	https_only					= true
	
	identity {
        type         = "UserAssigned"
        identity_ids = [var.user_assigned_identity_id]
    }

	site_config {		
		ftps_state				= "AllAllowed"
		always_on				= var.app_service_alwayson
		vnet_route_all_enabled	= true
		minimum_tls_version		= "1.2"
		use_32_bit_worker		= true
		http2_enabled           = true
     
		application_stack {
			current_stack  = "dotnet"
			dotnet_version = "v6.0"
		}
	}
	app_settings = {
		"APPINSIGHTS_INSTRUMENTATIONKEY": "${var.app_insight_connection_string}",
		"APPLICATIONINSIGHTS_CONNECTION_STRING": "${var.app_insight_connection_string}",

		"WEBSITE_DNS_SERVER":  var.subnet_id == "" ? null : "168.63.129.16",
		"WEBSITE_VNET_ROUTE_ALL": var.subnet_id == "" ? null : "1"
	}
}

resource "azurerm_app_service_virtual_network_swift_connection" "vnet-integration" {
	count			= var.subnet_id == "" ? 0 : 1
	app_service_id	= azurerm_windows_web_app.web.id
	subnet_id		= var.subnet_id
}