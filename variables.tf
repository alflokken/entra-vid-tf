variable "azure_metadata" {
  type = object({
    client_id       = string
    tenant_id       = string
    subscription_id = string
  })
}

variable "client_secret" {
  description = "value of the client secret"
  type        = string
  sensitive   = true
}

variable "did_authority" {
  description = "The DID Authority value from Entra Verified ID settings"
  type        = string
}

variable "admin_user_object_id" {
  description = "Object ID of the admin user who will be assigned the UserAdmin role"
  type        = string
}

variable "resource_prefix" {
  description = "Common prefix for resource names"
  type        = string
  default     = "verifiedid"
}

variable "tap_group_name" {
  description = "Name of the security group for TAP and SSPR"
  type        = string
  default     = "TAP-SSPR-Group"
}

variable "location" {
  description = "Azure region to deploy resources"
  type        = string
  default     = "norwayeast"
}

# did-onboarding app permissions
variable "graph_app_permissions" {
  type = list(object({
    resource_app_id = string
    role_id         = string
    type            = string
  }))
  default = [
    {
      resource_app_id = "00000003-0000-0000-c000-000000000000" # Microsoft Graph
      role_id         = "e1fe6dd8-ba31-4d61-89e7-88639da4683d" # User.Read
      type            = "Scope"
    },
    {
      resource_app_id = "00000003-0000-0000-c000-000000000000" # Microsoft Graph
      role_id         = "df021288-bdef-4463-88db-98f22de89214" # User.Read.All
      type            = "Role"
    },
    {
      resource_app_id = "00000003-0000-0000-c000-000000000000" # Microsoft Graph
      role_id         = "741f803b-c850-494e-b5df-cde7c675a1ca" # User.ReadWrite.All
      type            = "Role"
    },
    {
      resource_app_id = "00000003-0000-0000-c000-000000000000" # Microsoft Graph
      role_id         = "50483e42-d915-4231-9639-7fdb7fd190e5" # UserAuthenticationMethod.ReadWrite.All
      type            = "Role"
    },
    {
      resource_app_id = "00000003-0000-0000-c000-000000000000" # Microsoft Graph
      role_id         = "62a82d76-70ea-41e2-9197-370581804d09" # Group.ReadWrite.All
      type            = "Role"
    },
    {
      resource_app_id = "00000003-0000-0000-c000-000000000000" # Microsoft Graph
      role_id         = "09850681-111b-4a89-9bed-3f2cae46d706" # User.Invite.All
      type            = "Role"
    },
    {
      resource_app_id = "00000003-0000-0000-c000-000000000000" # Microsoft Graph
      role_id         = "925f1248-0f97-47b9-8ec8-538c54e01325" # User-LifeCycleInfo.ReadWrite.All
      type            = "Role"
    },
    {
      resource_app_id = "3db474b9-6a0c-4840-96ac-1fceb342124f" # Verifiable Credentials
      role_id         = "410607a4-22de-48a8-b35d-ad33c0c2e1bf" # VerifiableCredential.Create.PresentRequest
      type            = "Role"
    }
  ]
}