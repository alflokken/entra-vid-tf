# Create a security group for TAP and SSPR
resource "azuread_group" "tap_group" {
  display_name     = var.tap_group_name
  security_enabled = true
}

# create did-onboard application
resource "azuread_application" "app" {
  display_name = "${var.resource_prefix}-sample-app"


  web {
    implicit_grant {
      access_token_issuance_enabled = false
      id_token_issuance_enabled     = true
    }
    redirect_uris = [
      "https://localhost:5001/signin-oidc",
      "https://${local.app_hostname}/signin-oidc"
    ]
  }

  app_role {
    allowed_member_types = ["User"]
    description          = "UserAdmin role for managing users"
    display_name         = "UserAdmin"
    id                   = "00000000-0000-0000-0000-000000000001" # fixed value
    value                = "UserAdmin"
  }

  optional_claims {
    access_token {
      name = "groups"
    }

    id_token {
      essential = true
      name      = "groups"
    }
  }

  dynamic "required_resource_access" {
    for_each = local.grouped_permissions

    content {
      resource_app_id = required_resource_access.key

      dynamic "resource_access" {
        for_each = required_resource_access.value

        content {
          id   = resource_access.value.id
          type = resource_access.value.type
        }
      }
    }
  }
}

# Application Password (client secret)
resource "azuread_application_password" "app_password" {
  application_id = azuread_application.app.id
  display_name   = "TerraformGeneratedSecret"
  end_date       = timeadd(timestamp(), "8760h") # 1 year from now
  lifecycle {
    ignore_changes = [
      end_date
    ]
  }
}

# resolve did-onboard spn
resource "azuread_service_principal" "sp" {
  client_id    = azuread_application.app.client_id
  use_existing = true
}

# Assign app role to user
resource "azuread_app_role_assignment" "admin_role" {
  app_role_id         = "00000000-0000-0000-0000-000000000001"
  principal_object_id = var.admin_user_object_id
  resource_object_id  = azuread_service_principal.sp.object_id
}

# Consent app permissions (azuread_service_principal_delegated_permission_grant for delegated permissions)
resource "azuread_app_role_assignment" "role_permissions" {
  for_each = local.role_permissions

  app_role_id         = each.value.role_id
  principal_object_id = azuread_service_principal.sp.object_id
  resource_object_id  = data.azuread_service_principal.resource_apps[each.value.resource_app_id].object_id
}