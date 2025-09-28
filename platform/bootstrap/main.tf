terraform {
  required_version = "= 1.13.1"

  backend "azurerm" {
    use_azuread_auth     = true
    storage_account_name = "githubactionsterraform"
    resource_group_name  = "tf-state"
    container_name       = "platform"
    key                  = "bootstrap"
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "= 4.42.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "= 3.5.0"
    }
    github = {
      source  = "integrations/github"
      version = "= 6.6.0"
    }
    google = {
      source = "hashicorp/google"
      version = "7.3.0"
    }
    random = {
      source = "hashicorp/random"
      version = "3.7.2"
    }
  }
}

provider "google" {
  project = var.project_id
}

provider "azurerm" {
  features {}
  tenant_id       = "a76d71c9-6cc2-42f9-abbe-ca56098403bf"
  subscription_id = "50cf58a9-75e9-48c2-be1c-589c6fb298a2"
}

# Gets your Tenant & Subscription for secrets and defaults
data "azurerm_client_config" "current" {}

provider "azuread" {
  # Use the same tenant as your current Azure context
  tenant_id = "a76d71c9-6cc2-42f9-abbe-ca56098403bf"
}

# GitHub provider reads GITHUB_TOKEN from your environment; must have repo admin rights
provider "github" {
  owner = var.github_owner
}

# ---- Entra ID application + SP ----
resource "azuread_application_registration" "gh" {
  display_name = var.app_name
}

resource "azuread_service_principal" "gh" {
  client_id = azuread_application_registration.gh.client_id
}

# Pick the OIDC subject:
# Default is branch-based; override via var.oidc_subject for tags/environments.
locals {
  default_branch_subject = "repo:${var.github_owner}/${var.github_repository}:pull_request"
  oidc_subject           = var.oidc_subject != "" ? var.oidc_subject : local.default_branch_subject
}

resource "azuread_application_federated_identity_credential" "gh" {
  application_id = "/applications/${azuread_application_registration.gh.object_id}"
  display_name   = "github-${var.github_repository}"
  description    = "OIDC trust for GitHub Actions"
  audiences      = ["api://AzureADTokenExchange"]
  issuer         = "https://token.actions.githubusercontent.com"
  subject        = local.oidc_subject
}

resource "azuread_application_federated_identity_credential" "gh_main" {
  application_id = "/applications/${azuread_application_registration.gh.object_id}"
  display_name   = "github-main-${var.github_repository}"
  description    = "OIDC trust for GitHub Actions on main"
  audiences      = ["api://AzureADTokenExchange"]
  issuer         = "https://token.actions.githubusercontent.com"
  subject        = "repo:${var.github_owner}/${var.github_repository}:ref:refs/heads/main"
}

# ---- RBAC assignment (least privilege!) ----
resource "azurerm_role_assignment" "gh" {
  scope                = var.rbac_scope != "" ? var.rbac_scope : "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
  role_definition_name = var.role_definition_name
  principal_id         = azuread_service_principal.gh.object_id
  principal_type       = "ServicePrincipal"

  # Helps avoid race conditions right after SP creation
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "terraform_sp_storage_blob" {
  scope                = var.rbac_scope != "" ? var.rbac_scope : "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azuread_service_principal.gh.object_id
  principal_type       = "ServicePrincipal"
}

# ---- GitHub Actions secrets ----
resource "github_actions_secret" "azure_client_id" {
  repository      = var.github_repository
  secret_name     = "AZURE_CLIENT_ID"
  plaintext_value = azuread_application_registration.gh.client_id
}

resource "github_actions_secret" "azure_tenant_id" {
  repository      = var.github_repository
  secret_name     = "AZURE_TENANT_ID"
  plaintext_value = data.azurerm_client_config.current.tenant_id
}

resource "github_actions_secret" "azure_subscription_id" {
  repository      = var.github_repository
  secret_name     = "AZURE_SUBSCRIPTION_ID"
  plaintext_value = data.azurerm_client_config.current.subscription_id
}

output "app_client_id" {
  value     = azuread_application_registration.gh.client_id
  sensitive = true
}

output "service_principal_object_id" {
  value = azuread_service_principal.gh.object_id
}

output "federated_subject" {
  value = local.oidc_subject
}
