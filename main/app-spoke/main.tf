terraform {

  #required_version = ">=0.12"
  required_version = ">=0.14.9"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}


data "azurerm_virtual_network" "vnet" {
  name                = lookup(var.attr["networks"], "vnet_name","")
  resource_group_name = lookup(var.attr["networks"], "network_rg_name","")
}

data "azurerm_subnet" "endpoint-snet" {
  name                 = lookup(var.attr["networks"], "endpoint_snet_name","")
  virtual_network_name = lookup(var.attr["networks"], "vnet_name","")
  resource_group_name  = lookup(var.attr["networks"], "network_rg_name","")
}

data "azurerm_subnet" "integration-snet" {
  name                 = lookup(var.attr["networks"], "int_snet_name","")
  virtual_network_name = lookup(var.attr["networks"], "vnet_name","")
  resource_group_name  = lookup(var.attr["networks"], "network_rg_name","")
}


data "azurerm_subnet" "agw-snet" {
  name                 = lookup(var.attr["networks"], "agw_snet_name","")
  virtual_network_name = lookup(var.attr["networks"], "vnet_name","")
  resource_group_name  = lookup(var.attr["networks"], "network_rg_name","")
}


data "azurerm_subnet" "app-snet" {
  name                 = lookup(var.attr["networks"], "app_snet_name","")
  virtual_network_name = lookup(var.attr["networks"], "vnet_name","")
  resource_group_name  = lookup(var.attr["networks"], "network_rg_name","")
}

data "azurerm_subnet" "data-snet" {
  name                 = lookup(var.attr["networks"], "data_snet_name","")
  virtual_network_name = lookup(var.attr["networks"], "vnet_name","")
  resource_group_name  = lookup(var.attr["networks"], "network_rg_name","")
}

data "azurerm_private_dns_zone" "private-dns-zone-webapp" {
  name                  = "privatelink.azurewebsites.net"  
  resource_group_name   = lookup(var.attr["networks"], "network_rg_name","")
}

data "azurerm_private_dns_zone" "private-dns-zone-kv" {
  name                  = "privatelink.vaultcore.azure.net"  
  resource_group_name   = lookup(var.attr["networks"], "network_rg_name","")
}

data "azurerm_private_dns_zone" "private-dns-zone-azure-sql" {
  name                  = "privatelink.database.windows.net"  
  resource_group_name   = lookup(var.attr["networks"], "network_rg_name","")
}


module "mgmt-rg" {
      source              = "../../modules/resource-groups"

      location            = "${var.location}"
      resource_group_name = lookup(var.attr, "mgmt_rg_name","") 
      tags                = "${var.tags}"
}

module "app-rg" {
      source              = "../../modules/resource-groups"
      location            = "${var.location}"
      resource_group_name = lookup(var.attr, "app_rg_name","") 
      tags                = "${var.tags}"
}

module "db-rg" {
      source              = "../../modules/resource-groups"
      location            = "${var.location}"
      resource_group_name = lookup(var.attr, "db_rg_name","") 
      tags                = "${var.tags}"
}


# publicip Module is used to create Public IP Address
module "agw-pip" {
      source              = "../../modules/public-ip-address"

      # Used for application Gateway 
      public_ip_name      = lookup(var.attr["agw"], "agw_pip_name","")
      resource_group_name = module.mgmt-rg.name
      location            = "${var.location}"
      allocation_method   = "Static"
      sku                 = "Standard"
      tags		          = merge(tomap({"type" = "network"}), var.tags)

      depends_on          = [module.mgmt-rg]
}



module "application-insights" {
  source              = "../../modules/application-insight"

  ai_name             =  lookup(var.attr["appinsights"], "ai_name","")
  location            = "${var.location}"
  resource_group_name = module.mgmt-rg.name
  tags		          = merge(tomap({"type" = "application"}), var.tags)
  depends_on          = [module.mgmt-rg]
}

# keyvault Module is used to create Azure Key Vault.
module "key-vault" {
    source                          = "../../modules/key-vault"

    resource_group_name             = module.mgmt-rg.name
    location                        = "${var.location}"   

    # To use Key vault - Choose a unique name 
    key_vault_name                  = lookup(var.attr["keyvault"], "kv_name","")
    sku_name                        = lookup(var.attr["keyvault"], "sku","")
    admin_certificate_permissions   = lookup(var.attr["keyvault"], "admin_certificate_permissions","")
    admin_key_permissions           = lookup(var.attr["keyvault"], "admin_key_permissions","")
    admin_secret_permissions        = lookup(var.attr["keyvault"], "admin_secret_permissions","") 
    managed_identity_name           = lookup(var.attr["keyvault"], "managed_identity_name","") 
    managed_identity_secret_permissions = lookup(var.attr["keyvault"], "managed_identity_secret_permissions","")
    tags		                    = merge(tomap({"type" = "security"}), var.tags)

