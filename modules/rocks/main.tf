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

variable "team-repos" { type = map(any) }
variable "team-labels" { type = list(map(string)) }
variable "JIRA_URL" {
  type        = string
  description = "Jira Incoming webhook"
}
variable "OTHER_TEAM_SECRET" {
  type        = string
  description = "Some optional team secret"
}


module "team-repos-template" {
  source = "./repo"

  for_each                       = var.team-repos
  repo-name                      = each.key
  repo-homepage                  = each.value.homepage
  repo-visibility                = each.value.visibility
  repo-description               = each.value.description
  repo-skip-secrets              = each.value.skip_secrets
  repo-teams                     = each.value.teams
  repo-admin-team                = each.value.admin-team
  repo-pr-approving-review-count = each.value.pr-approving-review-count

  team-labels   = var.team-labels
  team-jira-url = var.JIRA_URL
  # team-secret-x     = var.OTHER_TEAM_SECRET

  GITHUB_ORG = var.GITHUB_ORG
}
