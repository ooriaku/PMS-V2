resource "azurerm_log_analytics_workspace" "law-workspace" {
  name                = var.la_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.sku					#"PerGB2018"
  retention_in_days   = var.retention_in_days	#30
  tags		          = merge(tomap({"type" = "management"}), var.tags)   
}

resource "azurerm_log_analytics_solution" "law-solution" {
  count                 = length(var.solutions)
  solution_name         = var.solutions[count.index].name
  location              = var.location
  resource_group_name   = var.resource_group_name
  workspace_resource_id = azurerm_log_analytics_workspace.law-workspace.id
  workspace_name        = azurerm_log_analytics_workspace.law-workspace.name
  tags		            = merge(tomap({"type" = "management"}), var.tags) 

  plan {
    publisher = var.solutions[count.index].publisher
    product   = var.solutions[count.index].product
  }
}
