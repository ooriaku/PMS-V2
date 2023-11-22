# Custom script extension to install the DevOps agent
resource "azurerm_virtual_machine_extension" "install-devops-ext" {
  name                 = "${var.agent_name}"  
  virtual_machine_id   = "${var.virtual_machine_id}"  
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.9"

  settings = <<SETTINGS
	  {
		  "fileUris": ["${var.url}"],
		  "commandToExecute": "powershell.exe -ExecutionPolicy Unrestricted -File Install-DevOpsAgent.ps1 -DevOpsOrg ${var.vsts_account} -DevOpsPAT ${var.pat} -PoolName ${var.pool} -AgentName ${var.agent_name} -AgentCount ${var.agent_count}",
		  "timestamp" : "12"
	  }
	SETTINGS

  tags  = "${var.tags}"
}