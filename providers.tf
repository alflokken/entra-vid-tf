terraform {
  required_version = ">= 1.11.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.21.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.1.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.13"
    }
  }
}

provider "azuread" {
  tenant_id     = var.azure_metadata.tenant_id
  client_id     = var.azure_metadata.client_id
  client_secret = var.client_secret
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = false # avoid waiting for purge
      recover_soft_deleted_key_vaults = true
    }
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
  tenant_id       = var.azure_metadata.tenant_id
  client_id       = var.azure_metadata.client_id
  client_secret   = var.client_secret
  subscription_id = var.azure_metadata.subscription_id
}