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
variable "team-labels" {}
variable "team-jira-url" {}

# Repository settings
resource "github_repository" "this-repo" {
  name         = var.repo-name
  homepage_url = var.repo-homepage
  description            = replace(chomp(var.repo-description), "\n", " ")

  allow_merge_commit     = false
  allow_squash_merge     = true
  allow_rebase_merge     = false
  allow_auto_merge       = false
  allow_update_branch    = true
  delete_branch_on_merge = true

  has_issues             = true
  has_discussions        = false
  has_projects           = false
  has_wiki               = false
  has_downloads          = false
  
  vulnerability_alerts   = true

  lifecycle {
      ignore_changes = [ topics, visibility, pages ]
  }
}

# Labels
resource "github_issue_label" "label" {
  for_each = {
      for l in var.team-labels : l.name => l
  }
  repository = var.repo-name
  name = each.value.name
  color = each.value.color
  description = each.value.description
}

# Secrets
resource "github_actions_secret" "jira_url" {
  repository             = var.repo-name
  secret_name            = "JIRA_URL"
  plaintext_value        = var.team-jira-url
}

# --- end of team-specific repo configurations ---
