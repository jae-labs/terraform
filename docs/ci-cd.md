# CI/CD

GitHub Actions workflow at `.github/workflows/github-apply.yml`.

## Trigger

Push to `main` affecting `github/**` or `modules/github/**`.

## Secrets

Stored in the `production` environment on the `terraform` repo.

| Secret | Value |
|---|---|
| `GH_PAT` | Fine-grained PAT with org admin permissions |
| `GCP_SA_KEY` | Raw JSON contents of `gcp-sa-key.json` |

## Flow

1. Checkout code
2. Write GCP credentials to temp file
3. `terraform init`
4. `terraform apply -auto-approve`
5. Cleanup credentials

## Security

- Secrets scoped to `production` environment only
- Environment restricted to protected branches (`main`)
- Branch protection requires PR with 1 approval before merge
- No direct pushes to `main`
