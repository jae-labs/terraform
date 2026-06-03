# Terraform

<p align="center">
  <a href="https://github.com/jae-labs/terraform/actions/workflows/ci.yml"><img src="https://github.com/jae-labs/terraform/actions/workflows/ci.yml/badge.svg?branch=main" alt="CI"></a>
  <a href="https://github.com/jae-labs/terraform/actions/workflows/github-apply.yml"><img src="https://github.com/jae-labs/terraform/actions/workflows/github-apply.yml/badge.svg?branch=main" alt="GitHub Apply"></a>
  <a href="https://github.com/jae-labs/terraform/actions/workflows/cloudflare-apply.yml"><img src="https://github.com/jae-labs/terraform/actions/workflows/cloudflare-apply.yml/badge.svg?branch=main" alt="Cloudflare Apply"></a>
  <a href="https://github.com/jae-labs/terraform/actions/workflows/doppler-apply.yml"><img src="https://github.com/jae-labs/terraform/actions/workflows/doppler-apply.yml/badge.svg?branch=main" alt="Doppler Apply"></a>
  <a href="https://github.com/jae-labs/terraform/actions/workflows/oci-apply.yml"><img src="https://github.com/jae-labs/terraform/actions/workflows/oci-apply.yml/badge.svg?branch=main" alt="OCI Apply"></a>
  <a href="https://github.com/jae-labs/terraform/actions/workflows/tailscale-apply.yml"><img src="https://github.com/jae-labs/terraform/actions/workflows/tailscale-apply.yml/badge.svg?branch=main" alt="Tailscale Apply"></a>
  <a href="https://developer.hashicorp.com/terraform"><img src="https://img.shields.io/badge/terraform-%3E%3D%201.5-844FBA?logo=terraform&logoColor=white" alt="Terraform >= 1.5"></a>
</p>

This repository is the source of truth for all `jae-labs` infrastructure as code. It manages GitHub organization config, Cloudflare DNS and Pages, Doppler secrets infrastructure, OCI infrastructure, Sentry organization/project config, and Tailscale preferences/ACLs. Changes are split by provider root, validated in CI, and auto-applied on merge to `main`.

## What this repo manages

| Path | Purpose |
|---|---|
| `github/` | Org settings, members, teams, repositories, environments, branch protection |
| `cloudflare/` | Zones, DNS records, account members, Workers KV, Pages projects/domains |
| `doppler/` | Projects, environments, groups, access grants |
| `oci/` | Flat OCI stack: network, security rules, compute, object storage |
| `sentry/` | Sentry organization, teams, projects, client keys |
| `tailscale/` | Tailscale MagicDNS, nameservers, search paths, global preferences, and ACL policies |

## How it works

- Each provider root has isolated remote state in PostgreSQL with its own backend schema.
- All domains (`github/`, `cloudflare/`, `doppler/`, `oci/`, `sentry/`, and `tailscale/`) are flat and self-contained Terraform roots.
- GitHub Actions runs format, lint, and validation checks on pull requests.
- Merges to `main` trigger path-filtered applies for only the affected provider root.

Architecture, state layout, and repo structure live in [docs/architecture.md](docs/architecture.md). Provider-root conventions live in [docs/providers.md](docs/providers.md).

## Quick start

### Prerequisites

- Terraform `>= 1.5`
- `PG_CONN_STR` pointing to the Terraform PostgreSQL backend
- Provider auth:
  - GitHub: `GITHUB_TOKEN`
  - Cloudflare: `CLOUDFLARE_API_TOKEN`
  - Doppler: `DOPPLER_TOKEN`
  - OCI: `OCI_TENANCY_OCID`, `OCI_USER_OCID`, `OCI_FINGERPRINT`, `OCI_REGION`, `OCI_PRIVATE_KEY_PATH`
  - Sentry: `SENTRY_AUTH_TOKEN`
  - Tailscale: `TAILSCALE_API_KEY`
- OCI stack inputs: `TF_VAR_compartment_id`, `TF_VAR_availability_domain`, `TF_VAR_ssh_authorized_keys`, `TF_VAR_ssh_ingress_cidr`

Run any provider root locally:

```bash
cd github
terraform init
terraform plan
terraform apply
```

Swap `github` for `cloudflare`, `doppler`, `oci`, `tailscale`, or `sentry` as needed.

## Validation

```bash
terraform fmt -check -recursive .
tflint --recursive --config=.tflint.hcl
for root in github cloudflare doppler oci tailscale sentry; do
  (
    cd "${root}" && \
    terraform init -backend=false && \
    terraform validate
  )
done
```

## Bot contract

The [conCierge bot](https://github.com/jae-labs/conCIerge/tree/main) is a Slack-driven GitOps client for this repository. It does not own infrastructure state and it does not apply Terraform directly. Instead, it reads configuration from this repo, edits specific Terraform locals files through the GitHub API, opens pull requests, and relies on this repo's review and CI/CD flow to merge and apply changes.

In that model, this repo is the source of truth and the bot is an external client of its file layout, locals structure, and `concierge-schema.yaml`.

`Contract` means the bot depends on `concierge-schema.yaml` matching the editable locals data it exposes. Sentry is not listed here because it is not bot-exposed yet. The schema and those locals files are not internal implementation details. They are an interface consumed by another system.

| File | Bot use |
|---|---|
| `concierge-schema.yaml` | Declares editable resources, field paths, actions, and key sources |
| `github/locals.tf` | Repo, membership, and org settings CRUD backing the GitHub schema resources |
| `cloudflare/locals.tf` | DNS record CRUD |
| `doppler/locals.tf` | Doppler project CRUD |

If you rename files, move blocks, or change key names, nesting, or field paths in those files without updating `concierge-schema.yaml`, Slack flows will break or generate invalid edits. Update the schema in the same change set, and keep the bot aligned with both.

## Documentation

| Document | Description |
|---|---|
| [docs/architecture.md](docs/architecture.md) | Repository layout, state model, apply flow, bot coupling |
| [docs/providers.md](docs/providers.md) | Generic provider-root model, `locals.tf`, and concierge contract |
| [docs/ci-cd.md](docs/ci-cd.md) | GitHub Actions workflows and secrets |
