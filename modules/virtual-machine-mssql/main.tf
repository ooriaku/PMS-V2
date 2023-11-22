resource "azurerm_mssql_virtual_machine_group" "example" {
  name                = "examplegroup"
  resource_group_name = "example-resources"
  location            = "West Europe"

  sql_image_offer = "SQL2017-WS2016"
  sql_image_sku   = "Developer"

  wsfc_domain_profile {
    fqdn                = "testdomain.com"
    cluster_subnet_type = "SingleSubnet"
  }
}

resource "azurerm_mssql_virtual_machine" "vm-sql" {
  virtual_machine_id               = var.virtual_machine_id
  sql_license_type                 = "PAYG"
  r_services_enabled               = true
  sql_connectivity_port            = 1433
  sql_connectivity_type            = "PRIVATE"
  sql_connectivity_update_password = "Password1234!"
  sql_connectivity_update_username = "sqllogin"

  wsfc_domain_credential {
    cluster_bootstrap_account_password = "P@ssw0rd1234!"
    cluster_operator_account_password  = "P@ssw0rd1234!"
    sql_service_account_password       = "P@ssw0rd1234!"
  }

  auto_patching {
    day_of_week                            = "Sunday"
    maintenance_window_duration_in_minutes = 60
    maintenance_window_starting_hour       = 2
  }
}
