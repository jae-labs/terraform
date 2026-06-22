# Provider Roots

This repo is organized by provider/domain. Each top-level provider folder is an independent Terraform root with its own state schema, CI path filters, and apply workflow behavior.

## Layout

| Path | Purpose |
|---|---|
| `github/` | GitHub org configuration |
| `cloudflare/` | Cloudflare DNS, Pages, and account configuration |
| `doppler/` | Doppler project and access configuration |
| `oci/` | OCI infrastructure |
| `sentry/` | Sentry organization configuration |
| `tailscale/` | Tailscale tailnet-wide preferences and Access Control Lists |
| `grafana/` | Grafana Git Sync configuration, SLOs, Synthetic Monitoring checks, k6 performance projects/tests, and OnCall (IRM) schedules/escalation chains |
| `honeycomb/` | Honeycomb datasets configuration |

## Root model

- one provider per top-level folder
- one Terraform root per provider folder
- one backend schema per provider root
- no reusable internal Terraform modules; configuration is kept flat in each root

## `locals.tf`

When present, `locals.tf` is the main committed configuration surface for a provider root. Keep it stable, reviewable, and easy to edit.

`locals.tf` is especially important for roots that are edited by automation or used as a structured data source.

In `oci/`, `locals.tf` is organized as OCI-named top-level maps such as `vcns`, `subnets`, `security_lists`, `network_security_groups`, and `instances` rather than a single synthetic stack object.

## Change rules

For provider-root changes:

- Keep changes scoped to the relevant top-level provider folder.
- Update docs in the same PR or commit when the root model changes.
- Check existing docs, workflows, and lefthook configurations for drift.
- Always check provider/vendor docs, always aim for the latest stable versions of tools, and keep documentation fresh.
- Prefer keeping provider details in code and locals over large duplicated docs.

### Documentation maintenance mapping

| Change type | Update required |
|---|---|
| New/modified local field | `docs/providers.md` if it changes the generic model |
| New/modified resource | docs only if it changes the generic provider-root model |
| New/modified locals file | `docs/providers.md` if it changes the generic model |
| New CI workflow or secret | `docs/ci-cd.md` |

## Adding a provider root

When adding a new provider root:

1. add a new top-level folder
2. configure its backend schema and CI/apply wiring
3. add `locals.tf` if the root benefits from committed structured config
4. add the root to the provider inventory above
