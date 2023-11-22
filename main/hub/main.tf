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

locals { 
  solutions = [
    {
        name      = "AzureAutomation",
        publisher = "Microsoft",
        product   = "OMSGallery/AzureAutomation"
    },
    {
        name      = "InfrastructureInsights",
        publisher = "Microsoft",
        product   = "OMSGallery/InfrastructureInsights"
    },
    {
        name      = "Containers",
        publisher = "Microsoft",
        product   = "OMSGallery/Containers"
    },
    {
        name      = "Security",
        publisher = "Microsoft",
        product   = "OMSGallery/Security"
    }
  ]
  private_zone_names = [
    "privatelink.azurewebsites.net",
    "privatelink.database.windows.net",
    "privatelink.vaultcore.azure.net",
    "privatelink.blob.core.windows.net",
    "privatelink.queue.core.windows.net",
    "privatelink.file.core.windows.net",
    "privatelink.azure-api.net",
    "privatelink.azurecr.io",
    "privatelink.openai.azure.net",
    "privatelink.datafactory.azure.net",
    "privatelink.azuredatabricks.net",
    "privatelink.dfs.core.windows.net",
    "privatelink.postgres.database.azure.com"
  ]
}

data "azurerm_storage_account" "artefact-storage-account" {
    name                = lookup(var.hub["devOps"], "artefact_sa_name","")
    resource_group_name = lookup(var.hub["devOps"], "artefact_rg_name","")
}

data "azurerm_storage_account_blob_container_sas" "sas-token" {
    connection_string = data.azurerm_storage_account.artefact-storage-account.primary_connection_string
    container_name    = "artefacts"
     https_only       = true
   
    start  = timestamp()
    expiry = timeadd(formatdate("YYYY-MM-01'T'00:00:00Z", timestamp()), "24h")

    permissions {
        read    = true    
        add     = true
        create  = true
        write   = true
        delete  = true        
        list    = true       
    }
    cache_control       = "max-age=5"
    content_disposition = "inline"
    content_encoding    = "deflate"
    content_language    = "en-US"
    content_type        = "application/json"
}


module "network-rg" {
      source                = "../../modules/resource-groups"
      
      location              = "${var.location}"
      resource_group_name   = lookup(var.hub, "network_rg_name","") 
      tags                  = "${var.tags}"  
}

module "management-rg" {
      source                = "../../modules/resource-groups"
      
      location              = "${var.location}"
      resource_group_name   = lookup(var.hub, "mgmt_rg_name","") 
      tags                  = "${var.tags}"  
}

module "monitor-rg" {
      source                = "../../modules/resource-groups"
      
      location              = "${var.location}"
      resource_group_name   = lookup(var.hub, "mon_rg_name","") 
      tags                  = "${var.tags}"  
}

module "aci-devops-rg" {
      source      = "../../modules/resource-groups"
      
      location              = "${var.location}"
      resource_group_name   = lookup(var.hub, "devops_rg_name","") 
      tags                  = "${var.tags}"  
}




# Create the log analytics workspace. Use the outputs from the resource-group module to create an implicit dependancy
module "log-analytics-workspace" {
    source              = "../../modules/log-analytics"

    la_name             = lookup(var.hub["loganalytics"], "name","")
    resource_group_name = module.monitor-rg.name
    location            = "${var.location}"
    tags                = "${var.tags}"
    solutions           = local.solutions
    depends_on          = [module.monitor-rg]
}

module "diagnostic-storage" {
    source              = "../../modules/storage/storage-account"

    storage_account_name= lookup(var.hub["loganalytics"], "diag_storage_name","")
    resource_group_name = module.monitor-rg.name
    location            = "${var.location}"
    tags                = "${var.tags}"
   
    depends_on          = [module.monitor-rg]
}

module "acr" {
    source              = "../../modules/container-registry"
    acr_name            =  lookup(var.hub["devOps"], "acr_name","")
    location            = "${var.location}"
    resource_group_name = module.aci-devops-rg.name
    sku                 = lookup(var.hub["devOps"], "acr_sku","Premium")
    admin_enabled       = lookup(var.hub["devOps"], "admin_enabled",false)
    tags                = "${var.tags}"
}

# keyvault Module is used to create Azure Key Vault.
module "key-vault" {
    source                          = "../../modules/key-vault"

    resource_group_name             = module.management-rg.name
    location                        = "${var.location}"   

    # To use Key vault - Choose a unique name 
    key_vault_name                  = lookup(var.hub["keyvault"], "kv_name","")
    sku_name                        = lookup(var.hub["keyvault"], "sku","")
    admin_certificate_permissions   = lookup(var.hub["keyvault"], "admin_certificate_permissions","")
    admin_key_permissions           = lookup(var.hub["keyvault"], "admin_key_permissions","")
    admin_secret_permissions        = lookup(var.hub["keyvault"], "admin_secret_permissions","") 
    managed_identity_name           = lookup(var.hub["keyvault"], "managed_identity_name","") 
    managed_identity_secret_permissions = lookup(var.hub["keyvault"], "managed_identity_secret_permissions","")
    tags		                    = merge(tomap({"type" = "security"}), var.tags)
}

# vnet Module is used to create Virtual Networks and Subnets
module "hub-vnet" {
    source              = "../../modules/virtual-network"
    
    resource_group_name = module.network-rg.name
    location            = "${var.location}"
    tags                = "${var.tags}"
    vnet_name           = lookup(var.hub, "vnet_name","")
    address_space       = [lookup(var.hub, "address_space","")]
    depends_on          = [module.network-rg, module.log-analytics-workspace]

    # Subnets are used in Index for other modules to refer
    # module.hub-vnet.vnet_subnet_id[0] = A1-AciSubnet             - Alphabetical Order
    # module.hub-vnet.vnet_subnet_id[1] = A2-AzureBastionSubnet    - Alphabetical Order
    # module.hub-vnet.vnet_subnet_id[2] = A3-AzureFirewallSubnet   - Alphabetical Order
    # module.hub-vnet.vnet_subnet_id[3] = A4-DevOpsSubnet          - Alphabetical Order
    # module.hub-vnet.vnet_subnet_id[4] = A5-DnsInSubnet           - Alphabetical Order
    # module.hub-vnet.vnet_subnet_id[5] = A6-DnsOutSubnet          - Alphabetical Order
    # module.hub-vnet.vnet_subnet_id[6] = A7-GatewaySubnet         - Alphabetical Order
    # module.hub-vnet.vnet_subnet_id[7] = A8-ManagementSubnet      - Alphabetical Order
    # module.hub-vnet.vnet_subnet_id[8] = A9-EndpointsSubnet       - Alphabetical Order

