# Terraform

<p align="center">
  <a href="https://github.com/jae-labs/terraform/actions/workflows/ci.yml"><img src="https://github.com/jae-labs/terraform/actions/workflows/ci.yml/badge.svg?branch=main" alt="CI"></a>
  <a href="https://github.com/jae-labs/terraform/actions/workflows/github-apply.yml"><img src="https://github.com/jae-labs/terraform/actions/workflows/github-apply.yml/badge.svg?branch=main" alt="GitHub Apply"></a>
  <a href="https://github.com/jae-labs/terraform/actions/workflows/cloudflare-apply.yml"><img src="https://github.com/jae-labs/terraform/actions/workflows/cloudflare-apply.yml/badge.svg?branch=main" alt="Cloudflare Apply"></a>
  <a href="https://github.com/jae-labs/terraform/actions/workflows/doppler-apply.yml"><img src="https://github.com/jae-labs/terraform/actions/workflows/doppler-apply.yml/badge.svg?branch=main" alt="Doppler Apply"></a>
  <a href="https://github.com/jae-labs/terraform/actions/workflows/oci-apply.yml"><img src="https://github.com/jae-labs/terraform/actions/workflows/oci-apply.yml/badge.svg?branch=main" alt="OCI Apply"></a>
  <a href="https://developer.hashicorp.com/terraform"><img src="https://img.shields.io/badge/terraform-%3E%3D%201.5-844FBA?logo=terraform&logoColor=white" alt="Terraform >= 1.5"></a>
</p>

This repository is the source of truth for all `jae-labs` infrastructure as code. It currently manages GitHub organization config, Cloudflare DNS and Pages, Doppler secrets infrastructure, and OCI infrastructure. Changes are split by root module, validated in CI, and auto-applied on merge to `main`. More modules and infrastructure components will be added here over time.

## What this repo manages

| Root module | Purpose |
|---|---|
| `github/` | Org settings, members, teams, repositories, environments, branch protection |
| `cloudflare/` | Zones, DNS records, account members, Workers KV, Pages projects/domains |
| `doppler/` | Projects, environments, groups, access grants |
| `oci/` | Flat OCI stack: network, security rules, compute, object storage |

## How it works

- Each root module has isolated remote state in PostgreSQL with its own backend schema.
- All domains (`github/`, `cloudflare/`, `doppler/`, and `oci/`) are flat and self-contained root modules.
- GitHub Actions runs format, lint, and validation checks on pull requests.
- Merges to `main` trigger path-filtered applies for only the affected root module.

Architecture, state layout, and repo structure live in [docs/architecture.md](docs/architecture.md).

## Quick start

### Prerequisites

- Terraform `>= 1.5`
- `PG_CONN_STR` pointing to the Terraform PostgreSQL backend
- Provider auth:
  - GitHub: `GITHUB_TOKEN`
  - Cloudflare: `CLOUDFLARE_API_TOKEN`
  - Doppler: `DOPPLER_TOKEN`
  - OCI: `OCI_TENANCY_OCID`, `OCI_USER_OCID`, `OCI_FINGERPRINT`, `OCI_REGION`, `OCI_PRIVATE_KEY_PATH`
- OCI stack inputs: `TF_VAR_compartment_id`, `TF_VAR_availability_domain`, `TF_VAR_ssh_authorized_keys`, `TF_VAR_ssh_ingress_cidr`

Run any root module locally:

```bash
cd github
terraform init
terraform plan
terraform apply
```

Swap `github` for `cloudflare`, `doppler`, or `oci` as needed.

## Validation

```bash
terraform fmt -check -recursive .
tflint --recursive --config=.tflint.hcl
for module in github cloudflare doppler oci; do
  (
    cd "${module}" && \
    terraform init -backend=false && \
    terraform validate
  )
done
```

## Bot contract

The [conCierge bot](https://github.com/jae-labs/conCIerge/tree/main) is a Slack-driven GitOps client for this repository. It does not own infrastructure state and it does not apply Terraform directly. Instead, it reads configuration from this repo, edits specific Terraform locals files through the GitHub API, opens pull requests, and relies on this repo's review and CI/CD flow to merge and apply changes.

In that model, this repo is the source of truth and the bot is an external client of its file layout and HCL structure.

`Contract` means the bot depends on specific file paths and specific HCL shapes staying stable. Those files are not just internal implementation details. They are an interface consumed by another system.

| File | Bot use |
|---|---|
| `github/locals.tf` | Repo, membership, and org settings CRUD |
| `cloudflare/locals.tf` | DNS record CRUD |

If you rename files, move blocks, or change key names or nesting in those files without updating the bot, Slack flows will break or generate invalid edits. Update the bot path constants and HCL editors in the [conCierge repo](https://github.com/jae-labs/conCIerge/tree/main) in the same change set.

## Documentation

| Document | Description |
|---|---|
| [docs/architecture.md](docs/architecture.md) | Repository layout, state model, apply flow, bot coupling |
| [docs/github-module.md](docs/github-module.md) | GitHub org module |
| [docs/cloudflare-module.md](docs/cloudflare-module.md) | Cloudflare module |
| [docs/doppler-module.md](docs/doppler-module.md) | Doppler module |
| [docs/oci-module.md](docs/oci-module.md) | OCI root module |
| [docs/ci-cd.md](docs/ci-cd.md) | GitHub Actions workflows and secrets |
