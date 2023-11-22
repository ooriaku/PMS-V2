resource "azurerm_api_management" "apim-service" {
    name                = "${var.apim_name}"
    location            = var.location
    resource_group_name = var.resource_group_name
    
    publisher_name      = "${var.publisher_name}"
    publisher_email     = "${var.publisher_email}"
    sku_name            = "${var.sku_name}"                          #" "
    tags                = var.tags
    policy {
        xml_content = <<XML
        <policies>
            <inbound />
            <backend />
            <outbound />
            <on-error />
        </policies>
        XML
    }
}