    # Subnets are used in Index for other modules to refer
    subnet_names = {
      "A7-GatewaySubnet" = {
            subnet_name = lookup(var.hub["gateway"], "subnet_name","")
            address_prefixes = [lookup(var.hub["gateway"], "address_prefixes","")]
            route_table_name = ""
            snet_delegation  = ""
            service_endpoints   = [lookup(var.hub["gateway"], "service_endpoints","")]
            private_endpoint_network_policies_enabled = false
            
      },
      "A3-AzureFirewallSubnet" = {
            subnet_name = lookup(var.hub["firewall"], "subnet_name","")
            address_prefixes = [lookup(var.hub["firewall"], "address_prefixes","")]
            route_table_name = ""
            snet_delegation  = ""
            service_endpoints   = [lookup(var.hub["firewall"], "service_endpoints","")]
            private_endpoint_network_policies_enabled = false
      },
      "A5-DnsInSubnet" = {
            subnet_name = lookup(var.hub["dnsIn"], "subnet_name","")
            address_prefixes = [lookup(var.hub["dnsIn"], "address_prefixes","")]
            route_table_name = ""
            snet_delegation  = ""
            service_endpoints   = [lookup(var.hub["dnsIn"], "service_endpoints","")]
            private_endpoint_network_policies_enabled = false
      },
      "A6-DnsOutSubnet" = {
            subnet_name = lookup(var.hub["dnsOut"], "subnet_name","")
            address_prefixes = [lookup(var.hub["dnsOut"], "address_prefixes","")]
            route_table_name = ""
            snet_delegation  = ""
            service_endpoints   = [lookup(var.hub["dnsOut"], "service_endpoints","")]
            private_endpoint_network_policies_enabled = false
      }, 
      "A2-AzureBastionSubnet" = {
            subnet_name = lookup(var.hub["bastion"], "subnet_name","")
            address_prefixes = [lookup(var.hub["bastion"], "address_prefixes","")]
            route_table_name = ""
            snet_delegation  = ""
            service_endpoints= [lookup(var.hub["bastion"], "service_endpoints","")]
            private_endpoint_network_policies_enabled = false
      },   
      "A1-AciSubnet" = {
            subnet_name = lookup(var.hub["aci"], "subnet_name","")
            address_prefixes = [lookup(var.hub["aci"], "address_prefixes","")]
            route_table_name = ""
            snet_delegation  = "aci"
            service_endpoints   = [lookup(var.hub["aci"], "service_endpoints","")]
            private_endpoint_network_policies_enabled = false
      },
      "A4-DevOpsSubnet" = {
            subnet_name = lookup(var.hub["devOps"], "subnet_name","")
            address_prefixes = [lookup(var.hub["devOps"], "address_prefixes","")]
            route_table_name = ""
            snet_delegation  = ""
            service_endpoints   = [lookup(var.hub["devOps"], "service_endpoints","")]
            private_endpoint_network_policies_enabled = false
      },
      "A8-ManagementSubnet" = {
            subnet_name = lookup(var.hub["management"], "subnet_name","")
            address_prefixes = [lookup(var.hub["management"], "address_prefixes","")]
            route_table_name = ""
            snet_delegation  = ""
            service_endpoints   = [lookup(var.hub["management"], "service_endpoints","")]
            private_endpoint_network_policies_enabled = false
      },
      "A9-EndpointsSubnet" = {
            subnet_name = lookup(var.hub["endpoints"], "subnet_name","")
            address_prefixes = [lookup(var.hub["endpoints"], "address_prefixes","")]
            route_table_name = "" 
            snet_delegation  = ""
            service_endpoints   = [lookup(var.hub["endpoints"], "service_endpoints","")]
            private_endpoint_network_policies_enabled = true
      }
    }
}

module "dev-vnet" {
    source              = "../../modules/virtual-network"
    
    resource_group_name = module.network-rg.name
    location            = "${var.location}"
    tags                = "${var.tags}"
    vnet_name           = lookup(var.dev, "vnet_name","")
    address_space       = [lookup(var.dev, "address_space","")]

    depends_on = [module.network-rg]

    # Subnets are used in Index for other modules to refer
    # module.dev-vnet.vnet_subnet_id[0] = A1-AgwSubnet         - Alphabetical Order
    # module.dev-vnet.vnet_subnet_id[1] = A2-AksClusterSubnet  - Alphabetical Order
    # module.dev-vnet.vnet_subnet_id[2] = A3-AksServiceSubnet  - Alphabetical Order
    # module.dev-vnet.vnet_subnet_id[3] = A4-ApimSubnet        - Alphabetical Order
    # module.dev-vnet.vnet_subnet_id[4] = A5-AppSubnet         - Alphabetical Order
    # module.dev-vnet.vnet_subnet_id[5] = A6-DataSubnet        - Alphabetical Order
    # module.dev-vnet.vnet_subnet_id[6] = A7-IntSubnet         - Alphabetical Order
    # module.dev-vnet.vnet_subnet_id[7] = A8-EndpointsSubnet   - Alphabetical Order
   
    
   

