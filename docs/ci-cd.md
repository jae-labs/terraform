# Repository CI/CD

GitHub Actions workflows live in `.github/workflows/`.

## Workflows

| Workflow | Scope | Purpose |
|---|---|---|
| `ci.yml` | all provider roots | format, lint, validate |
| `github-apply.yml` | `github/**` | apply GitHub root |
| `cloudflare-apply.yml` | `cloudflare/**` | apply Cloudflare root |
| `doppler-apply.yml` | `doppler/**` | apply Doppler root |
| `oci-apply.yml` | `oci/**` | apply OCI root |
| `sentry-apply.yml` | `sentry/**` | apply Sentry root |
| `tailscale-apply.yml` | `tailscale/**` | apply Tailscale root |

## Execution model

- CI runs on pull requests and relevant pushes
- applies run on `main` only for changed provider roots
- GitHub, Cloudflare, Doppler, Sentry, and Tailscale share reusable apply logic
- OCI uses its own apply workflow because its auth/input surface differs
- applies are serialized per provider root

## Secrets

Secrets are stored in the `production` environment on the `conCIerge` repo.

Secret groups:

- shared backend: `PG_CONN_STR`
- provider auth: GitHub, Cloudflare, Doppler, OCI, Tailscale, Sentry credentials
- OCI stack inputs: compartment, availability domain, SSH inputs
- bot runtime: Slack, GitHub App, Tailscale, optional Sentry

## Notes

- action SHAs are ratchet-pinned
- branch protection gates merge before apply
- provider-specific runtime details should stay in workflows, not duplicated here