    depends_on                      = [module.mgmt-rg.name]
}


module "vm-app01-avail-set" {
     source                           = "../../modules/virtual-machines/vm-availability-set"
     availability_set_name            = "${lookup(var.attr["app01"], "vm_app_avail_set_name", "")}-app"
     location                         = "${var.location}"
     resource_group_name              = module.app-rg.name
     tags		                      = merge(tomap({"type" = "application"}), var.tags)
}

# vm-windows Module is used to create App 01 Virtual Machines
module "vm-app01" {
      source                           = "../../modules/virtual-machines/virtual-machine"
      count                            =  lookup(var.attr["app01"], "vm_app_count", 1)

      availability_set_id              = module.vm-app01-avail-set.avail_set_id
      virtual_machine_name             = "${lookup(var.attr["app01"], "vm_app_name","")}${count.index + 1}"  
      nic_name                         = "nic-pms-${lookup(var.attr["app01"], "vm_app_name","")}${count.index + 1}"
      location                         = "${var.location}"
      resource_group_name              = module.app-rg.name
      ipconfig_name                    = "ipconfig1"
      subnet_id                        = data.azurerm_subnet.app-snet.id
      private_ip_address_allocation    = "Dynamic"
      #private_ip_address               = lookup(var.hub["management"], "vm_jumpbox01_private_ip","")
      vm_size                          = lookup(var.attr["app01"], "vm_app_size","")
      tags		                       = merge(tomap({"type" = "application"}), var.tags)
      
      # Uncomment this line to delete the OS disk automatically when deleting the VM
      delete_os_disk_on_termination    = true

      # Uncomment this line to delete the data disks automatically when deleting the VM
      delete_data_disks_on_termination = true

      publisher                        = "MicrosoftWindowsServer"
      offer                            = "WindowsServer"
      sku                              = "2019-Datacenter"
      storage_version                  = "latest"

      os_disk_name                     = "${lookup(var.attr["app01"], "vm_app_name","")}${count.index + 1}-os-disk-01"
      caching                          = "ReadWrite"
      create_option                    = "FromImage"
      managed_disk_type                = "Premium_LRS"

      admin_username                   = "${var.vm_admin_username}"
      admin_password                   = "${var.vm_admin_password}"
        
      provision_vm_agent               = true   
      depends_on                       = [module.app-rg, module.vm-app01-avail-set]
}

module "vm-app01-db-avail-set" {
     source                           = "../../modules/virtual-machines/vm-availability-set"
     availability_set_name            = "${lookup(var.attr["app01"], "vm_app_avail_set_name", "")}-db"
     location                         = "${var.location}"
     resource_group_name              = module.db-rg.name
     tags		                      = merge(tomap({"type" = "database"}), var.tags)
}

# vm-windows Module is used to create App01 Database 01 Virtual Machines
module "vm-app01-db-01" {
      source                           = "../../modules/virtual-machines/virtual-machine"
      count                            =  lookup(var.attr["app01"], "vm_app_count", 1)


      virtual_machine_name             = "${lookup(var.attr["app01"], "vm_db_name","")}${count.index + 1}"  
      nic_name                         = "nic-pms-${lookup(var.attr["app01"], "vm_db_name","")}${count.index + 1}"
      location                         = "${var.location}"
      resource_group_name              = module.db-rg.name
      ipconfig_name                    = "ipconfig1"
      subnet_id                        = data.azurerm_subnet.data-snet.id
      private_ip_address_allocation    = "Dynamic"
      #private_ip_address               = lookup(var.hub["management"], "vm_jumpbox01_private_ip","")
      vm_size                          = lookup(var.attr["app01"], "vm_db_size","")
      tags		                       = merge(tomap({"type" = "application"}), var.tags)
      
      # Uncomment this line to delete the OS disk automatically when deleting the VM
      delete_os_disk_on_termination    = true

      # Uncomment this line to delete the data disks automatically when deleting the VM
      delete_data_disks_on_termination = true

      publisher                        = "MicrosoftSQLServer"
      offer                            = "sql2022-ws2022"
      sku                              = "${lookup(var.attr["app01"], "vm_db_sku","sqldev-gen2")}"    #enterprise-gen2, sqldev-gen2, standard-gen2, web-gen2
      storage_version                  = "latest"

      os_disk_name                     = "${lookup(var.attr["app01"], "vm_db_name","")}${count.index + 1}-os-disk-01"
      caching                          = "ReadWrite"
      create_option                    = "FromImage"
      managed_disk_type                = "Premium_LRS"