    # Subnets are used in Index for other modules to refer
    subnet_names = {
      "A1-AgwSubnet" = {
            subnet_name = lookup(var.dev["agw"], "subnet_name","")
            address_prefixes = [lookup(var.dev["agw"], "address_prefixes","")]
            route_table_name = ""
            snet_delegation  = ""
            service_endpoints   = [lookup(var.dev["agw"], "service_endpoints","")]
            private_endpoint_network_policies_enabled = false
      },
      "A5-AppSubnet" = {
            subnet_name = lookup(var.dev["app"], "subnet_name","")
            address_prefixes = [lookup(var.dev["app"], "address_prefixes","")]
            route_table_name = ""
            snet_delegation  = ""
            service_endpoints   = [lookup(var.dev["app"], "service_endpoints","")]
            private_endpoint_network_policies_enabled = false
      },
      "A7-IntSubnet" = {
            subnet_name = lookup(var.dev["int"], "subnet_name","")
            address_prefixes = [lookup(var.dev["int"], "address_prefixes","")]
            route_table_name = ""
            snet_delegation  = "appservice"
            service_endpoints   = [lookup(var.dev["int"], "service_endpoints","")]
            private_endpoint_network_policies_enabled = false
      },
      "A6-DataSubnet" = {
            subnet_name = lookup(var.dev["data"], "subnet_name","")
            address_prefixes = [lookup(var.dev["data"], "address_prefixes","")]
            route_table_name = ""
            snet_delegation  = ""
            service_endpoints   = [lookup(var.dev["data"], "service_endpoints","")]
            private_endpoint_network_policies_enabled = false
      },
      "A4-ApimSubnet" = {
            subnet_name = lookup(var.dev["apim"], "subnet_name","")
            address_prefixes = [lookup(var.dev["apim"], "address_prefixes","")]
            route_table_name = ""
            snet_delegation  = ""
            service_endpoints   = [lookup(var.dev["apim"], "service_endpoints","")]
            private_endpoint_network_policies_enabled = false
      },
      "A2-AksClusterSubnet" = {
            subnet_name = lookup(var.dev["akscluster"], "subnet_name","")
            address_prefixes = [lookup(var.dev["akscluster"], "address_prefixes","")]
            route_table_name = ""
            snet_delegation  = ""
            service_endpoints   = [lookup(var.dev["akscluster"], "service_endpoints","")]
            private_endpoint_network_policies_enabled = false
      }, 
       "A3-AksServiceSubnet" = {
            subnet_name = lookup(var.dev["aksservices"], "subnet_name","")
            address_prefixes = [lookup(var.dev["aksservices"], "address_prefixes","")]
            route_table_name = ""
            snet_delegation  = ""
            service_endpoints   = [lookup(var.dev["aksservices"], "service_endpoints","")]
            private_endpoint_network_policies_enabled = false
        } ,
        "A8-EndpointsSubnet" = {
            subnet_name = lookup(var.dev["endpoints"], "subnet_name","")
            address_prefixes = [lookup(var.dev["endpoints"], "address_prefixes","")]
            route_table_name = ""
            snet_delegation  = ""
            service_endpoints   = [lookup(var.dev["endpoints"], "service_endpoints","")]
            private_endpoint_network_policies_enabled = true
        }
    }
}

module "qa-vnet" {
    source              = "../../modules/virtual-network"
    
    resource_group_name = module.network-rg.name
    location            = "${var.location}"
    tags                = "${var.tags}"
    vnet_name           = lookup(var.qa, "vnet_name","")
    address_space       = [lookup(var.qa, "address_space","")]
    depends_on          = [module.network-rg]

    # Subnets are used in Index for other modules to refer
    subnet_names = {
      "AgwSubnet" = {
            subnet_name = lookup(var.qa["agw"], "subnet_name","")
            address_prefixes = [lookup(var.qa["agw"], "address_prefixes","")]
            route_table_name = ""
            snet_delegation  = ""
      },
      "AppSubnet" = {
            subnet_name = lookup(var.qa["app"], "subnet_name","")
            address_prefixes = [lookup(var.qa["app"], "address_prefixes","")]
            route_table_name = ""
            snet_delegation  = ""
      },
      "WebSubnet" = {
            subnet_name = lookup(var.qa["web"], "subnet_name","")
            address_prefixes = [lookup(var.qa["web"], "address_prefixes","")]
            route_table_name = ""
            snet_delegation  = "appservice"
      },
      "DataSubnet" = {
            subnet_name = lookup(var.qa["data"], "subnet_name","")
            address_prefixes = [lookup(var.qa["data"], "address_prefixes","")]
            route_table_name = ""
            snet_delegation  = ""
      },
      "ApimSubnet" = {
            subnet_name = lookup(var.qa["apim"], "subnet_name","")
            address_prefixes = [lookup(var.qa["apim"], "address_prefixes","")]
            route_table_name = ""
            snet_delegation  = ""
        },
        "AksClusterSubnet" = {
            subnet_name = lookup(var.qa["akscluster"], "subnet_name","")
            address_prefixes = [lookup(var.qa["akscluster"], "address_prefixes","")]
            route_table_name = ""
            snet_delegation  = ""
        }, 
        "AksServiceSubnet" = {
            subnet_name = lookup(var.qa["aksservices"], "subnet_name","")
            address_prefixes = [lookup(var.qa["aksservices"], "address_prefixes","")]
            route_table_name = ""
            snet_delegation  = ""
        } 
    }
}

module "prd-vnet" {
    source              = "../../modules/virtual-network"
    
    resource_group_name = module.network-rg.name
    location            = "${var.location}"
    tags                = "${var.tags}"
    vnet_name           = lookup(var.prd, "vnet_name","")
    address_space       = [lookup(var.prd, "address_space","")]
    depends_on          = [module.network-rg]
    # Subnets are used in Index for other modules to refer
    subnet_names = {
      "AgwSubnet" = {
            subnet_name = lookup(var.prd["agw"], "subnet_name","")
            address_prefixes = [lookup(var.prd["agw"], "address_prefixes","")]
            route_table_name = ""
            snet_delegation  = ""
      },
      "AppSubnet" = {
            subnet_name = lookup(var.prd["app"], "subnet_name","")
            address_prefixes = [lookup(var.prd["app"], "address_prefixes","")]
            route_table_name = ""
            snet_delegation  = ""
      },
      "WebSubnet" = {
            subnet_name = lookup(var.prd["web"], "subnet_name","")
            address_prefixes = [lookup(var.prd["web"], "address_prefixes","")]
            route_table_name = ""
            snet_delegation  = "appservice"
      },
      "DataSubnet" = {
            subnet_name = lookup(var.prd["data"], "subnet_name","")
            address_prefixes = [lookup(var.prd["data"], "address_prefixes","")]
            route_table_name = ""
            snet_delegation  = ""
      },
      "ApimSubnet" = {
            subnet_name = lookup(var.prd["apim"], "subnet_name","")
            address_prefixes = [lookup(var.prd["apim"], "address_prefixes","")]
            route_table_name = ""
            snet_delegation  = ""
        },
        "AksClusterSubnet" = {
            subnet_name = lookup(var.prd["akscluster"], "subnet_name","")
            address_prefixes = [lookup(var.prd["akscluster"], "address_prefixes","")]
            route_table_name = ""
            snet_delegation  = ""
        }, 
        "AksServiceSubnet" = {
            subnet_name = lookup(var.prd["aksservices"], "subnet_name","")
            address_prefixes = [lookup(var.prd["aksservices"], "address_prefixes","")]
            route_table_name = ""
            snet_delegation  = ""
        } 
    }
}

module "avd-vnet" {
    source              = "../../modules/virtual-network"
    
    resource_group_name = module.network-rg.name
    location            = "${var.location}"
    tags                = "${var.tags}"
    vnet_name           = lookup(var.avd, "vnet_name","")
    address_space       = [lookup(var.avd, "address_space","")]
    depends_on          = [module.network-rg]
     # Subnets are used in Index for other modules to refer
    subnet_names = {      
        "StdUser01Subnet" = {
            subnet_name = lookup(var.avd["user01"], "subnet_name","")
            address_prefixes = [lookup(var.avd["user01"], "address_prefixes","")]
            route_table_name = ""
            snet_delegation  = ""
            service_endpoints   = [lookup(var.avd["user01"], "service_endpoints","")]
        } 
    }
}

