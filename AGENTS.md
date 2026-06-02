# Terraform IaC — jae-labs infrastructure

Root modules: `github/`, `cloudflare/`, `doppler/`, `oci/`. All modules are flat root modules (reusable modules were simplified and inlined directly). State uses Terraform `pg` backend; each root module has its own schema. Terraform >= 1.5. CI auto-applies on merge to main, path-filtered per module. Action SHAs are ratchet-pinned in workflows.

## Structure

- `github/` — org settings, members, teams, repos, branch protection, environments
- `cloudflare/` — DNS records, zone members, Workers KV, Pages projects/domains
- `doppler/` — secrets management (projects, environments, groups)
- `oci/` — flat OCI root module (VCN, subnet, security rules, compute instance)
- `scripts/` — operational utilities
- `docs/` — module docs (github, cloudflare, doppler), ci-cd, architecture

## Bot-Consumed Files

The conCierge bot reads and writes these files via the GitHub API:

| File | Bot Operation |
|---|---|
| `github/locals.tf` | Repo, members, and org settings CRUD |
| `cloudflare/locals.tf` | Add/delete/update DNS records |

## Critical Constraints

- MUST NOT rename or restructure any bot-consumed locals file without updating path constants in `src/internal/slack/handler.go`
- MUST NOT change HCL key names or nesting in those files without updating the HCL editor at `src/internal/hcl/`
- These files are the contract between IaC and the bot; treat them as a public API

## Documentation

Module docs live in `docs/`:

| Document | Description |
|---|---|
| [GitHub Module](docs/github-module.md) | Org members, teams, repos, branch protection, environments |
| [Cloudflare Module](docs/cloudflare-module.md) | DNS zones, records, account members |
| [Doppler Module](docs/doppler-module.md) | Projects, environments, groups, access grants |
| [OCI Module](docs/oci-module.md) | VCN, subnet, security rules, compute instance |
| [CI/CD](docs/ci-cd.md) | GitHub Actions workflows, secrets, SHA ratcheting |

### Documentation maintenance

Documentation MUST be updated in the same PR as the code change.

| Change type | Update required |
|---|---|
| New/modified local field | Module doc in `docs/{module}-module.md` variables/locals table |
| New/modified resource | Module doc resources table |
| New/modified locals file | Module doc locals files table |
| New bot integration | Module doc bot integration section, `src/AGENTS.md`, root `AGENTS.md` |
| New CI workflow or secret | `docs/ci-cd.md` |

Module docs follow the format in `docs/github-module.md`: title, resources, variables, locals, flattening, bot integration, auth, examples.