      admin_username                   = "${var.vm_admin_username}"
      admin_password                   = "${var.vm_admin_password}"
      provision_vm_agent               = true      

      depends_on                       = [module.db-rg, module.vm-app01-db-avail-set]
}

module "vm-app01-windows-features-ext" {
    source                  = "../../modules/virtual-machines/vm-extensions/windows-features"
    count                   =  lookup(var.attr["app01"], "vm_app_count", 1)

    virtual_machine_name    = module.vm-app01[count.index].vm_name  
    virtual_machine_id      = module.vm-app01[count.index].vm_id    
    tags		            = merge(tomap({"type" = "monitor"}), var.tags)
    
    depends_on              = [module.vm-app01]
}

module "vm-app01-monitor-agent-ext" {
    source                  = "../../modules/virtual-machines/vm-extensions/monitor-agent"
    count                   =  lookup(var.attr["app01"], "vm_app_count", 1)

    virtual_machine_name    = module.vm-app01[count.index].vm_name  
    virtual_machine_id      = module.vm-app01[count.index].vm_id    
    tags		            = merge(tomap({"type" = "monitor"}), var.tags)
    
    depends_on              = [module.vm-app01]
}

module "web-service-plan" {
    source                            = "../../modules/azure-services/service-plan"

    app_service_hosting_plan_name     = "${lookup(var.attr["appservices"], "host_plan01_name","")}"  
    os_type                           = "Windows"
    location                          = "${var.location}"
    resource_group_name               =  module.app-rg.name
    app_service_hosting_plan_sku      = "${lookup(var.attr["appservices"], "host_plan_sku","")}"
    app_service_workers               = "${lookup(var.attr["appservices"], "app_service_workers", 1)}"

    tags		                      = merge(tomap({"type" = "web"}), var.tags)

    depends_on                       = [module.app-rg]
}

module "public-webapp" {
    source                           = "../../modules/azure-services/app-services"
    app_serv_name                    = "${lookup(var.attr["publicweb"], "web_app_name","")}"
    location                         = "${var.location}"
    resource_group_name              =  module.app-rg.name
    service_plan_id                  =  module.web-service-plan.service_plan_id
    subnet_id                        =  data.azurerm_subnet.integration-snet.id  
    app_insight_connection_string    =  module.application-insights.app_connection_string
    app_insight_instrumentation_key  =  module.application-insights.instrumentation_key
    user_assigned_identity_id        = module.key-vault.user_assigned_identity_id 

    depends_on                       = [module.application-insights, module.app-rg, module.web-service-plan]
}

module "admin-webapp" {
    source                           = "../../modules/azure-services/app-services"
    app_serv_name                    = "${lookup(var.attr["adminweb"], "web_app_name","")}"
    location                         = "${var.location}"
    resource_group_name              =  module.app-rg.name
    service_plan_id                  =  module.web-service-plan.service_plan_id
    app_insight_connection_string    =  module.application-insights.app_connection_string
    app_insight_instrumentation_key  =  module.application-insights.instrumentation_key
    user_assigned_identity_id        =  module.key-vault.user_assigned_identity_id
    
    tags                             = "${var.tags}"
    depends_on                       = [module.application-insights, module.app-rg, module.web-service-plan]
}


module "sql-audit-store" {
    count                       = "${lookup(var.attr["sql"], "enable_threat_detection_policy", false)}" || "${lookup(var.attr["sql"], "enable_auditing_policy", false)}" ? 1 : 0
    source                      = "../../modules/storage/storage-account"

    storage_account_name        = lookup(var.attr["sql"], "sql_audit_storage_name","")
    resource_group_name         = module.db-rg.name
    location                    = "${var.location}"
    account_replication_type    = "GRS"
    tags                        = "${var.tags}"
   
    depends_on                  = [module.db-rg]
}



module "azure-sql" {
    source                           = "../../modules/azure-sql/sql-server"

    locations                        =  lookup(var.attr["sql"], "locations",[])
    server_name                      = "${lookup(var.attr["sql"], "sql_logical_server_name","")}"
    resource_group_name              =  module.db-rg.name   
    admin_username                   = "${var.vm_admin_username}"
    admin_password                   = "${var.vm_admin_password}"
    storage_account_id               = module.sql-audit-store[0].storage_id

    storage_primary_access_key       = module.sql-audit-store[0].storage_primary_access_key
    storage_primary_blob_endpoint    = module.sql-audit-store[0].storage_primary_blob_endpoint
    user_assigned_identity_id        = module.key-vault.user_assigned_identity_id    
    user_assigned_principal_id       = module.key-vault.user_assigned_principal_id
    
   
   
   
    log_retention_days                  = "${lookup(var.attr["sql"], "log_retention_days",30)}" 
    sku_name                            = "${lookup(var.attr["sql"], "sku_name","S0")}" 
    db_name                             = "${lookup(var.attr["sql"], "sql_db_name","")}"
    email_addresses_for_alerts          = "${lookup(var.attr["sql"], "email_addresses_for_alerts",[])}"
    tags		                        = merge(tomap({"type" = "data"}), var.tags)

