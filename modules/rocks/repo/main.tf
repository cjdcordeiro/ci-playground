# --- boilerplate code ---
terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "5.34.0"
    }
  }
}
# --- end of boilerplate code ---

# --- team-specific repo configurations ---
variable "repo-name" {}
variable "repo-description" {}
variable "repo-homepage" {}
variable "repo-skip-secrets" {}
variable "repo-teams" {}
variable "repo-admin-team" {}
variable "repo-pr-approving-review-count" {}
variable "team-labels" {}
variable "team-jira-url" {}
# variable "team-secret-x" {}
variable "repo-visibility" {
  type    = string
  default = "public"

  validation {
    condition     = contains(["public", "internal"], var.repo-visibility)
    error_message = "Visibility must be either \"public\" or \"internal\"."
  }
}
variable "GITHUB_ORG" {}

# Repository settings
resource "github_repository" "this-repo" {
  name         = var.repo-name
  homepage_url = var.repo-homepage
  visibility   = var.repo-visibility
  description  = replace(chomp(var.repo-description), "\n", " ")

  allow_merge_commit     = false
  allow_squash_merge     = true
  allow_rebase_merge     = false
  allow_auto_merge       = false
  allow_update_branch    = true
  delete_branch_on_merge = true

  has_issues      = true
  has_discussions = false
  has_projects    = false
  has_wiki        = false
  has_downloads   = false

  vulnerability_alerts = true

  lifecycle {
    ignore_changes = [topics, visibility, pages]
    # Prevent unintentional destroys
    prevent_destroy = true
  }
}

# Repository teams
resource "github_team_repository" "this-repo-teams" {
  for_each   = toset(var.repo-teams)
  repository = var.repo-name
  team_id    = each.value
  permission = "maintain"
}
resource "github_team_repository" "this-repo-admin-team" {
  repository = var.repo-name
  team_id    = var.repo-admin-team
  permission = "admin"
}

# Labels
resource "github_issue_label" "label" {
  for_each = {
    for l in var.team-labels : l.name => l
  }
  repository  = var.repo-name
  name        = each.value.name
  color       = each.value.color
  description = each.value.description
}

# Secrets
resource "github_actions_secret" "jira_url" {
  repository      = var.repo-name
  secret_name     = "JIRA_URL"
  plaintext_value = var.team-jira-url
}
# resource "github_actions_secret" "x" {
#   count           = var.repo-skip-secrets ? 0 : 1
#   repository      = var.repo-name
#   secret_name     = "SECRET_X"
#   plaintext_value = var.team-secret-x
# }

# Branch protection rules
resource "github_branch_protection" "main" {
  repository_id = github_repository.this-repo.node_id

  pattern = "main"

  enforce_admins   = true
  allows_deletions = false

  allows_force_pushes = false
  # Exception to the rule
  force_push_bypassers = [
    "${var.GITHUB_ORG}/${var.repo-admin-team}"
  ]

  require_signed_commits          = false
  required_linear_history         = true
  require_conversation_resolution = true

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    pull_request_bypassers = [
      "${var.GITHUB_ORG}/${var.repo-admin-team}"
    ]
    require_code_owner_reviews      = true
    required_approving_review_count = var.repo-pr-approving-review-count
  }
}
# --- end of team-specific repo configurations ---
