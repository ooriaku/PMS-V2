# Create AVD workspace
resource "azurerm_virtual_desktop_workspace" "avd-workspace" {
    name                    = "${var.workspace_name}"
    resource_group_name     = var.resource_group_name
    location                = var.location
    friendly_name           = "${var.prefix} Workspace"
    description             = "${var.prefix} Workspace"
}

resource "azurerm_virtual_desktop_host_pool" "avd-host-pool" {
   
    name                     = "${var.host_pool}"
    resource_group_name      = var.resource_group_name
    location                 = var.location
    friendly_name            = var.host_pool
    validate_environment     = true
    type                     = "Pooled"
    custom_rdp_properties    = "audiocapturemode:i:1;audiomode:i:0;"
    maximum_sessions_allowed = 16
    load_balancer_type       = "BreadthFirst" #[BreadthFirst DepthFirst]
}


resource "azurerm_virtual_desktop_host_pool_registration_info" "registration-info" {
    hostpool_id     = azurerm_virtual_desktop_host_pool.avd-host-pool.id
    expiration_date = var.rfc3339
}

# Create AVD DAG
resource "azurerm_virtual_desktop_application_group" "dag" {
    resource_group_name = var.resource_group_name
    host_pool_id        = azurerm_virtual_desktop_host_pool.avd-host-pool.id
    location            = var.location
    type                = "Desktop"
    name                = "${var.prefix}-dag"
    friendly_name       = "Desktop AppGroup"
    description         = "AVD application group"

    depends_on          = [azurerm_virtual_desktop_host_pool.avd-host-pool, azurerm_virtual_desktop_workspace.avd-workspace]
}

# Associate Workspace and DAG
resource "azurerm_virtual_desktop_workspace_application_group_association" "ws-dag" {
    application_group_id = azurerm_virtual_desktop_application_group.dag.id
    workspace_id         = azurerm_virtual_desktop_workspace.avd-workspace.id
}