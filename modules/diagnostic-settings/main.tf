// enable all diagnostic settings for a collection of resources
data "azurerm_monitor_diagnostic_categories" "categories" {
  count       = length(var.targets_resource_id)
  resource_id = var.targets_resource_id[count.index]
}

resource "azurerm_monitor_diagnostic_setting" "diagnostic-setting" {
  count                      = length(var.targets_resource_id)
  
  name                       = split("/", var.targets_resource_id[count.index])[length(split("/", var.targets_resource_id[count.index])) - 1]  
  
  target_resource_id         = data.azurerm_monitor_diagnostic_categories.categories[count.index].id
  log_analytics_workspace_id = var.log_analytics_workspace_id
  #storage_account_id         = var.storage_account_id

  dynamic "metric" {
    for_each = data.azurerm_monitor_diagnostic_categories.categories[count.index].metrics
    content {
      category = metric.value
      enabled  = true
    }
  }

   dynamic "log" {
    for_each = data.azurerm_monitor_diagnostic_categories.categories[count.index].logs
        content {
            category = log.value
            enabled  = true
        }
       
  }

  # dynamic "log" {
  #   for_each = data.azurerm_monitor_diagnostic_categories.categories[count.index].log_category_types
  #   content {
  #     category = log.value
  #     enabled  = true
  #   }
  # }
}