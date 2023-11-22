output "service_plan_id" {
  description = "The id of the newly created app service plan"
  value       = azurerm_service_plan.service-plan.id
}
