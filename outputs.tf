output "app_service_url" {
  value       = "https://${azurerm_windows_web_app.app_service.default_hostname}"
  description = "The URL to access the deployed application"
}

output "application_display_name" {
  value = azuread_application.app.display_name
}

output "key_vault_name" {
  value = azurerm_key_vault.kv.name
}

output "appservice_name" {
  value = azurerm_windows_web_app.app_service.name
}

output "tap_group_name" {
  value = azuread_group.tap_group.display_name
}