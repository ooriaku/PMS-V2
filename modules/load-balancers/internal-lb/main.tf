# Create a load balancer
resource "azurerm_internal_load_balancer" "ilb" {
    count               = var.enabled ? 1 : 0

    name                = "${var.lb_name}"
    location            = "${var.location}"
    resource_group_name = "${var.resource_group_name}"
    sku                 = "Standard"

    frontend_ip_configuration {
        name                 = "${var.lb_name}-internal"
        subnet_id            = "${var.subnet_id}"        
    }

    backend_address_pool {
        name = "${var.lb_name}-backend"
    }

    dynamic "backend_address_pool" {
        #for_each = 
    }

}
