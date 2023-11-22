    tags = {
		environment = "prd (hub)"
		owner       = "Owen Oriaku"
		costCenter  = "1111"
		approver    = "Owen Oriaku"
		managedBy   = "Owen"
	}
   
	location            = "uksouth"
	location_code		= "uks"

	vm_admin_username   = "netb.admin"
	vm_admin_password   = "Password1234!"
	
	
	hub = {
		mgmt_rg_name        =   "rg-pms-mgmt-hub"
		mon_rg_name         =   "rg-pms-mon-hub"
		network_rg_name     =   "rg-pms-network-hub"
	   
		
		devops_rg_name      =   "rg-pms-devops-hub"

		vnet_name           =   "vnet-pms-hub"
		address_space       =   "10.200.0.0/22"  
		 
		gateway = {
			name                = "gw-pms-gateway"
			subnet_name         = "GatewaySubnet"
			address_prefixes    = "10.200.0.0/28"
			route_table_name    = ""
			snet_delegation     = ""
			service_endpoints   = ""
			private_endpoint_network_policies_enabled = false
		},
		firewall = {
			name                = "fw-pms-firewall"
			subnet_name         = "AzureFirewallSubnet"
			address_prefixes    = "10.200.0.16/28"
			route_table_name    = ""
			snet_delegation     = ""
			service_endpoints   = ""
			private_endpoint_network_policies_enabled = false
		},
		dnsIn = {
			name                = ""
			subnet_name         = "snet-pms-dns-001-hub"
			address_prefixes    = "10.200.0.32/28"
			route_table_name    = ""
			snet_delegation     = ""
			service_endpoints   = ""
			private_endpoint_network_policies_enabled = false
		},
		dnsOut = {
			name                = ""
			subnet_name         = "snet-pms-dns-002-hub"
			address_prefixes    = "10.200.0.48/28"
			route_table_name    = ""
			snet_delegation     = ""
			service_endpoints   = ""
			private_endpoint_network_policies_enabled = false
		},
		bastion = {
			bastion_name        = "bst-pms-bastion"
			bastion_sku         = "Standard"
			subnet_name         = "AzureBastionSubnet"
			address_prefixes    = "10.200.0.64/28"
			route_table_name    = ""
			snet_delegation     = ""
			service_endpoints   = ""
			private_endpoint_network_policies_enabled = false
		},

		devOps = {            
			subnet_name         = "snet-pms-devops-hub"
			address_prefixes    = "10.200.0.80/28"
			route_table_name    = ""
			snet_delegation     = ""
			service_endpoints   = ""
			private_endpoint_network_policies_enabled = false

			acr_name            = "acrpmsregistry"
			acr_sku             = "Premium"
			acr_admin_enabled   = false

			vm_build_name       = "vmbuildagent01p"
			#vm_build_private_ip= "10.200.0.84"
			vm_build_size       = "Standard_B2ms" #"Standard_D2s_v3"           
			url                 = "https://stscriptstore001.blob.core.windows.net/artefacts/scripts/Install-DevOpsAgent.ps1"
			pat                 = "6pvmie5jnsbyemj6lp6uy2e2jujgp7d4okgxamv6sc6i3y3bp2wq"
			pool                = "winpool"            
			vsts_account        = "munacroftglobal"
			
			artefact_rg_name        = "rg-pms-terraform"
			artefact_sa_name        = "stscriptstore001"
			artefact_sa_container   = "artefacts"
			sas_start               = "2023-03-21T00:00:00Z"
			sas_expiry              = "2024-03-21T00:00:00Z"
		},

	   
		aci = {
			subnet_name         = "snet-aci-hub"
			address_prefixes    = "10.200.0.96/28"
			route_table_name    = ""
			snet_delegation     = "aci"
			service_endpoints   = ""
			private_endpoint_network_policies_enabled = false
		},
		management = {            
			subnet_name         = "snet-pms-mgmt-hub"
			address_prefixes    = "10.200.0.112/28"
			route_table_name    = ""
			snet_delegation     = ""
			service_endpoints   = ""
			private_endpoint_network_policies_enabled = false


			vm_jumpbox01_name       = "vmjumpbox01p"
			vm_jumpbox01_private_ip = "10.200.0.117"
			vm_jumpbox01_size       = "Standard_D2s_v3"            
		},
		endpoints = {            
			subnet_name         = "snet-pms-endpoint-hub"
			address_prefixes    = "10.200.0.128/28"
			route_table_name    = ""
			snet_delegation     = ""
			service_endpoints   = ""
			private_endpoint_network_policies_enabled = true
		},

		keyvault = {
			kv_name                         = "kv-pms-keyvault-hub"
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
			managed_identity_name               = "mi-hub-keyvault"
			managed_identity_secret_permissions = ["Get"]
		},
	 
		loganalytics = {
			name                =   "log-pms-workspace"
			diag_storage_name   =   "stgdiags01"
		}
	}

	dev = {
		resource_group_name =   "rg-pms-dev"
		vnet_name           =   "vnet-pms-dev"
		address_space       =   "10.200.4.0/22"  
		 
		agw = {
			name                = "agw-pms-gateway-dev"
			subnet_name         = "snet-pms-agw-dev"
			address_prefixes    = "10.200.4.0/28"
			route_table_name    = ""
			snet_delegation     = ""
			service_endpoints   = []
		},
		app = {            
			subnet_name         = "snet-pms-app-dev"
			address_prefixes    = "10.200.4.16/28"
			route_table_name    = ""
			snet_delegation     = ""
			service_endpoints   = []
		},
		int = {            
			subnet_name         = "snet-pms-int-dev"
			address_prefixes    = "10.200.4.32/28"
			route_table_name    = ""
			snet_delegation     = "appservice"
			service_endpoints   = []
		},
		data = {            
			subnet_name         = "snet-pms-db-dev"
			address_prefixes    = "10.200.4.48/28"
			route_table_name    = ""
			snet_delegation     = ""
			service_endpoints   = ["Microsoft.Storage", "Microsoft.Sql", "Microsoft.KeyVault"]
		},
		apim = {            
			subnet_name         = "snet-pms-apim-dev"
			address_prefixes    = "10.200.4.64/28"
			route_table_name    = ""
			snet_delegation     = ""
			service_endpoints   = ""
		},
		akscluster = {            
			subnet_name         = "snet-pms-aks-001-dev"
			address_prefixes    = "10.200.5.0/24"
			route_table_name    = ""
			snet_delegation     = ""
			service_endpoints   = ""
		},
		aksservices = {            
			subnet_name         = "snet-pms-aks-002-dev"
			address_prefixes    = "10.200.6.0/24"
			route_table_name    = ""
			snet_delegation     = ""
			service_endpoints   = ""
		},
		endpoints = {            
			subnet_name         = "snet-pms-endpoint-dev"
			address_prefixes    = "10.200.7.0/24"
			route_table_name    = ""
			snet_delegation     = ""
			service_endpoints   = ""
			private_endpoint_network_policies_enabled = true
		}
	}

	qa = {
		resource_group_name =   "rg-pms-qa"
		vnet_name           =   "vnet-pms-qa"
		address_space       =   "10.200.8.0/22"  
		 
		agw = {
			name                = "agw-pms-gateway-qa"
			subnet_name         = "snet-agw-qa"
			address_prefixes    = "10.200.8.0/28"
			route_table_name    = ""
			snet_delegation     = ""
			service_endpoints   = ""
		},
		app = {            
			subnet_name         = "snet-pms-app-qa"
			address_prefixes    = "10.200.8.16/28"
			route_table_name    = ""
			snet_delegation     = ""
			service_endpoints   = ""
		},
		web = {            
			subnet_name         = "snet-pms-web-qa"
			address_prefixes    = "10.200.8.32/28"
			route_table_name    = ""
			snet_delegation     = "appservice"
			service_endpoints   = ""
		},
		data = {            
			subnet_name         = "snet-pms-db-qa"
			address_prefixes    = "10.200.8.48/28"
			route_table_name    = ""
			snet_delegation     = ""
			service_endpoints   = ""

		},
		apim = {            
			subnet_name         = "snet-pms-apim-qa"
			address_prefixes    = "10.200.8.64/28"
			route_table_name    = ""
			snet_delegation     = ""
			service_endpoints   = ""
		},
		akscluster = {            
			subnet_name         = "snet-pms-aks-001-qa"
			address_prefixes    = "10.200.9.0/24"
			route_table_name    = ""
			snet_delegation     = ""
			service_endpoints   = ""
		},
		aksservices = {            
			subnet_name         = "snet-pms-aks-002-qa"
			address_prefixes    = "10.200.10.0/24"
			route_table_name    = ""
			snet_delegation     = ""
			service_endpoints   = ""
		}
	}

	prd = {
		resource_group_name =   "rg-pms-prd"
		vnet_name           =   "vnet-pms-prd"
		address_space       =   "10.200.12.0/22"  
		 
		agw = {
			name                = "agw-pms-gateway-prd"
			subnet_name         = "snet-agw-prd"
			address_prefixes    = "10.200.12.0/28"
			route_table_name    = ""
			snet_delegation     = ""
			service_endpoints   = ""
		},
		app = {            
			subnet_name         = "snet-pms-app-prd"
			address_prefixes    = "10.200.12.16/28"
			route_table_name    = ""
			snet_delegation     = ""
			service_endpoints   = ""
		},
	   
		web = {            
			subnet_name         = "snet-pms-web-prd"
			address_prefixes    = "10.200.12.32/28"
			route_table_name    = ""
			snet_delegation     = "appservice"
			service_endpoints   = ""
		},
		data = {            
			subnet_name         = "snet-pms-db-prd"
			address_prefixes    = "10.200.12.48/28"
			route_table_name    = ""
			snet_delegation     = ""
			service_endpoints   = ""
		},
		apim = {            
			subnet_name         = "snet-pms-apim-prd"
			address_prefixes    = "10.200.12.64/28"
			route_table_name    = ""
			snet_delegation     = ""
			service_endpoints   = ""
		},
		akscluster = {            
			subnet_name         = "snet-pms-aks-001-prd"
			address_prefixes    = "10.200.13.0/24"
			route_table_name    = ""
			snet_delegation     = ""
			service_endpoints   = []
		},
		aksservices = {            
			subnet_name         = "snet-pms-aks-002-prd"
			address_prefixes    = "10.200.14.0/24"
			route_table_name    = ""
			snet_delegation     = ""
			service_endpoints   = []
		}
	}

    avd = {
		resource_group_name =   "rg-pms-network-hub"
		vnet_name           =   "vnet-pms-avd"
		address_space       =   "10.200.20.0/22"  
		user01 = {
			name                = "avd-pms-avd01-prd"
			subnet_name         = "snet-pms-avd01-prd"
			address_prefixes    = "10.200.20.0/24"
			route_table_name    = ""
			snet_delegation     = ""
			service_endpoints   = ""
		},

	}