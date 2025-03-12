# Deploy Entra Verified ID Sample Application with Terraform

This Terraform configuration automates setup and deployment of the [Microsoft Entra Verified ID sample application](https://github.com/Azure-Samples/active-directory-verifiable-credentials-dotnet/tree/main/5-onboard-with-tap) for Employee or Guest Onboarding (onboarding with TAP) to Azure App Service.

## Pre-requisites

- Entra ID [Terraform application registration](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/guides/service_principal_client_secret#setting-up-an-application-and-service-principal) (service principal)
   - With the following application API permissions: 
      - Application.ReadWrite.All, AppRoleAssignment.ReadWrite.All, Directory.ReadWrite.All, Group.ReadWrite.All and User.Read
   - Contributor role on the Azure subscription.
- Ensure Entra Verified ID is configured.
   - Follow the [documented tutorials](https://learn.microsoft.com/en-us/entra/verified-id/verifiable-credentials-configure-tenant-quick) to set up Entra Verified ID itself.
- Enable Temporary Access Pass (TAP).
   - Entra portal → Protection → Authentication Methods → Temporary Access Pass
- Enable Self-Service Password Reset (SSPR).
   - Entra portal → Protection → Password reset.



## Setup

Create a `terraform.tfvars` file with your specific values.
```hcl
did_authority        = "did:web:...your name..." 

azure_metadata = {
  client_id       = "your-client-id"
  tenant_id       = "your-tenant-id"
  subscription_id = "your-subscription-id"
}

client_secret = "your-client-secret"

admin_user_object_id = "user-object-id"
```
_See variables.tf for all available variables and their descriptions._


## Deployment

Follow these steps to deploy the application:

1. **Clone the Repository:**

       git clone <repository-url>

2. **Initialize Terraform:**

       terraform init

3. **Deploy Infrastructure and App Settings:**

       terraform apply

      *Note:* The application code is deployed from a public repository as part of the configuration.

4. **Access the Application:**

   The application is deployed to an Azure App Service. The URL is displayed in the output of the `terraform apply` command.

   The application might take a few minutes to start up. See the deployment status in the Azure portal:
   - App Service → Deployment Center → Logs

## Troubleshooting
You can view app logging information in the Log stream if you do the following:

- Go to Development Tools, then Extensions
- Select + Add and add ASP.NET Core Logging Integration extension
- Go to Log stream and set Log level drop down filter to verbose

The Log Stream console will now display logs from the deployed application. Remember to disable the extension after troubleshooting.

## Cleaning Up

To remove all resources created by this Terraform configuration:

       terraform destroy