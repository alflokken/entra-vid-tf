resource "azurerm_key_vault" "kv" {
  name                          = "${var.resource_prefix}-kv"
  location                      = azurerm_resource_group.rg.location
  resource_group_name           = azurerm_resource_group.rg.name
  tenant_id                     = var.azure_metadata.tenant_id
  sku_name                      = "standard"
  soft_delete_retention_days    = 7
  purge_protection_enabled      = false
  enable_rbac_authorization     = false
  public_network_access_enabled = true

  # App spn access
  access_policy {
    tenant_id = var.azure_metadata.tenant_id
    object_id = azuread_service_principal.sp.object_id

    key_permissions = [
      "Get",
      "Sign"
    ]
  }

  # terraform spn access
  access_policy {
    tenant_id = var.azure_metadata.tenant_id
    object_id = data.azuread_client_config.current.object_id

    key_permissions = [
      "Create",
      "Delete",
      "Get",
      "Purge",
      "Recover",
      "Update",
      "GetRotationPolicy"
    ]
  }

  depends_on = [azuread_service_principal.sp]
}

resource "azurerm_key_vault_key" "signing_key" {
  name         = "signing-key"
  key_vault_id = azurerm_key_vault.kv.id
  key_type     = "RSA"
  key_size     = 2048
  key_opts     = ["sign", "verify"]
}