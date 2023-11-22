
locals {   
    if_threat_detection_policy_enabled  = var.enable_threat_detection_policy ? [{}] : []
    if_extended_auditing_policy_enabled = var.enable_auditing_policy ? [{}] : []
}

data "azurerm_subscription" "primary" {
}

data "azurerm_client_config" "example" {
}


#SA Password should be changed once VM is stood up and configured.
resource "random_password" "admin-password" {  
    length      = 20
    special     = true
    min_numeric = 1
    min_upper   = 1
    min_lower   = 1
    min_special = 1
}


resource "azurerm_mssql_server" "sql" {  
    count                        = "${length(var.locations)}"
    
    name                         = "${var.server_name}-${count.index}"
    resource_group_name          = var.resource_group_name
    location                     = "${element(var.locations, count.index)}"
    version                      = "12.0"
    administrator_login          = var.admin_username
    administrator_login_password = var.admin_password != null ? var.admin_password : random_password.admin-password.result

    

    # azuread_administrator {
    #     login_username = var.user_assigned_identity_name
    #     object_id      = var.user_assigned_identity_principal_id
    # }

    identity {
        type         = "UserAssigned"
        identity_ids = [var.user_assigned_identity_id]
    }
    primary_user_assigned_identity_id  = var.user_assigned_identity_id  
    tags						       = merge(tomap({"type" = "data"}), var.tags)
}

resource "azurerm_mssql_server_extended_auditing_policy" "sql-audit-policy" {
    count                                   = "${length(var.locations)}"

    server_id                               = "${element(azurerm_mssql_server.sql.*.id, count.index)}"
    storage_endpoint                        = var.storage_primary_blob_endpoint
    storage_account_access_key              = var.storage_primary_access_key
    storage_account_access_key_is_secondary = false
    retention_in_days                       = var.log_retention_days

    depends_on        = [azurerm_role_assignment.role-assignment]
}

resource "azurerm_mssql_firewall_rule" "sql-fw-rule" { 
    count               = "${length(var.locations)}"

    name                = "AllowAzureServices"    
    server_id           = "${element(azurerm_mssql_server.sql.*.id, count.index)}"
    start_ip_address    = var.start_ip_address
    end_ip_address      = var.end_ip_address
}



resource "azurerm_mssql_database" "sql-db" {  
    name                             = var.db_name    
    server_id                        = "${azurerm_mssql_server.sql.*.id[0]}"
    collation                        = "SQL_Latin1_General_CP1_CI_AS"
    create_mode                      = "Default"
    zone_redundant                   = true
    #read_scale                       = true
    sku_name                         = var.sku_name
    max_size_gb                      = 200   
    auto_pause_delay_in_minutes      = 60
    min_capacity                     = 0.5

    tags						     = merge(tomap({"type" = "data"}), var.tags)

    dynamic "threat_detection_policy" {
        for_each = local.if_threat_detection_policy_enabled
        content {
            state                      = "Enabled"
            storage_account_access_key = var.storage_primary_access_key
            storage_endpoint           = var.storage_primary_blob_endpoint
            retention_days             = var.log_retention_days
            email_addresses            = var.email_addresses_for_alerts
        }
    }
}

resource "azurerm_mssql_database_extended_auditing_policy" "sql-db-audit-policy" {
    database_id            = azurerm_mssql_database.sql-db.id
    log_monitoring_enabled = true
}

resource "azurerm_mssql_failover_group" "sql-failover-group" { 
    count               = length(var.locations) > 1 ?  1 : 0

    name                = "sqlpoc-failover-group"    
    server_id           = "${azurerm_mssql_server.sql.*.id[0]}"
    databases           = [
                            azurerm_mssql_database.sql-db.id
    ]
    partner_server {
        id = azurerm_mssql_server.sql.*.id[1]       
    }

    read_write_endpoint_failover_policy {
        mode          = "Automatic"
        grace_minutes = 60
    }
}

resource "azurerm_role_assignment" "role-assignment" {
    scope                = var.storage_account_id
    role_definition_name = "Storage Blob Data Contributor"   
    principal_id         =  var.user_assigned_principal_id   
}