    depends_on                          = [module.db-rg, module.sql-audit-store,  module.key-vault]
}

module "vnet-dns-zone-azure-sql-link" {
    source                            = "../../modules/vnet-dns-zone-link"

    resource_group_name               = data.azurerm_private_dns_zone.private-dns-zone-azure-sql.resource_group_name
    vnet_dns_zone_link_name           = "${module.azure-sql.server_name[0]}-vnetlink"
    private_dns_zone_name             = data.azurerm_private_dns_zone.private-dns-zone-azure-sql.name
    virtual_network_id                = data.azurerm_virtual_network.vnet.id
    registration_enabled              = "false"
    tags		                        = merge(tomap({"type" = "network"}), var.tags)

    depends_on                       = [module.azure-sql]
}


module "vnet-dns-zone-webapp-link" {
    source                            = "../../modules/vnet-dns-zone-link"

    resource_group_name               = data.azurerm_private_dns_zone.private-dns-zone-webapp.resource_group_name
    vnet_dns_zone_link_name           = "${module.admin-webapp.web_app_name}-vnetlink"
    private_dns_zone_name             = data.azurerm_private_dns_zone.private-dns-zone-webapp.name
    virtual_network_id                = data.azurerm_virtual_network.vnet.id
    registration_enabled              = "false"
    tags		                      = merge(tomap({"type" = "network"}), var.tags)

    depends_on                       = [module.admin-webapp]
}


module "vnet-dns-zone-kv-link" {
    source                            = "../../modules/vnet-dns-zone-link"

    resource_group_name               = data.azurerm_private_dns_zone.private-dns-zone-kv.resource_group_name
    vnet_dns_zone_link_name           = "${module.key-vault.kv_name}-vnetlink"
    private_dns_zone_name             = data.azurerm_private_dns_zone.private-dns-zone-kv.name
    virtual_network_id                = data.azurerm_virtual_network.vnet.id
    registration_enabled              = "false"
    tags		                      = merge(tomap({"type" = "network"}), var.tags)

    depends_on                        = [module.key-vault]
}

module "kv-pvt-endpoint" {
    source                           = "../../modules/private-endpoint"

    pvt_endpoint_name                = "pvt-${module.key-vault.kv_name}"
    resource_group_name              = module.mgmt-rg.name
    location                         = "${var.location}"
    subnet_id                        = data.azurerm_subnet.endpoint-snet.id 
    private_service_connection_name  = "pvt-${module.key-vault.kv_name}-conn"
    is_manual_connection             = false
    private_connection_resource_id   = module.key-vault.kv_id
    subresource_name                 = "vault"
    tags		                     = merge(tomap({"type" = "network"}), var.tags)

    depends_on = [ module.vnet-dns-zone-kv-link, module.key-vault, module.mgmt-rg.name]
}

module "adminweb-pvt-endpoint" {
    source                           = "../../modules/private-endpoint"

    pvt_endpoint_name                = "pvt-${module.admin-webapp.web_app_name}"
    resource_group_name              = module.mgmt-rg.name
    location                         = "${var.location}"
    subnet_id                        = data.azurerm_subnet.endpoint-snet.id 
    private_service_connection_name  = "pvt-${module.admin-webapp.web_app_name}-conn"
    is_manual_connection             = false
    private_connection_resource_id   = module.admin-webapp.web_app_id
    subresource_name                 = "sites"
    tags		                     = merge(tomap({"type" = "network"}), var.tags)

    depends_on = [module.vnet-dns-zone-webapp-link, module.admin-webapp, module.mgmt-rg.name]
}

module "azure-sql-pvt-endpoint" {
    source                           = "../../modules/private-endpoint"

    pvt_endpoint_name                = "pvt-${module.azure-sql.server_name[0]}"
    resource_group_name              = module.mgmt-rg.name
    location                         = "${var.location}"
    subnet_id                        = data.azurerm_subnet.endpoint-snet.id 
    private_service_connection_name  = "pvt-${module.azure-sql.server_name[0]}-conn"
    is_manual_connection             = false
    private_connection_resource_id   = module.azure-sql.server_id[0]
    subresource_name                 = "sqlServer"
    tags		                     = merge(tomap({"type" = "network"}), var.tags)

    depends_on = [ module.vnet-dns-zone-azure-sql-link, module.azure-sql, module.mgmt-rg.name]
}


