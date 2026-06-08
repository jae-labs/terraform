# Terraform

<p align="center">
  <a href="https://github.com/jae-labs/terraform/actions/workflows/ci.yml"><img src="https://github.com/jae-labs/terraform/actions/workflows/ci.yml/badge.svg?branch=main" alt="CI"></a>
  <a href="https://github.com/jae-labs/terraform/actions/workflows/github-provider.yml"><img src="https://github.com/jae-labs/terraform/actions/workflows/github-provider.yml/badge.svg?branch=main" alt="GitHub Provider"></a>
  <a href="https://github.com/jae-labs/terraform/actions/workflows/cloudflare-provider.yml"><img src="https://github.com/jae-labs/terraform/actions/workflows/cloudflare-provider.yml/badge.svg?branch=main" alt="Cloudflare Provider"></a>
  <a href="https://github.com/jae-labs/terraform/actions/workflows/doppler-provider.yml"><img src="https://github.com/jae-labs/terraform/actions/workflows/doppler-provider.yml/badge.svg?branch=main" alt="Doppler Provider"></a>
  <a href="https://github.com/jae-labs/terraform/actions/workflows/oci-provider.yml"><img src="https://github.com/jae-labs/terraform/actions/workflows/oci-provider.yml/badge.svg?branch=main" alt="OCI Provider"></a>
  <a href="https://github.com/jae-labs/terraform/actions/workflows/sentry-provider.yml"><img src="https://github.com/jae-labs/terraform/actions/workflows/sentry-provider.yml/badge.svg?branch=main" alt="Sentry Provider"></a>
  <a href="https://github.com/jae-labs/terraform/actions/workflows/tailscale-provider.yml"><img src="https://github.com/jae-labs/terraform/actions/workflows/tailscale-provider.yml/badge.svg?branch=main" alt="Tailscale Provider"></a>
  <a href="https://github.com/jae-labs/terraform/actions/workflows/grafana-provider.yml"><img src="https://github.com/jae-labs/terraform/actions/workflows/grafana-provider.yml/badge.svg?branch=main" alt="Grafana Provider"></a>
  <a href="LICENSE"><img src="https://img.shields.io/github/license/jae-labs/terraform" alt="License"></a>
  <a href="https://github.com/jae-labs/terraform/issues"><img src="https://img.shields.io/github/issues/jae-labs/terraform" alt="GitHub issues"></a>
  <a href="https://github.com/jae-labs/terraform/stargazers"><img src="https://img.shields.io/github/stars/jae-labs/terraform" alt="GitHub stars"></a>
  <a href="https://github.com/jae-labs/terraform/network"><img src="https://img.shields.io/github/forks/jae-labs/terraform" alt="GitHub forks"></a>
  <a href="https://developer.hashicorp.com/terraform"><img src="https://img.shields.io/badge/terraform-%3E%3D%201.5-844FBA?logo=terraform&logoColor=white" alt="Terraform >= 1.5"></a>
  <a href="https://buymeacoffee.com/luiz1361"><img src="https://img.shields.io/badge/Buy%20Me%20A%20Coffee-donate-orange.svg?logo=buymeacoffee" alt="Buy Me A Coffee"></a>
</p>

This repository is the source of truth for all `jae-labs` infrastructure as code. It manages GitHub organization config, Cloudflare DNS and Pages, Doppler secrets infrastructure, Grafana monitoring, OCI infrastructure, Sentry organization/project config, and Tailscale preferences/ACLs. Changes are split by provider root, validated in CI, and auto-applied on merge to `main`.

## What this repo manages

| Path | Purpose |
|---|---|
| `github/` | Org settings, members, teams, repositories, environments, branch protection |
| `cloudflare/` | Zones, DNS records, account members, Workers KV, Pages projects/domains |
| `doppler/` | Projects, environments, groups, access grants |
| `oci/` | OCI resource-shaped config: VCNs, subnets, security lists, NSGs, instances, object storage |
| `sentry/` | Sentry organization, teams, projects, client keys |
| `tailscale/` | Tailscale MagicDNS, nameservers, search paths, global preferences, and ACL policies |
| `grafana/` | Grafana Git Sync configurations, SLOs, and Synthetic Monitoring checks |

## How it works

- Each provider root has isolated remote state in PostgreSQL with its own backend schema.
- All domains (`github/`, `cloudflare/`, `doppler/`, `grafana/`, `oci/`, `sentry/`, and `tailscale/`) are flat and self-contained Terraform roots.
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
- Grafana: `GRAFANA_AUTH`, `GRAFANA_SM_ACCESS_TOKEN`, `GRAFANA_SM_URL`, `GRAFANA_K6_ACCESS_TOKEN`
- OCI stack inputs: `TF_VAR_compartment_id`, `TF_VAR_availability_domain`, `TF_VAR_ssh_authorized_keys`, `TF_VAR_ssh_ingress_cidr`

Install local Git hooks:

```bash
lefthook install
```

Run any provider root locally:

```bash
cd github
doppler run -- terraform init
doppler run -- terraform plan
doppler run -- terraform apply
```

Swap `github` for `cloudflare`, `doppler`, `grafana`, `oci`, `tailscale`, or `sentry` as needed.

## Validation

```bash
terraform fmt -check -recursive .
tflint --recursive --config=.tflint.hcl
for root in github cloudflare doppler oci tailscale sentry grafana; do
  (
    cd "${root}" && \
    terraform init -backend=false && \
    terraform validate
  )
done
```

## Documentation

| Document | Description |
|---|---|
| [docs/architecture.md](docs/architecture.md) | Repository layout, state model, apply flow |
| [docs/providers.md](docs/providers.md) | Generic provider-root model, `locals.tf` |
| [docs/ci-cd.md](docs/ci-cd.md) | GitHub Actions workflows and secrets |
