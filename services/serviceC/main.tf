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

resource "google_project_service" "services" {
  for_each = toset([
    "compute.googleapis.com",
  ])
  project            = var.project_id
  service            = each.key
  disable_on_destroy = false
}


data "google_project" "this" {}

resource "google_compute_network" "test" {
  auto_create_subnetworks = false
  description = "A test network"
  name = "net-test"
}

variable "project_id" {
  description = "GCP project ID"
  type        = string
  default = "github-actions-472416"
}