module "hub-to-avd" {
      source                       = "../../modules/vnet-peering"
      
     
      virtual_network_peering_name = "hub-vnet-to-avd-vnet"
      resource_group_name          = module.network-rg.name
      virtual_network_name         = module.hub-vnet.vnet_name
      remote_virtual_network_id    = module.avd-vnet.vnet_id
      allow_virtual_network_access = "true"
      allow_forwarded_traffic      = "true"
      allow_gateway_transit        = "true"
      use_remote_gateways          = "false"
      
      depends_on                   = [module.hub-vnet , module.avd-vnet]
}

# vnet-peering Module is used to create peering between Virtual Networks
module "avd-to-hub" {
      source = "../../modules/vnet-peering"

      virtual_network_peering_name = "avd-vnet-to-hub-vnet"
      resource_group_name          = module.network-rg.name
      virtual_network_name         = module.avd-vnet.vnet_name
      remote_virtual_network_id    = module.hub-vnet.vnet_id
      allow_virtual_network_access = "true"
      allow_forwarded_traffic      = "true"
      allow_gateway_transit        = "false"
      # As there is no gateway while testing - Setting to False
      #use_remote_gateways   = "true"
      use_remote_gateways          = "false"
     
      depends_on = [module.hub-vnet , module.avd-vnet]
}

# vnet-peering Module is used to create peering between Virtual Networks
module "hub-to-dev" {
      source                       = "../../modules/vnet-peering"
      
     
      virtual_network_peering_name = "hub-vnet-to-dev-vnet"
      resource_group_name          = module.network-rg.name
      virtual_network_name         = module.hub-vnet.vnet_name
      remote_virtual_network_id    = module.dev-vnet.vnet_id
      allow_virtual_network_access = "true"
      allow_forwarded_traffic      = "true"
      allow_gateway_transit        = "true"
      use_remote_gateways          = "false"
      
      depends_on                   = [module.hub-vnet , module.dev-vnet]
}

# vnet-peering Module is used to create peering between Virtual Networks
module "dev-to-hub" {
      source = "../../modules/vnet-peering"

      virtual_network_peering_name = "dev-vnet-to-hub-vnet"
      resource_group_name          = module.network-rg.name
      virtual_network_name         = module.dev-vnet.vnet_name
      remote_virtual_network_id    = module.hub-vnet.vnet_id
      allow_virtual_network_access = "true"
      allow_forwarded_traffic      = "true"
      allow_gateway_transit        = "false"
      # As there is no gateway while testing - Setting to False
      #use_remote_gateways   = "true"
      use_remote_gateways          = "false"
     
      depends_on = [module.hub-vnet , module.dev-vnet]
}

# vnet-peering Module is used to create peering between Virtual Networks
module "hub-to-qa" {
      source                       = "../../modules/vnet-peering"
      depends_on                   = [module.hub-vnet , module.qa-vnet]
      #depends_on = [module.hub-vnet , module.spoke1-vnet , module.application_gateway, module.vpn_gateway , module.azure_firewall_01]

      virtual_network_peering_name = "hub-vnet-to-qa-vnet"
      resource_group_name          = module.network-rg.name
      virtual_network_name         = module.hub-vnet.vnet_name
      remote_virtual_network_id    = module.qa-vnet.vnet_id
      allow_virtual_network_access = "true"
      allow_forwarded_traffic      = "true"
      allow_gateway_transit        = "true"
      use_remote_gateways          = "false"
      

}

# vnet-peering Module is used to create peering between Virtual Networks
module "qa-to-hub" {
      source = "../../modules/vnet-peering"

      virtual_network_peering_name = "qa-vnet-to-hub-vnet"
      resource_group_name          = module.network-rg.name
      virtual_network_name         = module.qa-vnet.vnet_name
      remote_virtual_network_id    = module.hub-vnet.vnet_id
      allow_virtual_network_access = "true"
      allow_forwarded_traffic      = "true"
      allow_gateway_transit        = "false"
      
      # As there is no gateway while testing - Setting to False
      #use_remote_gateways   = "true"
      use_remote_gateways          = "false"
     
      depends_on = [module.hub-vnet , module.qa-vnet]
}

# vnet-peering Module is used to create peering between Virtual Networks
module "hub-to-prd" {
      source = "../../modules/vnet-peering"
      depends_on = [module.hub-vnet , module.prd-vnet]
      
      virtual_network_peering_name = "hub-vnet-to-prd-vnet"
      resource_group_name          = module.network-rg.name
      virtual_network_name         = module.hub-vnet.vnet_name
      remote_virtual_network_id    = module.prd-vnet.vnet_id
      allow_virtual_network_access = "true"
      allow_forwarded_traffic      = "true"
      allow_gateway_transit        = "true"
      use_remote_gateways          = "false"
      
}

# vnet-peering Module is used to create peering between Virtual Networks
module "prd-to-hub" {
      source = "../../modules/vnet-peering"

      virtual_network_peering_name = "prd-vnet-to-hub-vnet"
      resource_group_name          = module.network-rg.name
      virtual_network_name         = module.prd-vnet.vnet_name
      remote_virtual_network_id    = module.hub-vnet.vnet_id
      allow_virtual_network_access = "true"
      allow_forwarded_traffic      = "true"
      allow_gateway_transit        = "false"
      # As there is no gateway while testing - Setting to False
      #use_remote_gateways   = "true"
      use_remote_gateways          = "false"
     
      depends_on = [module.hub-vnet , module.prd-vnet]
}

# routetables Module is used to create route tables and associate them with Subnets created by Virtual Networks
# module "route_tables" {
#       source      = "../../modules/route-tables"
#       depends_on  = [module.hub-vnet , module.dev-vnet]

#     route_table_name              = "az-netb-pr-eastus2-route"
#       location                      = "${var.location}"
#       resource_group_name           = module.hub-rg.name
#       disable_bgp_route_propagation = false

#       route_name                    = "ToAzureFirewall"
#       address_prefix                = "0.0.0.0/0"
#       next_hop_type                 = "VirtualAppliance"
#       next_hop_in_ip_address        = module.azure_firewall_01.azure_firewall_private_ip

#       subnet_ids                    = [
#             module.dev-vnet.vnet_subnet_id[0],
#             module.dev-vnet.vnet_subnet_id[1]
#       ]

