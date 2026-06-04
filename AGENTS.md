# Terraform IaC — jae-labs infrastructure

Provider roots: `github/`, `cloudflare/`, `doppler/`, `oci/`, `sentry/`, `tailscale/`. Reusable modules were removed; each path is a flat Terraform root. State uses Terraform `pg` backend; each root has its own schema. Terraform >= 1.5. CI auto-applies on merge to main, path-filtered per root. Action SHAs are ratchet-pinned in workflows.

## Structure

- `github/` — org settings, members, teams, repos, branch protection, environments
- `cloudflare/` — DNS records, zone members, Workers KV, Pages projects/domains
- `doppler/` — secrets management (projects, environments, groups)
- `oci/` — flat OCI root (VCN, subnet, security rules, compute instance)
- `sentry/` — Sentry organization, teams, projects, and client keys
- `tailscale/` — tailnet-wide configurations, DNS preferences, and Access Control policies (ACL)
- `scripts/` — operational utilities
- `docs/` — generic provider, ci-cd, and architecture docs

## Bot-Consumed Files

The conCierge bot contract in this repo is `concierge-schema.yaml` plus the locals files it references:

| File | Bot Operation |
|---|---|
| `concierge-schema.yaml` | Declares editable resources, field paths, actions, and key sources |
| `github/locals.tf` | Repo, members, and org settings CRUD backing GitHub schema resources |
| `cloudflare/locals.tf` | Add/delete/update DNS records |
| `doppler/locals.tf` | Add/delete/update Doppler projects |

## Critical Constraints

- MUST NOT change any schema-managed locals path, key name, or nesting without updating `concierge-schema.yaml`
- MUST NOT rename or move any schema-managed locals file without updating `concierge-schema.yaml`
- Treat `concierge-schema.yaml` and its referenced locals as a public API between IaC and the bot

## Documentation

Docs live in `docs/`:

| Document | Description |
|---|---|
| [Providers](docs/providers.md) | Generic provider-root model, `locals.tf`, and concierge contract |
| [CI/CD](docs/ci-cd.md) | GitHub Actions workflows, secrets, SHA ratcheting |

### Documentation maintenance

Documentation MUST be updated in the same PR as the code change.

| Change type | Update required |
|---|---|
| New/modified local field | `docs/providers.md` if it changes the generic model, plus `concierge-schema.yaml` if bot-exposed |
| New/modified resource | docs only if it changes the generic provider-root model |
| New/modified locals file | `docs/providers.md` if it changes the generic model, plus `concierge-schema.yaml` if bot-exposed |
| New/modified schema-exposed bot field/action | `docs/providers.md`, `concierge-schema.yaml`, root `AGENTS.md`, and `README.md` |
| New CI workflow or secret | `docs/ci-cd.md` |

Avoid provider-specific docs unless the generic model is insufficient.

## Commands

- install hooks: `lefthook install`
- gate: `lefthook run pre-commit`
