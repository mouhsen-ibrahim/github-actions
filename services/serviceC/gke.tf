variable "project_id" {
  description = "GCP project ID that hosts the GKE cluster"
  type        = string
  default     = "github-actions-472416"
}

variable "region" {
  description = "Region where the regional GKE cluster will run"
  type        = string
  default     = "eu-central3"
}

variable "cluster_name" {
  description = "Name of the GKE cluster"
  type        = string
  default     = "services"
}

variable "release_channel" {
  description = "GKE release channel (RAPID, REGULAR, STABLE, UNSPECIFIED)"
  type        = string
  default     = "REGULAR"
}

variable "node_machine_type" {
  description = "Machine type for nodes in the default node pool"
  type        = string
  default     = "e2-standard-4"
}

variable "min_nodes" {
  description = "Minimum number of nodes to create in the default node pool"
  type        = number
  default     = 0
}

variable "max_nodes" {
  description = "Maximum number of nodes to create in the default node pool"
  type        = number
  default     = 1
}

provider "google" {
  project = var.project_id
  region  = var.region
}

locals {
  env = terraform.workspace
  cluster_name = local.env == "prod" ? var.cluster_name : "${local.env}-${var.cluster_name}"
}

resource "google_container_cluster" "services" {
  name     = local.cluster_name
  location = var.region

  remove_default_node_pool = true
  initial_node_count       = 0

  release_channel {
    channel = var.release_channel
  }

  master_auth {
    client_certificate_config {
      issue_client_certificate = false
    }
  }
}

locals {
  
}

resource "google_container_node_pool" "primary_nodes" {
  name     = "${local.cluster_name}-primary"
  location = var.region
  cluster  = google_container_cluster.services.name

  autoscaling {
    min_node_count = var.min_nodes
    max_node_count = var.max_nodes
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  node_config {
    machine_type = var.node_machine_type
    oauth_scopes = ["https://www.googleapis.com/auth/cloud-platform"]

    metadata = {
      disable-legacy-endpoints = "true"
    }
  }
}

output "servicec_gke_cluster_name" {
  description = "Name of the created GKE cluster"
  value       = google_container_cluster.services.name
}

output "servicec_gke_cluster_endpoint" {
  description = "Endpoint of the created GKE cluster"
  value       = google_container_cluster.services.endpoint
}

output "servicec_gke_cluster_ca_certificate" {
  description = "Base64 encoded public certificate for the cluster's CA"
  value       = google_container_cluster.services.master_auth[0].cluster_ca_certificate
  sensitive   = true
}
