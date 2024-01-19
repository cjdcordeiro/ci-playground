# terraform {
#   required_providers {
#     github = {
#       source  = "integrations/github"
#       version = "5.34.0"
#     }
#   }
# }

# variable "GITHUB_TOKEN" {
#   type = string
#   description = "GitHub Personal Access Token used by Terraform"
# }

# provider "github" {
#   # alias = "canonical"
#   owner = "cjdcordeiro"
# #   owner = "canonical"
#   token = var.GITHUB_TOKEN
# }