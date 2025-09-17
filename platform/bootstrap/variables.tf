variable "app_name" {
  description = "Display name for the Entra ID app registration"
  type        = string
  default     = "gh-oidc-app"
}

variable "github_owner" {
  description = "GitHub org or user that owns the repository"
  type        = string
  default     = "mouhsen-ibrahim"
}

variable "github_repository" {
  description = "GitHub repository name (without owner)"
  type        = string
  default     = "github-actions"
}

variable "github_branch" {
  description = "Branch to trust (used if oidc_subject is empty)"
  type        = string
  default     = "main"
}

variable "oidc_subject" {
  description = <<EOT
(Optional) Full GitHub OIDC 'subject' to use instead of the default branch subject.
Examples:
- repo:OWNER/REPO:ref:refs/heads/main
- repo:OWNER/REPO:ref:refs/tags/v1.2.3
- repo:OWNER/REPO:environment:production
EOT
  type        = string
  default     = ""
}

variable "rbac_scope" {
  description = "Azure scope for the role assignment (subscription, resource group, or resource ID). Defaults to current subscription."
  type        = string
  default     = ""
}

variable "role_definition_name" {
  description = "RBAC role to assign to the SP at the given scope"
  type        = string
  default     = "Contributor"
}

variable "project_id" {
  description = "GCP project ID"
  type        = string
  default = "github-actions-472416"
}

variable "pool_id" {
  description = "Workload Identity Pool ID"
  type        = string
  default     = "gh-actions-pool"
}

variable "provider_id" {
  description = "Workload Identity Provider ID"
  type        = string
  default     = "github-oidc"
}

variable "sa_id" {
  description = "Service account ID (short name)"
  type        = string
  default     = "gh-actions-deployer"
}

variable "sa_roles" {
  description = "Project-level roles to grant the service account"
  type        = list(string)
  default     = [
    "roles/artifactregistry.writer",
    "roles/run.admin",
    "roles/iam.serviceAccountUser"
  ]
}
