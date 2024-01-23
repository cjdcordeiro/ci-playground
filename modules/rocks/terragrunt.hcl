# --- boilerplate code ---
include "common" {
  path   = find_in_parent_folders()
  expose = true
}
# --- end of boilerplate code ---

locals {
  team-repos = {
    "test-repo-1" : {
      homepage : "homepage.url",
      visibility : "public", # or "internal"
      skip_secrets : true,
      # Use the DRY-github-teams.tf generator below to manage the GH teams
      teams : ["ROCKS"],
      admin-team : "ROCKS-admins",
      pr-approving-review-count : 1,
      description : <<-EOT
        repo description
      EOT
    },
  }

  team-labels = [
    # Prioritization
    { name : "Priority", color : "0DC903", description : "Look at me first" },

    # Statuses
    { name : "Blocked", color : "FE6D62", description : "Waiting for something external" },
    { name : "Decaying", color : "F0FB2B", description : "It's been a while, close or act on it" },
    { name : "Reviewed", color : "074BC6", description : "Supposedly ready for tuning or merging" },
    { name : "Duplicate", color : "cfd3d7", description : "This issue or pull request already exists" },

    # Types
    { name : "Bug", color : "D93F0B", description : "An undesired feature ;-)" },
    { name : "Polish", color : "E093FD", description : "Refactorings, etc" },
    { name : "Simple", color : "14BE88", description : "Nice for a quick look on a minute or two" },
    { name : "Documentation", color : "218bff", description : "Improvements or additions to documentation" },
    { name : "Question", color : "d876e3", description : "Further information is requested" },
    { name : "Invalid", color : "e4e669", description : "This doesn't seem right" },
  ]
}

inputs = {
  team-repos  = local.team-repos
  team-labels = concat(include.common.locals.org-labels, local.team-labels)
}

# DRY: avoiding re-defining the github teams for every repo
generate "github-teams" {
  path      = "DRY-github-teams.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
# Create the GH teams
resource "github_team" "ROCKS" {
  name        = "ROCKS"
  description = "The ROCKS team"
  privacy     = "closed"
}
resource "github_team" "ROCKS-admins" {
  name        = "ROCKS-admins"
  description = "The ROCKS team members with admin access to the ROCKS repos"
  privacy     = "closed"
}

# Add users to teams - NOTE: users must already exist in the org (ask IS)
resource "github_team_members" "ROCKS-team-members" {
  team_id  = github_team.ROCKS.id
  members {
    username = "cjdcordeiro"
    role     = "maintainer"
  }
  members {
    username = "ROCKsBot"
    role     = "member"
  }
}
resource "github_team_members" "ROCKS-admins-team-members" {
  team_id  = github_team.ROCKS-admins.id
  members {
    username = "cjdcordeiro"
    role     = "maintainer"
  }
}
EOF
}