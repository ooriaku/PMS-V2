resource "azurerm_virtual_machine_extension" "vm-extensions" {
  name                 = var.virtual_machine_name
  virtual_machine_id   = var.virtual_machine_id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"
  tags                 = merge(var.tags, tomap({ "firstapply" = timestamp() }))
  settings = <<SETTINGS
    {
        "commandToExecute": "powershell Add-WindowsFeature Web-Server; powershell Add-Content -Path \"C:\\inetpub\\wwwroot\\Default.htm\" -Value $($env:computername)"
    }
SETTINGS

lifecycle {
		ignore_changes = [tags]
	}
}