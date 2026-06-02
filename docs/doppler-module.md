# Doppler Root

Manages secrets infrastructure: projects, environments, groups, and access grants.

## Resources managed

| Resource | Key | Description |
|---|---|---|
| `doppler_project` | `projects[name]` | Doppler projects |
| `doppler_environment` | `envs[project:env_slug]` | Project environments |
| `doppler_group` | `groups[name]` | Access groups |
| `doppler_project_member_group` | `access[project:group]` | Group-to-project access grants |

## Configuration Locals

These local variables are defined in the Doppler Terraform root:

| Local | Type | Description |
|---|---|---|
| `projects` | `map(object({description, environments}))` | Projects with nested environments. Environment key is the slug, `name` is display value. `personal_configs` defaults to `false`. |
| `groups` | `map(object({description}))` | Doppler groups |
| `project_access` | `list(object({project, group, role, environments?}))` | Group-to-project access grants. Duplicates fail fast during execution. |

## Configuration

All metadata lives in a consolidated locals file under `doppler/`:

| File | Content |
|---|---|
| `locals.tf` | `projects` (with nested environments), `groups`, `project_access` |

## Flattening

Two flattening locals in `doppler/main.tf`:

| Local | Pattern | Key format |
|---|---|---|
| `project_environments` | `projects x environments` | `"project:env_slug"` |
| `project_access_map` | list-to-map conversion | `"project:group"` |

## Configuration examples

### Adding a project with environments

```hcl
"my-service" = {
  description = "Backend API service"
  environments = {
    "dev" = {
      name             = "Development"
      personal_configs = true
    }
    "stg" = {
      name = "Staging"
    }
  }
}
```

### Adding a group

```hcl
"backend-team" = {
  description = "Backend engineering team"
}
```

### Adding a project access grant

```hcl
project_access = [
  {
    project = "my-service"
    group   = "backend-team"
    role    = "admin"
  },
  {
    project      = "my-service"
    group        = "frontend-team"
    role         = "viewer"
    environments = ["dev", "stg"]
  },
]
```

## Bot integration

**Status: Partially integrated via `concierge-schema.yaml` (projects only).**

Current schema coverage:

| Schema resource | File | Root path | Actions |
|---|---|---|---|
| `project` | `doppler/locals.tf` | `projects` | `add`, `settings`, `delete` |

Current gaps:

- environments are still edited through `projects[*].environments`, but not exposed directly in the schema
- `groups` are not exposed in the schema
- `project_access` is not exposed in the schema

If you change `projects` structure, file paths, or field paths, update `concierge-schema.yaml` in the same change.

## Auth

The Doppler provider reads `DOPPLER_TOKEN` automatically. No variable needed.

Required: a personal token from Doppler account settings with access to managed projects.
