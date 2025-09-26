terraform {
  required_version = "1.13.1"
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "7.3.0"
    }
  }
  backend "azurerm" {
    use_azuread_auth     = true
    storage_account_name = "githubactionsterraform"
    resource_group_name  = "tf-state"
    container_name       = "services"
    key                  = "serviceC"
  }
}

provider "google" {
  project = var.project_id
}

variable "project_id" {
  description = "GCP project ID"
  type        = string
  default = "github-actions-472416"
}