# }


# publicip Module is used to create Public IP Address
module "gateway-pip" {
      source = "../../modules/public-ip-address"

      # Used for VPN Gateway 
      public_ip_name      = "pip-pms-gateway"
      resource_group_name = module.network-rg.name
      location            = "${var.location}"
      allocation_method   = "Static"
      sku                 = "Standard"
      tags                = "${var.tags}"
}

# publicip Module is used to create Public IP Address
module "firewall-pip" {
      source              = "../../modules/public-ip-address"

      # Used for Azure Firewall 
      public_ip_name      = "pip-pms-firewall"
      resource_group_name = module.network-rg.name
      location            = "${var.location}"
      allocation_method   = "Static"
      sku                 = "Standard"
      tags                = "${var.tags}"
}

# publicip Module is used to create Public IP Address
module "bastion-pip" {
      source = "../../modules/public-ip-address"

      # Used for Azure Bastion 
      public_ip_name      = "pip-pms-bastion"
      resource_group_name = module.network-rg.name
      location            = "${var.location}"
      allocation_method   = "Static"
      sku                 = "Standard"
      tags                = "${var.tags}"
}

# publicip Module is used to create Public IP Address
module "devops-pip" {
      source              = "../../modules/public-ip-address"

      # Used for DevOps Build Agent 
      public_ip_name      = "pip-pms-devops"
      resource_group_name = module.network-rg.name
      location            = "${var.location}"
      allocation_method   = "Static"
      sku                 = "Standard"
      tags                = "${var.tags}"
}

# Create Network Security Group and rules
 module "nsg-avd" {
     source                           = "../../modules/nsg"
     # Used for avd
     
     nsg_name                         = "nsg-pms-avd"
     location                         = "${var.location}"
     resource_group_name              = module.network-rg.name
    
     tags                             = "${var.tags}"
     nsg-rules = {   
         "nsg-rule-01" = {    
             name                        = "allow-https-inbound"
             priority                    = "100"
             direction                   = "Inbound"
             access                      = "Allow"
             protocol                    = "Tcp"
             source_port_range           = "*"
             destination_port_ranges     = ["443"]
             source_address_prefix       = "*"
             destination_address_prefix  = "*"
         }
     } 
     # Visual Studio: Ctrl+K, Ctrl+C to comment; Ctrl+K, Ctrl+U to uncomment.
     
     depends_on = [module.network-rg]
}

 module "nsg-snet-associate-avd-prd" {
     source                     = "../../modules/nsg-snet"
     subnet_id                  = module.avd-vnet.vnet_subnet_id[0]
     network_security_group_id  = module.nsg-avd.nsg_id

     depends_on = [module.avd-vnet, module.nsg-avd]
 }


 # Create Network Security Group and rules
 module "nsg-agw" {
     source                           = "../../modules/nsg"
     # Used for avd
     
     nsg_name                         = "nsg-pms-agw"
     location                         = "${var.location}"
     resource_group_name              = module.network-rg.name
    
     tags                             = "${var.tags}"
     nsg-rules = {   
         "nsg-rule-01" = {    
             name                        = "allow-https-inbound"
             priority                    = "100"
             direction                   = "Inbound"
             access                      = "Allow"
             protocol                    = "Tcp"
             source_port_range           = "*"
             destination_port_ranges     = ["443"]
             source_address_prefix       = "*"
             destination_address_prefix  = "*"
         }
     } 
     # Visual Studio: Ctrl+K, Ctrl+C to comment; Ctrl+K, Ctrl+U to uncomment.
     
     depends_on = [module.network-rg]
}

 module "nsg-snet-associate-agw-dev" {
     source                     = "../../modules/nsg-snet"
     subnet_id                  = module.dev-vnet.vnet_subnet_id[0]
     network_security_group_id  = module.nsg-agw.nsg_id

     depends_on = [module.dev-vnet, module.nsg-agw]
 }


# Create Network Security Group and rules
 module "nsg-jumpbox-01" {
     source                           = "../../modules/nsg"
     # Used for Jump Box
     
     nsg_name                         = "nsg-pms-${lookup(var.hub["management"], "vm_jumpbox01_name","")}"
     location                         = "${var.location}"
     resource_group_name              = module.network-rg.name
    
     tags                             = "${var.tags}"
     nsg-rules = {   
         "nsg-rule-01" = {    
             name                        = "allow-ssh-rdp-https-bastion-inbound"
             priority                    = "100"
             direction                   = "Inbound"
             access                      = "Allow"
             protocol                    = "Tcp"
             source_port_range           = "*"
             destination_port_ranges     = ["22","3389", "443"]
             source_address_prefix       = lookup(var.hub["bastion"], "address_prefixes","")
             destination_address_prefix  = "*"
         }
     } 
     # Visual Studio: Ctrl+K, Ctrl+C to comment; Ctrl+K, Ctrl+U to uncomment.
     
     depends_on = [module.vm-jumpbox-01, module.network-rg]
}

 module "nsg-nic-associate-jumpbox-01" {
     source                    = "../../modules/nsg-nic"

     network_interface_id      = module.vm-jumpbox-01.nic_id
     network_security_group_id = module.nsg-jumpbox-01.nsg_id

     depends_on = [module.vm-jumpbox-01]
 }

#Create Network Security Group and rules (Bastion)
module "nsg-bastion" {
    source                           = "../../modules/nsg"

