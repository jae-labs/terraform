# GitHub Root

Manages the `jae-labs` GitHub organization: members, teams, repositories, environments, and branch protection.

## Resources managed

| Resource | Key | Description |
|---|---|---|
| `github_organization_settings` | `org` | Org-level settings |
| `github_membership` | `members[username]` | Org members |
| `github_team` | `teams[name]` | Teams |
| `github_team_members` | `teams[name]` | Team membership (members + maintainers) |
| `github_organization_role_team` | `teams[name:role]` | Team org role assignments |
| `github_repository` | `repos[name]` | Repositories |
| `github_repository_pages` | `repos[name]` | GitHub Pages configuration |
| `github_team_repository` | `repos[repo:team]` | Team-repo access |
| `github_repository_environment` | `envs[repo:env]` | Deployment environments |
| `github_branch_protection` | `repos[name]` | Branch protection rules |

## Configuration Locals

These local variables are defined in the GitHub Terraform root:

| Name | Type | Description |
|---|---|---|
| `org` | `string` | GitHub organization name |
| `members` | `map(object({role, full_name}))` | Org members keyed by username |
| `teams` | `map(object({description, privacy, members, maintainers, org_roles?}))` | Teams keyed by slug |
| `repos` | `map(object({...}))` | Repositories with 20+ fields, including optional `security_and_analysis` settings (see `locals.tf`) |
| `org_settings` | `object({...})` | Org settings: billing, permissions, dependabot flags (15+ fields) |

## Locals files

Root `github/` defines configuration in:

| File | Content |
|---|---|
| `locals.tf` | `org`, `org_settings`, `members`, `teams`, `repos` |

For `repos`, the map key is the repository name used by `github_repository.name` and all derived `for_each` keys. Rename that key only when the actual GitHub repository name changes, or move state in the same change.

## Flattening pattern

This root flattens nested maps into composite keys for `for_each`:

| Local | Source | Key format |
|---|---|---|
| `team_org_roles` | teams x org_roles | `"team:role"` |
| `repo_team_access` | repos x team_access | `"repo:team"` |
| `repo_environments` | repos x environments | `"repo:env"` |

## Bot integration

**Status**: Integrated via `concierge-schema.yaml`.

The [conCierge bot](https://github.com/jae-labs/conCIerge/tree/main) is an external client of this repo. It reads these locals to populate Slack workflows and validate requests, then writes changes back by editing them and opening pull requests.

For GitHub, the contract is `concierge-schema.yaml` plus the file paths and locals shapes it references:

| Schema resource | File | Root path |
|---|---|
| `repo` | `github/locals.tf` | `repos` |
| `org_settings` | `github/locals.tf` | `org_settings` |
| `user_management` | `github/locals.tf` | `teams`, `members` |

Bot operations exposed by the schema: add/delete/update repos, extract team names, read/update org settings, add/remove/change team members.

If you rename files or change local key names, nesting, or field paths, update `concierge-schema.yaml` in the same change. If the contract drifts, Slack request handling and PR generation break before Terraform does.

## Auth

The GitHub provider reads `GITHUB_TOKEN` automatically. No variable needed.

Fine-grained PAT permissions:

| Scope | Permission | Access |
|---|---|---|
| Organization | Administration | Read and write |
| Organization | Members | Read and write |
| Repository | Administration | Read and write |
| Repository | Environments | Read and write |
| Repository | Metadata | Read-only |

## Configuration examples

### Adding a member

```hcl
"username" = {
  role      = "member"
  full_name = "Full Name"
}
```

### Adding a team

```hcl
"Engineering" = {
  description = "Engineering team"
  privacy     = "closed"
  members     = ["user1", "user2"]
  maintainers = ["lead1"]
  org_roles   = {}
}
```

### Adding a repository

```hcl
"my-repo" = {
  description    = "My new repo"
  visibility     = "public"
  has_issues     = true
  default_branch = "main"
  team_access    = { "Maintainers" = "admin" }
  branch_protection = null
}
```

### Adding branch protection

```hcl
branch_protection = {
  required_reviews                = 1
  dismiss_stale_reviews           = true
  require_linear_history          = true
  require_conversation_resolution = true
  force_push_bypassers            = ["/username"]
}
```

### Adding an environment

```hcl
environments = {
  "production" = {
    deployment_branch_policy = {
      protected_branches     = true
      custom_branch_policies = false
    }
  }
}
```

### Managing GitHub Pages

Use the repo `pages` object to manage GitHub Pages. This root applies that input with the dedicated `github_repository_pages` resource.

```hcl
pages = {
  build_type = "workflow"
  cname      = "example.com"
}
```

### Managing repository security and analysis

For public repositories, omit `advanced_security`; GitHub treats it as always enabled and the provider rejects that block.

```hcl
security_and_analysis = {
  secret_scanning                 = { status = "enabled" }
  secret_scanning_push_protection = { status = "enabled" }
}
```

### Managing repository vulnerability alerts

Use the per-repo `vulnerability_alerts` boolean to manage Dependabot vulnerability and malware alerts. This root keeps that input shape stable and applies it with the dedicated `github_repository_vulnerability_alerts` resource.

```hcl
vulnerability_alerts = true
```

### Managing Dependabot security updates

Use the per-repo `dependabot_security_updates` boolean to manage automated Dependabot security update pull requests. This root applies that input with the dedicated `github_repository_dependabot_security_updates` resource.

```hcl
dependabot_security_updates = true
```
