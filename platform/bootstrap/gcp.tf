data "google_project" "this" {}

# Helpful APIs (STS & IAM Credentials) for WIF/impersonation
resource "google_project_service" "services" {
  for_each = toset([
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "sts.googleapis.com",
    "cloudresourcemanager.googleapis.com",
  ])
  project            = var.project_id
  service            = each.key
  disable_on_destroy = false
}

# 1) Workload Identity Pool
resource "google_iam_workload_identity_pool" "gh_pool" {
  project                   = var.project_id
  workload_identity_pool_id = var.pool_id
  display_name              = "GitHub Actions Pool"
  description               = "Federates GitHub OIDC tokens"
}

# 2) Workload Identity Provider for GitHub OIDC
resource "google_iam_workload_identity_pool_provider" "gh_provider" {
  project                             = var.project_id
  workload_identity_pool_id           = google_iam_workload_identity_pool.gh_pool.workload_identity_pool_id
  workload_identity_pool_provider_id  = var.provider_id
  display_name                        = "GitHub OIDC"
  description                         = "Accepts GitHub Actions OIDC tokens"
  attribute_mapping = {
    "google.subject"            = "assertion.sub"
    "attribute.actor"           = "assertion.actor"
    "attribute.repository"      = "assertion.repository"
    "attribute.repository_owner"= "assertion.repository_owner"
    "attribute.ref"             = "assertion.ref"
    "attribute.workflow"        = "assertion.workflow"
    "attribute.environment"     = "assertion.environment"
    "attribute.sha"             = "assertion.sha"
  }

  # Restrict which repos/branches can exchange tokens.
  # If you want ANY branch, set github_branch="*" (condition adapts below).
  attribute_condition = "assertion.repository == \"${var.github_owner}/${var.github_repository}\""

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
    # Tip: you can leave allowed_audiences unset (defaults are fine with the official action).
  }

  depends_on = [google_project_service.services]
}

# 3) Service account to impersonate from GitHub
resource "google_service_account" "ci" {
  account_id   = var.sa_id
  display_name = "GitHub Actions deployer"
}

# 4) Grant project roles to the service account (least privilege!)
resource "google_project_iam_member" "sa_project_roles" {
  for_each = toset(var.sa_roles)
  project  = var.project_id
  role     = each.value
  member   = "serviceAccount:${google_service_account.ci.email}"
}

# 5) Let tokens from your repo impersonate the service account
# principalSet identifies identities from the WIF pool filtered by attribute.repository
resource "google_service_account_iam_member" "wif_bind" {
  service_account_id = google_service_account.ci.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.gh_pool.name}/attribute.repository/${var.github_owner}/${var.github_repository}"
}

# Optional: also bind per-branch (only if you want an extra guard at IAM level).
# Not strictly necessary because attribute_condition already enforces it at the provider.
# Uncomment to add:
# resource "google_service_account_iam_member" "wif_bind_branch" {
#   service_account_id = google_service_account.ci.name
#   role               = "roles/iam.workloadIdentityUser"
#   member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.gh_pool.name}/attribute.repository/${var.github_owner}/${var.github_repo}/attribute.ref/refs/heads/${var.github_branch}"
# }

############################################
# outputs.tf
############################################
output "workload_identity_provider_full_name" {
  description = "Use this in your GitHub Actions 'workload_identity_provider' input"
  value       = "projects/${data.google_project.this.number}/locations/global/workloadIdentityPools/${var.pool_id}/providers/${var.provider_id}"
}

output "service_account_email" {
  value = google_service_account.ci.email
}

output "project_number" {
  value = data.google_project.this.number
}

resource "github_actions_secret" "gcp_project_id" {
  repository      = var.github_repository
  secret_name     = "GCP_PROJECT_ID"
  plaintext_value = data.google_project.this.project_id
}

resource "github_actions_secret" "gcp_workload_identity_provider" {
  repository      = var.github_repository
  secret_name     = "GCP_WORKLOAD_IDENTITY_PROVIDER"
  plaintext_value = "projects/${data.google_project.this.number}/locations/global/workloadIdentityPools/${var.pool_id}/providers/${var.provider_id}"
}

resource "github_actions_secret" "gcp_service_account" {
  repository      = var.github_repository
  secret_name     = "GCP_SERVICE_ACCOUNT"
  plaintext_value = google_service_account.ci.email
}

resource "random_string" "state" {
  length = 4
  special = false
  upper = false
}

resource "google_storage_bucket" "state" {
  name = "services-state-${random_string.state.result}"
  location = "EU"
}

resource "github_actions_secret" "state_bucket" {
  repository      = var.github_repository
  secret_name     = "GCP_BUCKET_NAME"
  plaintext_value = google_storage_bucket.state.name
}