    # Used for bastion
    nsg_name                         = "nsg-pms-bastion"
    location                         = "${var.location}"
    resource_group_name              = module.network-rg.name
    tags                             = "${var.tags}"
    nsg-rules = {
        "nsg-rule-01" = {    
            name                        = "allow-https-inbound"
            priority                    = "100"
            direction                   = "Inbound"
            access                      = "Allow"
            protocol                    = "Tcp"
            source_port_range           = "*"
            destination_port_ranges     = ["443"]
            source_address_prefix       = "Internet"
            destination_address_prefix  = "*"
        }, 
        "nsg-rule-02" = {    
            name                        = "allow-https-gm-inbound"
            priority                    = "120"
            direction                   = "Inbound"
            access                      = "Allow"
            protocol                    = "Tcp"
            source_port_range           = "*"
            destination_port_ranges     = ["443"]
            source_address_prefix       = "GatewayManager"
            destination_address_prefix  = "*"
        },
        "nsg-rule-03" = {    
            name                        = "allow-bastion-comms-inbound"
            priority                    = "130"
            direction                   = "Inbound"
            access                      = "Allow"
            protocol                    = "*"
            source_port_range           = "*"
            destination_port_ranges     = ["8080", "5701"]
            source_address_prefix       = "VirtualNetwork"
            destination_address_prefix  = "VirtualNetwork"
        },
        "nsg-rule-04" = {    
            name                        = "allow-ssh-rdp-outbound"
            priority                    = "100"
            direction                   = "Outbound"
            access                      = "Allow"
            protocol                    = "*"
            source_port_range           = "*"
            destination_port_ranges     = ["22", "3389"]
            source_address_prefix       = "*"
            destination_address_prefix  = "VirtualNetwork"
        },       
        "nsg-rule-05" = {    
            name                        = "allow-azure-cloud-outbound"
            priority                    = "110"
            direction                   = "Outbound"
            access                      = "Allow"
            protocol                    = "*"
            source_port_range           = "*"
            destination_port_ranges     = ["443"]
            source_address_prefix       = "*"
            destination_address_prefix  = "AzureCloud"
        },
        "nsg-rule-06" = {    
            name                        = "allow-bastion-comms-outbound"
            priority                    = "120"
            direction                   = "Outbound"
            access                      = "Allow"
            protocol                    = "*"
            source_port_range           = "*"
            destination_port_ranges     = ["8080", "5701"]
            source_address_prefix       = "VirtualNetwork"
            destination_address_prefix  = "VirtualNetwork"
        },
         "nsg-rule-07" = {    
            name                        = "allow-http-outbound"
            priority                    = "130"
            direction                   = "Outbound"
            access                      = "Allow"
            protocol                    = "*"
            source_port_range           = "*"
            destination_port_ranges     = ["80"]
            source_address_prefix       = "*"
            destination_address_prefix  = "Internet"
        }
    }     
    depends_on = [module.bastion-host, module.network-rg]
}

 module "nsg-snet-associate-bastion" {
     source                     = "../../modules/nsg-snet"
     subnet_id                  = module.hub-vnet.vnet_subnet_id[1]
     network_security_group_id  = module.nsg-bastion.nsg_id

     depends_on = [module.hub-vnet, module.nsg-bastion]
 }

 ##########################################################
 #Create Network Security Group and rules for applications
 ##########################################################
module "nsg-app" {
    source                           = "../../modules/nsg"

    # Used for application workload
    nsg_name                         = "nsg-pms-app"
    location                         = "${var.location}"
    resource_group_name              = module.network-rg.name
    tags                             = "${var.tags}"

    nsg-rules = {   
        "nsg-rule-01" = {    
            name                        = "allow-ssh-rdp-inbound"
            priority                    = "100"
            direction                   = "Inbound"
            access                      = "Allow"
            protocol                    = "Tcp"
            source_port_range           = "*"
            destination_port_ranges     = ["22", "3389"]
            source_address_prefix       = lookup(var.hub["bastion"], "address_prefixes","")
            destination_address_prefix  = "VirtualNetwork"
        }
    }     
    depends_on = [module.network-rg]
}

 module "nsg-snet-associate-app-dev" {
     source                     = "../../modules/nsg-snet"
     subnet_id                  = module.dev-vnet.vnet_subnet_id[4]
     network_security_group_id  = module.nsg-app.nsg_id

     depends_on = [module.dev-vnet, module.nsg-app]
 }

 #################################################
 #Create Network Security Group and rules for Web
 #################################################
module "nsg-web" {
    source                           = "../../modules/nsg"

    # Used for web workload
    nsg_name                         = "nsg-pms-web"
    location                         = "${var.location}"
    resource_group_name              = module.network-rg.name
    tags                             = "${var.tags}"

    nsg-rules = {   
        "nsg-rule-01" = {    
            name                        = "allow-ssh-rdp-inbound"
            priority                    = "100"
            direction                   = "Inbound"
            access                      = "Allow"
            protocol                    = "Tcp"
            source_port_range           = "*"
            destination_port_ranges     = ["22", "3389"]
            source_address_prefix       = lookup(var.hub["bastion"], "address_prefixes","")
            destination_address_prefix  = "VirtualNetwork"
        }
    }     
    depends_on = [module.network-rg]
}

 module "nsg-snet-associate-web-dev" {
     source                     = "../../modules/nsg-snet"
     subnet_id                  = module.dev-vnet.vnet_subnet_id[6]
     network_security_group_id  = module.nsg-web.nsg_id

     depends_on = [module.dev-vnet, module.nsg-web]
 }

 #########################################################
 #Create Network Security Group and rules for database(s)
 #########################################################
module "nsg-data" {
    source                           = "../../modules/nsg"

    # Used for database(s)
    nsg_name                         = "nsg-pms-data"
    location                         = "${var.location}"
    resource_group_name              = module.network-rg.name
    tags                             = "${var.tags}"

    nsg-rules = {   
        "nsg-rule-01" = {    
            name                        = "allow-ssh-rdp-inbound"
            priority                    = "100"
            direction                   = "Inbound"
            access                      = "Allow"
            protocol                    = "Tcp"
            source_port_range           = "*"
            destination_port_ranges     = ["22", "3389"]
            source_address_prefix       = lookup(var.hub["bastion"], "address_prefixes","")
            destination_address_prefix  = "VirtualNetwork"
        },
        "nsg-rule-02" = {    
            name                        = "allow-sql-inbound"
            priority                    = "110"
            direction                   = "Inbound"
            access                      = "Allow"
            protocol                    = "Tcp"
            source_port_range           = "*"
            destination_port_ranges     = ["1433"]
            source_address_prefix       = "*"
            destination_address_prefix  = "*"
        }
    }     
    depends_on = [module.network-rg]
}

 module "nsg-snet-associate-data-dev" {
     source                     = "../../modules/nsg-snet"
     subnet_id                  = module.dev-vnet.vnet_subnet_id[5]
     network_security_group_id  = module.nsg-data.nsg_id

     depends_on = [module.dev-vnet, module.nsg-data]
 }

 #########################################################
 #Create Network Security Group and rules for devOps
 #########################################################
module "nsg-devops" {
    source                           = "../../modules/nsg"

    # Used for database(s)
    nsg_name                         = "nsg-pms-devops"
    location                         = "${var.location}"
    resource_group_name              = module.network-rg.name
    tags                             = "${var.tags}"

    nsg-rules = {   
        "nsg-rule-01" = {    
            name                        = "allow-ssh-rdp-inbound"
            priority                    = "100"
            direction                   = "Inbound"
            access                      = "Allow"
            protocol                    = "Tcp"
            source_port_range           = "*"
            destination_port_ranges     = ["22", "3389"]
            source_address_prefix       = lookup(var.hub["bastion"], "address_prefixes","")
            destination_address_prefix  = "VirtualNetwork"
        }
    }     
    depends_on = [module.network-rg]
}
module "nsg-snet-associate-devops" {
     source                     = "../../modules/nsg-snet"
     subnet_id                  = module.hub-vnet.vnet_subnet_id[3]
     network_security_group_id  = module.nsg-devops.nsg_id

