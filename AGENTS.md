# Terraform IaC — jae-labs infrastructure

Provider roots: `github/`, `cloudflare/`, `doppler/`, `grafana/`, `oci/`, `sentry/`, `tailscale/`. Reusable modules were removed; each path is a flat Terraform root. State uses Terraform `pg` backend; each root has its own schema. Terraform >= 1.5. CI auto-applies on merge to main, path-filtered per root. Action SHAs are ratchet-pinned in workflows.

## Structure

- `github/` — org settings, members, teams, repos, branch protection, environments
- `cloudflare/` — DNS records, zone members, Workers KV, Pages projects/domains
- `doppler/` — secrets management (projects, environments, groups)
- `oci/` — flat OCI root (VCNs, subnets, security lists, NSGs, instances, object storage)
- `sentry/` — Sentry organization, teams, projects, and client keys
- `tailscale/` — tailnet-wide configurations, DNS preferences, and Access Control policies (ACL)
- `grafana/scripts/` — k6 performance test scripts used by the Grafana Synthetic Monitoring and k6 configurations in `grafana/`
- `docs/` — generic provider, ci-cd, and architecture docs

## Documentation

Docs live in `docs/`:

| Document | Description |
|---|---|
| [Architecture](docs/architecture.md) | Repository layout, state model, apply flow |
| [Providers](docs/providers.md) | Generic provider-root model, `locals.tf`|
| [CI/CD](docs/ci-cd.md) | GitHub Actions workflows, secrets, SHA ratcheting |

### Documentation maintenance

Documentation MUST be updated in the same PR as the code change.

| Change type | Update required |
|---|---|
| New/modified local field | `docs/providers.md` if it changes the generic model |
| New/modified resource | docs only if it changes the generic provider-root model |
| New/modified locals file | `docs/providers.md` if it changes the generic model |
| New CI workflow or secret | `docs/ci-cd.md` |

Avoid provider-specific docs unless the generic model is insufficient.

## Commands

- install hooks: `lefthook install`
- gate: `lefthook run pre-commit`
- validate a single root: `(cd <root> && terraform init -backend=false && terraform validate)`

## Agent workflow

Hard rules for any agent making changes in this repo:

- **Plan only, never apply.** Run `terraform plan` for verification. Do not run `terraform apply` locally under any circumstance. Applies happen via CI on merge to `main`.
- **Use Doppler for secrets.** All provider auth and backend env vars live in Doppler. Wrap every Terraform invocation with `doppler run --` so secrets are injected. Example: `doppler run -- terraform plan` (or `doppler run --config <project> -- terraform plan` when the Doppler project differs from the current directory).
- **No commits, no PRs.** Do not `git commit`, `git push`, or open pull requests unless the user explicitly asks for that step in the current turn. Stage nothing, push nothing.
- **Keep changes scoped.** Edit only the provider root(s) the task requires. Cross-root drive-by changes are not acceptable.
- **Ask before acting on ambiguity.** If a request is unclear, the change is destructive, or a schema-managed locals key/path would change, stop and ask the user. Do not guess.
