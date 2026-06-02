# Repository CI/CD

GitHub Actions workflows at `.github/workflows/` in the repo root.

## Workflows

| Workflow | Trigger paths | Required secret |
|---|---|---|
| `ci.yml` | `github/**`, `cloudflare/**`, `doppler/**`, `oci/**`, `.github/workflows/ci.yml` | None |
| `github-apply.yml` | `github/**` | `PG_CONN_STR`, `CONCIERGE_GH_PAT` |
| `cloudflare-apply.yml` | `cloudflare/**` | `PG_CONN_STR`, `CONCIERGE_CLOUDFLARE_API_TOKEN` |
| `doppler-apply.yml` | `doppler/**` | `PG_CONN_STR`, `CONCIERGE_DOPPLER_TOKEN` |
| `oci-apply.yml` | `oci/**` | `PG_CONN_STR`, OCI auth and stack secrets |


## Reusable workflow

GitHub, Cloudflare, and Doppler call `terraform-reusable.yml` with inputs:

- `module-path` (string) -- path to Terraform root
- `provider-token-name` (string) -- env var name for provider token

The reusable workflow:

1. Checks out code (`actions/checkout`, SHA-ratcheted)
2. Sets up Terraform (`hashicorp/setup-terraform`, ~> 1.5)
3. Runs `terraform init` with `PG_CONN_STR`
4. Runs `terraform plan` into a temporary local tfplan with stdout/stderr suppressed in GitHub Actions
5. Runs `terraform apply` from that temporary tfplan with stdout/stderr suppressed in GitHub Actions
6. Serializes applies per Terraform root with a GitHub Actions concurrency group keyed by repository and `module-path`

## Dedicated OCI workflow

`oci-apply.yml` is separate because OCI needs multiple provider environment variables plus stack inputs.

The OCI workflow:

1. Checks out code (`actions/checkout`, SHA-ratcheted)
2. Sets up Terraform (`hashicorp/setup-terraform`, ~> 1.5)
3. Writes the OCI API private key to a temp PEM file from `OCI_PRIVATE_KEY`
4. Exports OCI provider env vars, `TF_VAR_*` stack inputs, and `PG_CONN_STR`
5. Runs `terraform init`
6. Runs `terraform plan` into a temporary local tfplan with stdout/stderr suppressed in GitHub Actions
7. Runs `terraform apply` from that temporary tfplan with stdout/stderr suppressed in GitHub Actions
8. Deletes the temporary tfplan, cleans up the temporary OCI credential file, and serializes applies for `oci`

## Verification workflows

### Unified `ci.yml`

The main CI workflow (`ci.yml`) runs on all pull requests and pushes to `main` affecting `github/**`, `cloudflare/**`, `doppler/**`, `oci/**`, or `.github/workflows/ci.yml`. It verifies and validates all Terraform configurations in parallel:

#### Terraform Checks
1. **Format Check**: Runs `terraform fmt -check -recursive .` to verify styling.
2. **Lint Check**: Installs TFLint with `terraform-linters/setup-tflint`, then runs `tflint` recursively using the configuration `.tflint.hcl` in the repository root.
3. **Offline Validation**: Runs a matrix job across all Terraform roots (`github/`, `cloudflare/`, `doppler/`, `oci/`) which:
   - Runs `terraform init -backend=false`.
   - Runs `terraform validate`.

## Trigger

Bot CI runs on path-scoped pushes to `main` and pull requests. Bot releases run on path-scoped pushes to `main`. Terraform applies run on pushes to `main` affecting root-specific paths (see table).

## Secrets

Stored in the `production` environment on the `conCIerge` repo.

