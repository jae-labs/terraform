# Repository CI/CD

GitHub Actions workflows live in `.github/workflows/`.

## Workflows

| Workflow | Scope | Purpose |
|---|---|---|
| `ci.yml` | all provider roots | format, lint, validate |
| `github-provider.yml` | `github/**` | apply GitHub root |
| `cloudflare-provider.yml` | `cloudflare/**` | apply Cloudflare root |
| `doppler-provider.yml` | `doppler/**` | apply Doppler root |
| `oci-provider.yml` | `oci/**` | apply OCI root |
| `sentry-provider.yml` | `sentry/**` | apply Sentry root |
| `tailscale-provider.yml` | `tailscale/**` | apply Tailscale root |
| `grafana-provider.yml` | `grafana/**` | apply Grafana root |
| `honeycomb-provider.yml` | `honeycomb/**` | apply Honeycomb root |

## Execution model

- CI runs on pull requests and relevant pushes
- applies run on `main` only for changed provider roots
- All provider roots use the standard reusable apply workflow (`.github/workflows/terraform-reusable.yml`)
- applies are serialized repository-wide across all provider roots using a shared concurrency group

## Notes

- action SHAs are ratchet-pinned
- branch protection gates merge before apply
- apply workflows use `-lock-timeout=5m` on lock-capable Terraform commands to tolerate transient backend lock contention
- provider-specific runtime details should stay in workflows, not duplicated here
