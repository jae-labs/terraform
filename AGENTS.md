# Terraform IaC — jae-labs infrastructure

Provider roots: `github/`, `cloudflare/`, `doppler/`, `oci/`. Reusable modules were removed; each path is a flat Terraform root. State uses Terraform `pg` backend; each root has its own schema. Terraform >= 1.5. CI auto-applies on merge to main, path-filtered per root. Action SHAs are ratchet-pinned in workflows.

## Structure

- `github/` — org settings, members, teams, repos, branch protection, environments
- `cloudflare/` — DNS records, zone members, Workers KV, Pages projects/domains
- `doppler/` — secrets management (projects, environments, groups)
- `oci/` — flat OCI root (VCN, subnet, security rules, compute instance)
- `scripts/` — operational utilities
- `docs/` — root docs (github, cloudflare, doppler, oci), ci-cd, architecture

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

Root docs live in `docs/`:

| Document | Description |
|---|---|
| [GitHub Root](docs/github-module.md) | Org members, teams, repos, branch protection, environments |
| [Cloudflare Root](docs/cloudflare-module.md) | DNS zones, records, account members |
| [Doppler Root](docs/doppler-module.md) | Projects, environments, groups, access grants |
| [OCI Root](docs/oci-module.md) | VCN, subnet, security rules, compute instance |
| [CI/CD](docs/ci-cd.md) | GitHub Actions workflows, secrets, SHA ratcheting |

### Documentation maintenance

Documentation MUST be updated in the same PR as the code change.

| Change type | Update required |
|---|---|
| New/modified local field | Matching root doc locals table and `concierge-schema.yaml` if bot-exposed |
| New/modified resource | Matching root doc resources table |
| New/modified locals file | Matching root doc locals files table and `concierge-schema.yaml` if bot-exposed |
| New/modified schema-exposed bot field/action | Matching root doc bot integration section, `concierge-schema.yaml`, root `AGENTS.md`, and `README.md` |
| New CI workflow or secret | `docs/ci-cd.md` |

Root docs follow the format in `docs/github-module.md`: title, resources, variables/locals, flattening, bot integration, auth, examples.
