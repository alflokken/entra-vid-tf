resource "azurerm_resource_group" "rg" {
  name     = "${var.resource_prefix}-rg"
  location = var.location
}

resource "azurerm_service_plan" "app_plan" {
  name                = "verifiedid-plan"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Windows"
  sku_name            = "B1"
}

# app service
resource "azurerm_windows_web_app" "app_service" {

  name                = "verifiedid-app-${random_string.suffix.result}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  service_plan_id     = azurerm_service_plan.app_plan.id
  https_only          = true

  site_config {
    application_stack {
      current_stack  = "dotnet"
      dotnet_version = "v8.0"
    }
  }

  identity {
    type = "SystemAssigned"
  }

  # App specific settings 
  app_settings = {
    # General Application Settings
    "AllowedUserAdminRole" = "UserAdmin"

    # AppSettings Section
    "AppSettings__CookieKey"              = "state"
    "AppSettings__CookieExpiresInSeconds" = "7200"
    "AppSettings__CacheExpiresInSeconds"  = "300"
    "AppSettings__tapLifetimeInMinutes"   = "60"
    "AppSettings__CompanyName"            = "Contoso"
    "AppSettings__BrandImage"             = "https://docs.microsoft.com/en-us/microsoft-365/media/contoso-overview/contoso-icon.png"
    "AppSettings__IdvUrl"                 = "https://trueidentityinc.azurewebsites.net/"
    "AppSettings__IdvLogoUrl"             = "https://woodgroveemployee.azurewebsites.net/assets/images/verification/true-id-card.png"
    "AppSettings__KeyVaultURI"            = azurerm_key_vault.kv.vault_uri
    "AppSettings__SigningKeyName"         = azurerm_key_vault_key.signing_key.name
    "AppSettings__SigningKeyVersion"      = azurerm_key_vault_key.signing_key.version
    "AppSettings__KeyIdentifier"          = "https://${azurerm_key_vault.kv.name}.vault.azure.net/keys/${azurerm_key_vault_key.signing_key.name}/${azurerm_key_vault_key.signing_key.version}"

    # AzureAd Section
    "AzureAd__Instance"     = "https://login.microsoftonline.com/"
    "AzureAd__TenantId"     = var.azure_metadata.tenant_id
    "AzureAd__ClientId"     = azuread_application.app.client_id
    "AzureAd__ClientSecret" = azuread_application_password.app_password.value
    "AzureAd__CallbackPath" = "/signin-oidc"
    "AzureAd__TapGroupName" = azuread_group.tap_group.display_name
    "AzureAd__Domain"       = local.primary_domain

    # VerifiedID Section
    "VerifiedID__ApiEndpoint"                      = "https://verifiedid.did.msidentity.com/v1.0/verifiableCredentials/"
    "VerifiedID__TenantId"                         = var.azure_metadata.tenant_id
    "VerifiedID__Authority"                        = "https://login.microsoftonline.com/"
    "VerifiedID__scope"                            = "3db474b9-6a0c-4840-96ac-1fceb342124f/.default"
    "VerifiedID__ManagedIdentity"                  = "false"
    "VerifiedID__ClientId"                         = azuread_application.app.client_id
    "VerifiedID__ClientSecret"                     = azuread_application_password.app_password.value
    "VerifiedID__CertificateName"                  = "" #[MAKE EMPTY WHEN NOT USED Or instead of client secret: Enter here the name of a certificate (from the user cert store) as registered with your application]
    "VerifiedID__client_name"                      = "Onboard with TAP sample"
    "VerifiedID__Purpose"                          = "To prove your identity"
    "VerifiedID__DidAuthority"                     = var.did_authority
    "VerifiedID__includeQRCode"                    = "false"
    "VerifiedID__includeReceipt"                   = "true"
    "VerifiedID__allowRevoked"                     = "false"
    "VerifiedID__validateLinkedDomain"             = "true"
    "VerifiedID__CredentialType"                   = "TrueIdentity"
    "VerifiedID__acceptedIssuers"                  = "did:web:did.woodgrovedemo.com"
    "VerifiedID__client_name_guest"                = "Guest Account Onboarding"
    "VerifiedID__Purpose_guest"                    = "To prove your employment"
    "VerifiedID__CredentialTypeGuest"              = "VerifiedEmployee"
    "VerifiedID__GuestEmailClaimName"              = "mail"
    "VerifiedID__GuestDisplayNameClaimName"        = "displayName"
    "VerifiedID__FaceCheckRequiredForGuest"        = "false"
    "VerifiedID__sourcePhotoClaimName"             = "photo"
    "VerifiedID__matchConfidenceThreshold"         = "70"
    "VerifiedID__updateGuestUserProfilefromClaims" = "false"
  }
}

#  Deploy code from public repo
resource "azurerm_app_service_source_control" "github_source" {
  app_id                 = azurerm_windows_web_app.app_service.id
  repo_url               = "https://github.com/alflokken/active-directory-verifiable-credentials-dotnet"
  branch                 =  "5-onboard-with-tap" #"6-woodgrove-helpdesk"
  use_manual_integration = true
  use_mercurial          = false
}