| Secret | Value |
|---|---|
| `PG_CONN_STR` | PostgreSQL connection string for the Terraform `pg` backend |
| `CONCIERGE_GH_PAT` | Fine-grained PAT with org admin permissions |
| `CONCIERGE_CLOUDFLARE_API_TOKEN` | Cloudflare API token with zone/DNS edit |
| `CONCIERGE_DOPPLER_TOKEN` | Doppler personal token |
| `CONCIERGE_OCI_TENANCY_OCID` | OCI tenancy OCID used by the provider |
| `CONCIERGE_OCI_USER_OCID` | OCI user OCID used by the provider |
| `CONCIERGE_OCI_FINGERPRINT` | Fingerprint for the OCI API signing key |
| `CONCIERGE_OCI_REGION` | OCI region for provider operations |
| `CONCIERGE_OCI_PRIVATE_KEY` | PEM contents of the OCI API signing key |
| `CONCIERGE_OCI_COMPARTMENT_OCID` | Compartment OCID for the OCI stack |
| `CONCIERGE_OCI_AVAILABILITY_DOMAIN` | Exact tenancy-prefixed OCI availability-domain name for the compute instance (for example `tjxx:eu-amsterdam-1-AD-1`) |
| `CONCIERGE_OCI_SSH_AUTHORIZED_KEYS` | SSH authorized keys content injected into the instance |
| `CONCIERGE_TF_VAR_SSH_INGRESS_CIDR` | CIDR allowed to reach the instance over SSH |
| `OCI_PRIVATE_KEY_PASSPHRASE` | Optional passphrase for `OCI_PRIVATE_KEY` when the OCI API signing key is encrypted |
| `CONCIERGE_OCI_SSH_PRIVATE_KEY_B64` | Single-line base64-encoded private SSH key used by the bot deploy workflow to connect to `ubuntu@oci.justanother.engineer` |
| `CONCIERGE_SLACK_BOT_TOKEN` | Slack bot token rendered into `/etc/concierge/concierge.env` during CI deploy |
| `CONCIERGE_SLACK_SIGNING_SECRET` | Slack signing secret rendered into `/etc/concierge/concierge.env` during CI deploy |
| `CONCIERGE_SLACK_REQUESTS_CHANNEL_ID` | Slack channel ID for concierge request summaries |
| `CONCIERGE_SLACK_USER_IDS` | Comma-separated Slack user IDs allowed to use the bot |
| `SLACK_MANAGER_IDS` | Comma-separated Slack manager IDs allowed to approve requests |
| `SLACK_ADMIN_IDS` | Comma-separated Slack admin IDs allowed to approve requests |
| `CONCIERGE_GH_APP_ID` | GitHub App ID rendered into the concierge service env file |
| `CONCIERGE_GH_APP_INSTALLATION_ID` | GitHub App installation ID rendered into the concierge service env file |
| `CONCIERGE_GH_APP_PRIVATE_KEY` | GitHub App private key rendered into the concierge service env file |
| `CONCIERGE_GH_OWNER` | GitHub owner/org rendered into the concierge service env file |
| `CONCIERGE_GH_REPO` | GitHub repo rendered into the concierge service env file |
| `CONCIERGE_TAILSCALE_AUTH_KEY` | Tailscale auth key used by Ansible to register the OCI host as an exit node with Tailscale SSH |
| `CONCIERGE_SENTRY_DSN` | Optional Sentry DSN rendered into the concierge service env file |
| `SENTRY_ENVIRONMENT` | Optional Sentry environment override |

Encode the deploy SSH private key before saving it as `OCI_SSH_PRIVATE_KEY_B64`, for example with `base64 < ~/.ssh/your_deploy_key | tr -d '\n'`.

## External repository synced secrets

Doppler also syncs project `pages` configs `prd` and `rev` into the `pages` repository `production` and `review` GitHub environments. The `pages` CI workflow consumes these secrets and writes runtime-only values into Cloudflare Pages before deploy.

| Repository | Environment | Secret | Purpose |
|---|---|---|---|
| `pages` | `production`, `review` | `NVIDIA_NIM_TOKEN` | NVIDIA NIM token used by the lui.z clone chat endpoint; CI writes it to Cloudflare Pages runtime secrets |

## Security

- Secrets scoped to `production` environment only
- Environment restricted to protected branches (`main`)
- Branch protection requires PR with 1 approval before merge
- No direct pushes to `main`
- Action SHAs are ratchet-pinned in workflows

## SHA ratcheting

Action versions are pinned by SHA (not tag) with ratchet comments for auditability:

```yaml
- uses: actions/checkout@de0fac2e... # ratchet:actions/checkout@v6
```
