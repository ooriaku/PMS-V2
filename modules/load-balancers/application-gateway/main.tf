
resource "azurerm_application_gateway" "agw" {
    name                = var.application_gateway_name
    resource_group_name = var.resource_group_name
    location            = var.location
    tags                = "${var.tags}"
    enable_http2        = true
    zones               = var.zones



    sku {
        name     = var.sku_name
        tier     = var.tier
        capacity = var.capacity
    }

    autoscale_configuration {
        min_capacity = var.min_autoscale_capacity
        max_capacity = var.max_autoscale_capacity
    }
     identity {
        type         = "UserAssigned"
        identity_ids = [var.user_assigned_identity_id]
    }

    gateway_ip_configuration {
        name      = var.gateway_ip_configuration_name 
        subnet_id = var.subnet_id
    }

    frontend_port {
        name = var.frontend_port_name
        port = 80  
    }

    frontend_ip_configuration {
        name                 = var.frontend_ip_configuration_name
        public_ip_address_id = var.public_ip_address_id
    }

    backend_address_pool {
        name = var.backend_address_pool_name
        ip_addresses = var.backend_ip_addresss 
    }

    backend_http_settings {
        name                  = var.https_setting_name
        cookie_based_affinity = "Disabled"
        path                  = "/"
        port                  = 443
        protocol              = "Https"
        request_timeout       = 60
        probe_name            = "health-probe"
    }

    probe {
        name                = "health-probe"
        host                = var.probe_host_name
        interval            = 30
        timeout             = 30
        unhealthy_threshold = 3
        protocol            = "Https"
        port                = 443
        path                = "/"
    }
    http_listener {
        name                           = var.listener_name
        frontend_ip_configuration_name = var.frontend_ip_configuration_name
        frontend_port_name             = var.frontend_port_name
        protocol                       = "Https"
        ssl_certificate_name           = "app_listener"
    }

  

    ssl_certificate {
        name = "app_listener"
        key_vault_secret_id = trimsuffix(data.azurerm_key_vault_secret.certificate_secret.id, "${data.azurerm_key_vault_secret.certificate_secret.version}")

    }

    request_routing_rule {
        name                       = var.request_routing_rule_name
        rule_type                  = "Basic"
        http_listener_name         = var.listener_name
        backend_address_pool_name  = var.backend_address_pool_name
        backend_http_settings_name = var.https_setting_name
        priority                   = "100"
    }
    waf_configuration {
        enabled               = true
        firewall_mode         = "Prevention"
        rule_set_type         = "OWASP"
        rule_set_version      = "3.1"
        request_body_check    = true
        max_request_body_size = 1048576
    }
}