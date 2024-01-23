# EE repos as code

## Proposed structure

```
├── .github/
├── modules
│   └── <team-name>
│       ├── main.tf
│       ├── repo
│       │   └── main.tf
│       └── terragrunt.hcl
└── terragrunt.hcl
```

`terragrunt.hcl`: a top-level Terragrunt file that holds all the common
settings for all repos in the **organisation**. For example:

- labels that should be in all repos,
- the GitHub provider configuration that should be applied for all modules,
- etc.

`modules/<team-name>`: modules path, with one folder per team.

`modules/<team-name>/terragrunt.hcl`: a team-level Terragrunt file that holds
all the common settings for all repos in the **team**. For example:

- the list of repos for that team,
- the list of issue labels to set for each team repo,
- the GitHub teams to be added to each repo,
- etc.

`modules/<team-name>/main.tf`: definition of the team's Terraform module.

`modules/<team-name>/repo/main.tf`: this path holds the actual settings for
each team repo. The folder name `repo` simply alludes to the fact that this is a standard repo. Other folders, with other `main.tf` files inside, can also be created for managing repos that are not considered "standard" (e.g. a template repo).

## Managing the repos

### Requirements

- terraform
- terragrunt

(see <https://terragrunt.gruntwork.io/docs/getting-started/install/>)

### All org repos

To manage all the org repos at the same time, make sure you are at the project
root, and then run:

```bash
# NOTE: you should export the TF_VAR_* variables first, e.g.
# export TF_VAR_GITHUB_TOKEN="$(cat my_pat)"
terragrunt run-all init
terragrunt run-all plan
terragrunt run-all apply
```

### Only the team repos

To manage only your team's repos, make sure you are inside your team's folder
(i.e. `cd modules/<team-name>`) and then run:

```bash
# Drop the "run-all"
terragrunt init
terragrunt plan
terragrunt apply
```

## Open questions

1. How to test changes to the plans? We should make sure that an unintentional
typo ends up removing all our repos.
