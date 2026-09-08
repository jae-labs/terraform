locals {
  # ============================================================================
  # project_environments
  # ============================================================================
  # Purpose:
  #   Flattens the nested project environments structure (from local.projects)
  #   into a flat map of environment definitions suitable for use with a
  #   for_each resource loop (specifically doppler_environment.envs).
  #
  # How it works:
  #   1. Iterates over the `local.projects` map, extracting `project_name` and the
  #      `project` object.
  #   2. For each project, iterates over its `environments` map to extract
  #      `env_slug` and the `env` definition.
  #   3. Builds a map element representation structure containing the composite
  #      `key` ("project:env_slug"), references to the project name, env slug,
  #      env name, and the raw env object itself.
  #   4. Wraps the nested loops in `flatten()` to turn the list of lists into a
  #      single flat list of entries.
  #   5. Projects the flat list into a map keyed by each entry's composite `key`.
  #
  # Output format:
  #   {
  #     "github:prd" = {
  #       key          = "github:prd"
  #       project_name = "github"
  #       env_slug     = "prd"
  #       env_name     = "Production"
  #       env          = { name = "Production" }
  #     }
  #   }
  # ============================================================================
  project_environments = {
    for entry in flatten([
      for project_name, project in local.projects : [
        for env_slug, env in project.environments : {
          key          = "${project_name}:${env_slug}"
          project_name = project_name
          env_slug     = env_slug
          env_name     = env.name
          env          = env
        }
      ]
    ]) : entry.key => entry
  }

  # ============================================================================
  # project_access_map
  # ============================================================================
  # Purpose:
  #   Converts the project access authorization list (local.project_access)
  #   into a map keyed by a unique composite key ("project:group"). This is
  #   required to drive a for_each loop on doppler_project_member_group.access.
  #
  # How it works:
  #   1. Iterates through each object in the `local.project_access` list.
  #   2. Constructs a composite key string using the project name and the group name
  #      ("${entry.project}:${entry.group}").
  #   3. Maps each composite key to its respective project access entry.
  #   4. If a duplicate entry (same project and group) is defined in the list,
  #      Terraform will fail fast during evaluation because duplicate keys are not
  #      allowed in map comprehensions.
  #
  # Output format:
  #   {
  #     "github:admin-team" = {
  #       project      = "github"
  #       group        = "admin-team"
  #       role         = "admin"
  #       environments = ["prd"] # Optional list of environment slugs
  #     }
  #   }
  # ============================================================================
  project_access_map = {
    for entry in local.project_access :
    "${entry.project}:${entry.group}" => entry
  }
}

resource "doppler_project" "projects" {
  for_each = local.projects

  name        = each.key
  description = each.value.description
}

resource "doppler_environment" "envs" {
  for_each = local.project_environments

  project          = doppler_project.projects[each.value.project_name].name
  slug             = each.value.env_slug
  name             = each.value.env_name
  personal_configs = try(each.value.env.personal_configs, false)
}

resource "doppler_group" "groups" {
  for_each = local.groups

  name = each.key
}

resource "doppler_project_member_group" "access" {
  for_each = local.project_access_map

  project      = doppler_project.projects[each.value.project].name
  group_slug   = doppler_group.groups[each.value.group].slug
  role         = each.value.role
  environments = try(each.value.environments, null)
}
