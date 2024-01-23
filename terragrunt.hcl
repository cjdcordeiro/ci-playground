# This file contains the common configurations for ALL repos
locals {
  org-labels = [
    { name : "good first issue", color : "00ff00", description : "Good for newcomers" },
  ]
}

# DRY: avoiding re-defining the github provider for every team
generate "provider" {
  path      = "DRY-provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
variable "GITHUB_TOKEN" {
  type        = string
  description = "GitHub Personal Access Token used by Terraform"
}
variable "GITHUB_ORG" {
  type        = string
  description = "GitHub org. Do NOT use 'canonical' for running tests."
}

provider "github" {
  owner = "cjdcordeiro-new-test"
  #   owner = var.GITHUB_ORG
  token = var.GITHUB_TOKEN
}
EOF
}
