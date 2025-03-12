# resolve domains
data "azuread_domains" "tenant" {}

# resolve spn object IDs
data "azuread_client_config" "current" {}
data "azuread_service_principal" "resource_apps" {
  for_each = toset(local.resource_app_ids)

  client_id = each.key
}

locals {
  # app service name
  app_hostname = "verifiedid-app-${random_string.suffix.result}.azurewebsites.net"

  # Get unique resource_app_ids
  resource_app_ids = distinct([for perm in var.graph_app_permissions : perm.resource_app_id])

  # tenant primary domain 
  primary_domain = [for d in data.azuread_domains.tenant.domains : d if d.default][0].domain_name

  # Group permissions by resource_app_id
  grouped_permissions = {
    for app_id in local.resource_app_ids : app_id => [
      for perm in var.graph_app_permissions : {
        id   = perm.role_id
        type = perm.type
      } if perm.resource_app_id == app_id
    ]
  }

  # Filter role type permissions
  role_permissions = {
    for idx, perm in var.graph_app_permissions :
    "${perm.resource_app_id}|${perm.role_id}" => perm
    if perm.type == "Role"
  }
}

# Random string for unique app service name
resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false

  keepers = {
    resource_group_id = azurerm_resource_group.rg.id
  }
}