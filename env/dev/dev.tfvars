    subscription_id	    = ""
    environment         = "dev"
    location            = "uksouth"  
    

	vm_admin_username   = "netb.admin"
	vm_admin_password   = "Password1234!"


    tags = {
        environment = "dev"
        owner       = "Owen Oriaku"
        costCenter  = ""
        dr          = "no"
        approver    = "Owen Oriaku"
        managedBy   = "Owen Oriaku"
    }

   

    attr = {
        mgmt_rg_name        = "rg-pms-mgmt-dev"
        kv_rg_name          = "rg-pms-kv-dev"
        app_rg_name         = "rg-pms-app-dev"
        db_rg_name          = "rg-pms-db-dev"
        
        agw = {
            agw_name                = "agw-pms-app-gateway-dev"
            agw_pip_name            = "pip-pms-app-gateway-dev"
            agw_sku_name            = ""
            agw_sku_tier            = ""
            agw_sku_capacity        = 1
            min_autoscale_capacity  = 0
            max_autoscale_capacity  = 1

            gateway_ip_config_name  = ""

        }

        sql = {
            sql_db_name             = "pmsdb"
            sql_logical_server_name = "sql-pms-data-dev"
            sql_audit_storage_name  = "stgpmsauditlogs"
            log_retention_days      = 30
            enable_threat_detection_policy  = true
            enable_auditing_policy          = true  
            email_addresses_for_alerts  = ["test01@test.com", "test02@test.com"]
            locations                   = ["uksouth"]
            db_rg_names                 = ["rg-pms-db-dev"]
            sku_name                    = "GP_S_Gen5_2"

        }
        adminweb ={
            web_app_name    = "web-pms-admin-dev"

        }

        publicweb ={
            web_app_name    = "web-pms-public-dev"

        }
        
        app01 = {
            vm_app_avail_set_name   = "avs-app01-dev"
            vm_app_count            = 2
            vm_app_name             = "vmapp01d"
            vm_app_size             = "Standard_D2s_v3"
           

            vm_db_sku               = "sqldev-gen2"       #enterprise-gen2, sqldev-gen2, standard-gen2, web-gen2
            vm_db_count             = 2
            vm_db_name              = "vmdata01d" 
            vm_db_size              = "Standard_D2s_v3"
        
        }
        
        
        networks = {
            network_rg_name     = "rg-pms-network-hub"
            vnet_name           = "vnet-pms-dev"
            agw_snet_name       = "snet-pms-agw-dev"
            app_snet_name       = "snet-pms-app-dev"
            int_snet_name       = "snet-pms-int-dev"
            data_snet_name      = "snet-pms-db-dev"
            endpoint_snet_name  = "snet-pms-endpoint-dev"
        }        

        appinsights = {
            ai_name =   "ai-pms-insights-dev"
        }

        appservices = {
            host_plan01_name     =  "asp-pms-01-dev"
            host_plan_sku        =  "P1v2"
            host_plan_os_type    =  "Windows"
            app_service_workers  =  1
        }
        
        keyvault = {
			kv_name                         = "kv-pms-keyvault-dev"
			sku                             = "standard"
			admin_certificate_permissions = ["Create",
											  "Delete",
											  "DeleteIssuers",
											  "Get",
											  "GetIssuers",
											  "Import",
											  "List",
											  "ListIssuers",
											  "ManageContacts",
											  "ManageIssuers",
											  "Purge",
											  "SetIssuers",
											  "Update"
											]
			admin_key_permissions         = ["Backup",
											  "Create",
											  "Decrypt",
											  "Delete",
											  "Encrypt",
											  "Get",
											  "Import",
											  "List",
											  "Purge",
											  "Recover",
											  "Restore",
											  "Sign",
											  "UnwrapKey",
											  "Update",
											  "Verify",
											  "WrapKey"
											]
			admin_secret_permissions      = [ "Backup",
											  "Delete",
											  "Get",
											  "List",
											  "Purge",
											  "Restore",
											  "Restore",
											  "Set"
											] 
			managed_identity_name               = "mi-pms-dev"
			managed_identity_secret_permissions = ["Get"]
		}
      
    }
    
    

