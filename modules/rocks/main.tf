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

module "team-repos-template" {
  source           = "./repo"
  for_each         = var.team-repos
  repo-name        = each.key
  repo-homepage    = each.value.homepage
  repo-description = each.value.description
  team-labels      = var.team-labels
  team-jira-url    = var.JIRA_URL
}
