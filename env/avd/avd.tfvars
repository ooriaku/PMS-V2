subscription_id	    = ""
environment         = "Production"
location            = "uksouth"

vm_admin_username   = "netb.admin"
vm_admin_password   = "Password1234!"


tags = {
	environment = "AVD"
	owner       = "Owen Oriaku"
	costCenter  = ""
	dr          = "no"
	approver    = "Owen Oriaku"
	managedBy   = "Owen Oriaku"
}
 attr = {
        mgmt_rg_name        = "rg-pms-mgmt-avd"
        sig_rg_name         = "rg-pms-sig-shared-avd"
        host_rg_name        = "rg-pms-host-avd"    

       storage = {
            storage_name                = "stgavdfslogic"
            share_storage_account_name  = "fslogic"
            quota                       = 100
       }
       host = {
            virtual_machine_name    =   "vmpmsavd"
            vm_host_size            =   "Standard_DS2_v2"
            vm_host_count           =   2
       }
        
       gallery = {
            sig_name                    = ""
            share_storage_account_name  = ""
            quota                       = 100
       }
        
        networks = {
            network_rg_name     = "rg-pms-network-hub"
            vnet_name           = "vnet-pms-avd"
            avd01_snet_name     = "snet-pms-avd01-prd"           
        }        

     
      
    }