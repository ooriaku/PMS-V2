terraform {

  #required_version = ">=0.12"
  required_version = ">=0.14.9"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0.0"
    }
    azuread = {
      source = "hashicorp/azuread"
    }
  }
}

provider "azurerm" {
  features {}
}


## Azure built-in roles
## https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles
data "azurerm_role_definition" "storage-role" {
    name = "Storage File Data SMB Share Contributor"
}

data "azurerm_virtual_network" "vnet" {
  name                = lookup(var.attr["networks"], "vnet_name","")
  resource_group_name = lookup(var.attr["networks"], "network_rg_name","")
}

data "azurerm_subnet" "avd01-snet" {
  name                 = lookup(var.attr["networks"], "avd01_snet_name","")
  virtual_network_name = lookup(var.attr["networks"], "vnet_name","")
  resource_group_name  = lookup(var.attr["networks"], "network_rg_name","")
}


module "mgmt-rg" {
      source              = "../../modules/resource-groups"

      location            = "${var.location}"
      resource_group_name = lookup(var.attr, "mgmt_rg_name","") 
      tags                = "${var.tags}"
}

module "host-rg" {
      source              = "../../modules/resource-groups"
      location            = "${var.location}"
      resource_group_name = lookup(var.attr, "host_rg_name","") 
      tags                = "${var.tags}"
}

module "sig-rg" {
      source              = "../../modules/resource-groups"
      location            = "${var.location}"
      resource_group_name = lookup(var.attr, "sig_rg_name","") 
      tags                = "${var.tags}"
}


module "file-storage" {
    source                      =   "../../modules/storage/storage-share"

    storage_account_name        =   "${lookup(var.attr["storage"], "storage_name","")}"
    resource_group_name         =   module.mgmt-rg.name
    location                    =   "${var.location}"
    share_storage_account_name  =   "${lookup(var.attr["storage"], "share_storage_account_name","")}"
    quota                       =   lookup(var.attr["storage"], "quota",100)
    role_definition_id          =   data.azurerm_role_definition.storage-role.id
    principal_id                =   azuread_group.aad_group.id

    tags                        = "${var.tags}"
    depends_on                  = [module.mgmt-rg]
}

module "compute-gallery" {
     source                     =  "../../modules/avd/avd-shared-galleries"
     sig_name                   =  "${lookup(var.attr["gallery"], "sig_name","")}"
     resource_group_name        =  module.sig-rg.name
     location                   =  "${var.location}"
     tags                       =  "${var.tags}"
     depends_on                 = [module.sig-rg]
}

# vm-windows Module is used to create App 01 Virtual Machines
module "vm-avd" {
      source                           = "../../modules/virtual-machines/virtual-machine"
      count                            =  lookup(var.attr["host"], "vm_host_count", 1)

     
      virtual_machine_name             = "${lookup(var.attr["host"], "virtual_machine_name","")}${count.index + 1}"  
      nic_name                         = "nic-pms-avd-${lookup(var.attr["host"], "virtual_machine_name","")}${count.index + 1}"
      location                         = "${var.location}"
      resource_group_name              = module.host-rg.name

      ipconfig_name                    = "ipconfig1"
      subnet_id                        = data.azurerm_subnet.avd01-snet.id
      private_ip_address_allocation    = "Dynamic"
      
      vm_size                          = lookup(var.attr["host"], "vm_host_size","")
      tags		                       = merge(tomap({"type" = "avd"}), var.tags)
      
      # Uncomment this line to delete the OS disk automatically when deleting the VM
      delete_os_disk_on_termination    = true

      # Uncomment this line to delete the data disks automatically when deleting the VM
      delete_data_disks_on_termination = true

      publisher                        = "MicrosoftWindowsDesktop"
      offer                            = "Windows-10"
      sku                              = "20h2-evd"
      storage_version                  = "latest"

      os_disk_name                     = "${lookup(var.attr["host"], "virtual_machine_name","")}${count.index + 1}-os-disk-01"
      caching                          = "ReadWrite"
      create_option                    = "FromImage"
      managed_disk_type                = "Standard_LRS"

      admin_username                   = "${var.vm_admin_username}"
      admin_password                   = "${var.vm_admin_password}"
        
      provision_vm_agent               = true   
      depends_on                       = [module.host-rg]
}