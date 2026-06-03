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

## Root model

- one provider per top-level folder
- one Terraform root per provider folder
- one backend schema per provider root
- no reusable internal Terraform modules; configuration is kept flat in each root

## `locals.tf`

When present, `locals.tf` is the main committed configuration surface for a provider root. Keep it stable, reviewable, and easy to edit.

`locals.tf` is especially important for roots that are edited by automation or used as a structured data source.

## conCierge contract

The [conCierge bot](https://github.com/jae-labs/conCIerge/tree/main) does not apply Terraform. It reads this repo, edits supported locals through GitHub PRs, and relies on this repo's CI/CD to validate and apply.

The contract is:

- `concierge-schema.yaml` at the repo root
- every locals file, root path, field path, key name, and nesting shape referenced by that schema

If you change schema-managed locals data, update `concierge-schema.yaml` in the same change.

Examples of breaking changes if not coordinated:

- renaming a schema-managed `locals.tf`
- moving a root path referenced by the schema
- renaming keys used by schema field paths
- changing nesting under a schema-managed object

Treat `concierge-schema.yaml` and referenced locals as a public API between this repo and the bot.

## Change rules

For provider-root changes:

- keep changes scoped to the relevant top-level provider folder
- update docs in the same PR when the root model or bot contract changes
- if a bot-exposed locals shape changes, update `concierge-schema.yaml` in the same PR
- prefer keeping provider details in code and locals over large duplicated docs

## Adding a provider root

When adding a new provider root:

1. add a new top-level folder
2. configure its backend schema and CI/apply wiring
3. add `locals.tf` if the root benefits from committed structured config
4. update `concierge-schema.yaml` only if the bot should expose that root
5. add the root to the provider inventory above
