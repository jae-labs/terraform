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
  <a href="https://github.com/jae-labs/terraform/actions/workflows/honeycomb-provider.yml"><img src="https://github.com/jae-labs/terraform/actions/workflows/honeycomb-provider.yml/badge.svg?branch=main" alt="Honeycomb Provider"></a>
  <a href="LICENSE"><img src="https://img.shields.io/github/license/jae-labs/terraform" alt="License"></a>
  <a href="https://github.com/jae-labs/terraform/issues"><img src="https://img.shields.io/github/issues/jae-labs/terraform" alt="GitHub issues"></a>
  <a href="https://github.com/jae-labs/terraform/stargazers"><img src="https://img.shields.io/github/stars/jae-labs/terraform" alt="GitHub stars"></a>
  <a href="https://github.com/jae-labs/terraform/network"><img src="https://img.shields.io/github/forks/jae-labs/terraform" alt="GitHub forks"></a>
  <a href="https://developer.hashicorp.com/terraform"><img src="https://img.shields.io/badge/terraform-%3E%3D%201.5-844FBA?logo=terraform&logoColor=white" alt="Terraform >= 1.5"></a>
  <a href="https://buymeacoffee.com/luiz1361"><img src="https://img.shields.io/badge/Buy%20Me%20A%20Coffee-donate-orange.svg?logo=buymeacoffee" alt="Buy Me A Coffee"></a>
</p>

This repository is the source of truth for all `jae-labs` infrastructure as code. It manages GitHub organization config, Cloudflare DNS and Pages, Doppler secrets infrastructure, Honeycomb datasets, Grafana monitoring, OCI infrastructure, Sentry organization/project config, and Tailscale preferences/ACLs. Changes are split by provider root, validated in CI, and auto-applied on merge to `main`.

<table align="center">
  <tr>
    <td align="center" valign="middle" width="110" height="110">
      <a href="https://github.com">
        <img src="https://cdn.simpleicons.org/github/000000?dark=ffffff" width="48" height="48" alt="GitHub" /><br />
        <sub><b>GitHub</b></sub>
      </a>
    </td>
    <td align="center" valign="middle" width="110" height="110">
      <a href="https://cloudflare.com">
        <img src="https://cdn.simpleicons.org/cloudflare/F38020" width="48" height="48" alt="Cloudflare" /><br />
        <sub><b>Cloudflare</b></sub>
      </a>
    </td>
    <td align="center" valign="middle" width="110" height="110">
      <a href="https://doppler.com">
        <img src="https://cdn.jsdelivr.net/gh/selfhst/icons/svg/doppler.svg" width="48" height="48" alt="Doppler" /><br />
        <sub><b>Doppler</b></sub>
      </a>
    </td>
  </tr>
  <tr>
    <td align="center" valign="middle" width="110" height="110">
      <a href="https://oracle.com">
        <img src="https://cdn.jsdelivr.net/gh/devicons/devicon@latest/icons/oracle/oracle-original.svg" width="48" height="48" alt="OCI" /><br />
        <sub><b>OCI</b></sub>
      </a>
    </td>
    <td align="center" valign="middle" width="110" height="110">
      <a href="https://sentry.io">
        <img src="https://cdn.simpleicons.org/sentry/362D59?dark=ffffff" width="48" height="48" alt="Sentry" /><br />
        <sub><b>Sentry</b></sub>
      </a>
    </td>
    <td align="center" valign="middle" width="110" height="110">
      <a href="https://tailscale.com">
        <img src="https://cdn.simpleicons.org/tailscale/5A4099?dark=ffffff" width="48" height="48" alt="Tailscale" /><br />
        <sub><b>Tailscale</b></sub>
      </a>
    </td>
  </tr>
  <tr>
    <td align="center" valign="middle" width="110" height="110">
      <a href="https://grafana.com">
        <img src="https://cdn.simpleicons.org/grafana/F46800" width="48" height="48" alt="Grafana" /><br />
        <sub><b>Grafana</b></sub>
      </a>
    </td>
    <td align="center" valign="middle" width="110" height="110">
      <a href="https://honeycomb.io">
        <img src="https://upload.wikimedia.org/wikipedia/commons/2/24/Honeycomb.io_logo.svg" height="32" alt="Honeycomb" /><br />
        <sub><b>Honeycomb</b></sub>
      </a>
    </td>
    <td align="center" valign="middle" width="110" height="110">
      <a href="https://supabase.com">
        <img src="https://cdn.simpleicons.org/supabase/3ECF8E" width="48" height="48" alt="Supabase" /><br />
        <sub><b>Supabase</b></sub>
      </a>
    </td>
  </tr>
</table>


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
| `honeycomb/` | Honeycomb datasets, derived columns, queries, annotations, and boards |

## How it works

- Each provider root has isolated remote state in a PostgreSQL database (hosted on Supabase) with its own backend schema.
- All domains (`github/`, `cloudflare/`, `doppler/`, `grafana/`, `honeycomb/`, `oci/`, `sentry/`, and `tailscale/`) are flat and self-contained Terraform roots.
- GitHub Actions runs format, lint, and validation checks on pull requests.
- Merges to `main` trigger path-filtered applies for only the affected provider root.

Architecture, state layout, and repo structure live in [docs/architecture.md](docs/architecture.md). Provider-root conventions live in [docs/providers.md](docs/providers.md).

## Quick start

### Prerequisites

- [mise](https://mise.jdx.dev/) for managing tool versions (`terraform`, `tflint`, `lefthook`, `ratchet`)
- [Doppler CLI](https://docs.doppler.com/docs/install-cli) for secrets injection
- `PG_CONN_STR` pointing to the Terraform PostgreSQL backend (hosted on Supabase)
- Provider credentials (injected via Doppler for local development):
  - GitHub: `GITHUB_TOKEN`
  - Cloudflare: `CLOUDFLARE_API_TOKEN`
  - Doppler: `DOPPLER_TOKEN`
  - OCI: `OCI_TENANCY_OCID`, `OCI_USER_OCID`, `OCI_FINGERPRINT`, `OCI_REGION`, `OCI_PRIVATE_KEY_PATH`
  - Sentry: `SENTRY_AUTH_TOKEN`
  - Tailscale: `TAILSCALE_API_KEY`
  - Grafana: `GRAFANA_AUTH`, `GRAFANA_SM_ACCESS_TOKEN`, `GRAFANA_SM_URL`, `GRAFANA_K6_ACCESS_TOKEN`
  - Honeycomb: `HONEYCOMB_API_KEY`
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

Swap `github` for `cloudflare`, `doppler`, `grafana`, `honeycomb`, `oci`, `tailscale`, or `sentry` as needed.

## Validation

```bash
terraform fmt -check -recursive .
tflint --recursive --config=.tflint.hcl
for root in github cloudflare doppler honeycomb oci tailscale sentry grafana; do
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