     depends_on = [module.hub-vnet, module.nsg-devops]
 }

########################################## 
# Create the Bastion Host
##########################################
module "bastion-host" {
    source                  = "../../modules/bastion-host"

    bastion_host_name       =   lookup(var.hub["bastion"], "bastion_name","")
    sku                     =   lookup(var.hub["bastion"], "bastion_sku","")
    location                =   "${var.location}"

    resource_group_name     =   module.management-rg.name
    ipconfig_name           =   "configuration"
    subnet_id               =   module.hub-vnet.vnet_subnet_id[1]
    public_ip_address_id    =   module.bastion-pip.public_ip_address_id   

    tags                    =   "${var.tags}"
    depends_on              =   [module.management-rg, module.bastion-pip, module.hub-vnet]
}

#######################################################################
# vm-windows Module is used to create the DevOps Build Agent
#######################################################################
module "vm-aci-devops-agent" {
      source                           = "../../modules/virtual-machines/virtual-machine"
      
      virtual_machine_name             = "${lookup(var.hub["devOps"], "vm_build_name","")}"
      nic_name                         = "nic-${lookup(var.hub["devOps"], "vm_build_name","")}"
      location                         = "${var.location}"
      resource_group_name              = module.aci-devops-rg.name
      ipconfig_name                    = "ipconfig1"
      subnet_id                        =  module.hub-vnet.vnet_subnet_id[3]
      
      private_ip_address_allocation    = "Dynamic"
      public_ip_address_id             = module.devops-pip.public_ip_address_id 
      #private_ip_address              = ""
      vm_size                          = lookup(var.hub["devOps"], "vm_build_size","")
      tags		                       = merge(tomap({"type" = "devOps"}), var.tags)

      # Uncomment this line to delete the OS disk automatically when deleting the VM
      delete_os_disk_on_termination    = true
      # Uncomment this line to delete the data disks automatically when deleting the VM
      delete_data_disks_on_termination = true

     
      publisher                        = "MicrosoftWindowsServer"
      offer                            = "WindowsServer"
      sku                              = "2019-Datacenter"
      storage_version                  = "latest"

      os_disk_name                     = "${lookup(var.hub["devOps"], "vm_build_name","")}-os-disk-01"
      caching                          = "ReadWrite"
      create_option                    = "FromImage"
      managed_disk_type                = "Premium_LRS"

      admin_username                   = "${var.vm_admin_username}"
      admin_password                   = "${var.vm_admin_password}"

      provision_vm_agent               = true
      depends_on                       = [module.hub-vnet, module.aci-devops-rg]
}

###########################################################################################
#                     Creating DNS Zone(s) and linking them up                            #
###########################################################################################
module "dns-zone-acr" {
    source                        = "../../modules/dns-zone"

    resource_group_name           = module.network-rg.name
    private_dns_zone_name         = "privatelink.azurecr.io"
    tags		                  = merge(tomap({"type" = "network"}), var.tags)

    depends_on                    = [module.network-rg]
}

module "dns-zone-webapp" {
    source                        = "../../modules/dns-zone"

    resource_group_name           = module.network-rg.name
    private_dns_zone_name         = "privatelink.azurewebsites.net"
    tags		                  = merge(tomap({"type" = "network"}), var.tags)

    depends_on                    = [module.network-rg]
}

module "dns-zone-sql" {
    source                        = "../../modules/dns-zone"

    resource_group_name           = module.network-rg.name
    private_dns_zone_name         = "privatelink.database.windows.net"
    tags		                  = merge(tomap({"type" = "network"}), var.tags)

    depends_on                    = [module.network-rg]
}

module "dns-zone-sa-blob" {
    source                        = "../../modules/dns-zone"

    resource_group_name           = module.network-rg.name
    private_dns_zone_name         = "privatelink.blob.core.windows.net"
    tags		                  = merge(tomap({"type" = "network"}), var.tags)

    depends_on                    = [module.network-rg]
}

module "dns-zone-sa-file" {
    source                        = "../../modules/dns-zone"

    resource_group_name           = module.network-rg.name
    private_dns_zone_name         = "privatelink.file.core.windows.net"
    tags		                  = merge(tomap({"type" = "network"}), var.tags)

    depends_on                    = [module.network-rg]
}

module "dns-zone-sa-queue" {
    source                        = "../../modules/dns-zone"

    resource_group_name           = module.network-rg.name
    private_dns_zone_name         = "privatelink.queue.core.windows.net"
    tags		                  = merge(tomap({"type" = "network"}), var.tags)

    depends_on                    = [module.network-rg]
}

module "dns-zone-apim" {
    source                        = "../../modules/dns-zone"

    resource_group_name           = module.network-rg.name
    private_dns_zone_name         = "privatelink.azure-api.net"
    tags		                  = merge(tomap({"type" = "network"}), var.tags)

    depends_on                    = [module.network-rg]
}

module "dns-zone-databricks" {
    source                        = "../../modules/dns-zone"

    resource_group_name           = module.network-rg.name
    private_dns_zone_name         = "privatelink.azuredatabricks.net"
    tags		                  = merge(tomap({"type" = "network"}), var.tags)

    depends_on                    = [module.network-rg]
}

module "vnet-dns-zone-acr-link" {
    source                            = "../../modules/vnet-dns-zone-link"

    resource_group_name               = module.network-rg.name
    vnet_dns_zone_link_name           = "${module.acr.acr_name}-vnetlink"
    private_dns_zone_name             = module.dns-zone-acr.private_dns_zone_name
    virtual_network_id                = module.hub-vnet.vnet_id
    registration_enabled              = "false"
    tags		                      = merge(tomap({"type" = "network"}), var.tags)

    depends_on                        = [module.hub-vnet, module.dns-zone-acr, module.acr]
}

module "acr-pvt-endpoint" {
    source                           = "../../modules/private-endpoint"

    pvt_endpoint_name                = "pvt-${module.acr.acr_name}"
    resource_group_name              = module.network-rg.name
    location                         = "${var.location}"
    subnet_id                        = module.hub-vnet.vnet_subnet_id[8] 
    private_service_connection_name  = "pvt-${module.acr.acr_name}-conn"
    is_manual_connection             = false
    private_connection_resource_id   = module.acr.acr_id
    subresource_name                 = "registry"
    tags		                     = merge(tomap({"type" = "network"}), var.tags)

