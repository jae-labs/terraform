# Terraform

IaC for managing the [jae-labs](https://github.com/jae-labs) GitHub organization and Doppler secrets.

## Architecture

```
github/          # root module - GitHub org, members, teams, repos, branch protection, environments
doppler/         # root module - Doppler projects, environments, groups
modules/github/  # reusable module for GitHub resources
modules/doppler/ # reusable module for Doppler resources
scripts/         # bootstrap script for GCS backend setup
```

Each root module has independent state stored in GCS (`gh-jae-labs-terraform` bucket).

## Prerequisites

- Terraform >= 1.5
- `GITHUB_TOKEN` env var (fine-grained PAT with org admin + repo admin + members read/write)
- `DOPPLER_TOKEN` env var (personal token from Doppler account settings)
- `GOOGLE_APPLICATION_CREDENTIALS` pointing to a GCP service account key for GCS backend

## Usage

```bash
# first time only
bash scripts/bootstrap.sh

# github
cd github
terraform init
terraform plan
terraform apply

# doppler
cd doppler
terraform init
terraform plan
terraform apply
```

## Adding a repo

Add an entry to `github/locals.tf` under `repos`, push to `main`. The GitHub Action applies automatically.

## CI/CD

Merges to `main` that touch `github/` or `modules/github/` trigger `terraform apply` via GitHub Actions using a `production` environment with protected secrets.