    depends_on = [module.hub-vnet, module.dns-zone-kv, module.vnet-dns-zone-acr-link, module.acr]
}


module "dns-zone-kv" {
    source                        = "../../modules/dns-zone"

    resource_group_name           = module.network-rg.name
    private_dns_zone_name         = "privatelink.vaultcore.azure.net"
    tags		                  = merge(tomap({"type" = "network"}), var.tags)

    depends_on                    = [module.network-rg]
}

module "vnet-dns-zone-kv-link" {
    source                            = "../../modules/vnet-dns-zone-link"

    resource_group_name               = module.network-rg.name
    vnet_dns_zone_link_name           = "${module.key-vault.kv_name}-vnetlink"
    private_dns_zone_name             = module.dns-zone-kv.private_dns_zone_name
    virtual_network_id                = module.hub-vnet.vnet_id
    registration_enabled              = "false"
    tags		                      = merge(tomap({"type" = "network"}), var.tags)

    depends_on                        = [module.hub-vnet, module.dns-zone-kv, module.key-vault]
}


module "kv-pvt-endpoint" {
    source                           = "../../modules/private-endpoint"

    pvt_endpoint_name                = "pvt-${module.key-vault.kv_name}"
    resource_group_name              = module.network-rg.name
    location                         = "${var.location}"
    subnet_id                        = module.hub-vnet.vnet_subnet_id[8] 
    private_service_connection_name  = "pvt-${module.key-vault.kv_name}-conn"
    is_manual_connection             = false
    private_connection_resource_id   = module.key-vault.kv_id
    subresource_name                 = "vault"
    tags		                     = merge(tomap({"type" = "network"}), var.tags)

    depends_on = [module.hub-vnet, module.dns-zone-kv, module.vnet-dns-zone-kv-link, module.key-vault]
}



# module "build-agent-ext" {
#     source              = "../../modules/virtual-machines/vm-extensions/devops"

#     agent_name          =   "${module.vm-aci-devops-agent.vm_name}-agent"
#     vsts_account        =   "${lookup(var.hub["devOps"], "vsts_account","")}"
#     virtual_machine_id  =   module.vm-aci-devops-agent.vm_id
#     url                 =   "${lookup(var.hub["devOps"], "url","")}?${data.azurerm_storage_account_blob_container_sas.sas-token.sas}"
#     pat                 =   "${lookup(var.hub["devOps"], "pat","")}"
#     pool                =   "${lookup(var.hub["devOps"], "pool","")}"
#     agent_count         =   lookup(var.hub["devOps"], "agent_count", 1)
    

#     depends_on          = [module.vm-aci-devops-agent]
# }


# vm-windows Module is used to create Jumpbox Virtual Machines
module "vm-jumpbox-01" {
      source                           = "../../modules/virtual-machines/virtual-machine"

      virtual_machine_name             = "${lookup(var.hub["management"], "vm_jumpbox01_name","")}"
      nic_name                         = "nic-pms-${lookup(var.hub["management"], "vm_jumpbox01_name","")}"
      location                         = "${var.location}"
      resource_group_name              = module.management-rg.name
      ipconfig_name                    = "ipconfig1"
      subnet_id                        = module.hub-vnet.vnet_subnet_id[7]
      private_ip_address_allocation    = "Static"
      private_ip_address               = lookup(var.hub["management"], "vm_jumpbox01_private_ip","")
      vm_size                          = lookup(var.hub["management"], "vm_jumpbox01_size","")
      tags		                       = merge(tomap({"type" = "management"}), var.tags)
      
      # Uncomment this line to delete the OS disk automatically when deleting the VM
      delete_os_disk_on_termination    = true

      # Uncomment this line to delete the data disks automatically when deleting the VM
      delete_data_disks_on_termination = true

      publisher                        = "MicrosoftWindowsServer"
      offer                            = "WindowsServer"
      sku                              = "2019-Datacenter"
      storage_version                  = "latest"

      os_disk_name                     = "${lookup(var.hub["management"], "vm_jumpbox01_name","")}-os-disk-01"
      caching                          = "ReadWrite"
      create_option                    = "FromImage"
      managed_disk_type                = "Premium_LRS"

      admin_username                   = "${var.vm_admin_username}"
      admin_password                   = "${var.vm_admin_password}"

      provision_vm_agent               = true
      depends_on                       = [module.hub-vnet]
}

# module "diag-settings" {
#     source                     = "../../modules/diagnostic-settings"
#     log_analytics_workspace_id = module.log-analytics-workspace.id
#     //storage_account_id         = module.diagnostic-storage.id

#     targets_resource_id = [module.bastion-host.bastion_id,
#         module.hub-vnet.vnet_id,
#         module.dev-vnet.vnet_id,
#         module.qa-vnet.vnet_id,
#         module.prd-vnet.vnet_id,
#         module.gateway-pip.public_ip_address_id,
#         module.firewall-pip.public_ip_address_id,
#         module.bastion-pip.public_ip_address_id,
#         module.devops-pip.public_ip_address_id,
#         module.nsg-jumpbox-01.nsg_id,
#         module.nsg-bastion.nsg_id,
#         module.nsg-app.nsg_id,
#         module.nsg-web.nsg_id,
#         module.nsg-data.nsg_id,
#         module.nsg-devops.nsg_id,
#         module.vm-jumpbox-01.vm_id,

#         module.key-vault.kv_id,
#         module.acr.acr_id

#         #azurerm_service_plan.plan.id,
#         #azurerm_linux_web_app.linux_web_app.id,
#         # azurerm_storage_account.sa.id,
#         # join("", [azurerm_storage_account.sa.id, "/blobServices/default"]),
#         # join("", [azurerm_storage_account.sa.id, "/queueServices/default"]),
#         # join("", [azurerm_storage_account.sa.id, "/tableServices/default"]),
#         # join("", [azurerm_storage_account.sa.id, "/fileServices/default"])
#     ]
#     depends_on          = [module.log-analytics-workspace, 
#                             module.hub-vnet, 
#                             module.dev-vnet, 
#                             module.qa-vnet,
#                             module.prd-vnet, 
#                             module.bastion-host,
#                             module.vm-jumpbox-01,
#                             module.acr,
#                             module.key-vault,
#                             module.nsg-devops,
#                             module.nsg-data,
#                             module.nsg-web,
#                             module.nsg-app,
#                             module.nsg-bastion,
#                             module.nsg-jumpbox-01,
#                             module.bastion-pip,
#                             module.devops-pip,
#                             module.firewall-pip,
#                             module.gateway-pip
#                           ]
# }