locals {
  # Explicit list of secrets sync configurations due to licensing limits
  sync_targets = {
    "github:prd" = {
      project_key      = "github"
      config           = "prd"
      integration      = "f773431e-d8b3-4bf8-96ca-a1118ed56dde"
      sync_target      = "org"
      org_scope        = "all"
      repo_name        = null
      environment_name = null
    }
  }
}

resource "doppler_secrets_sync_github_actions" "github_sync" {
  for_each = local.sync_targets

  project     = doppler_project.projects[each.value.project_key].name
  config      = each.value.config
  integration = try(each.value.integration, "0e4c99e3-d0ef-4e3d-ad67-d3fad271c510")
  sync_target = lookup(each.value, "sync_target", "repo")

  # For repo sync (null when sync_target is "org")
  repo_name        = lookup(each.value, "repo_name", null)
  environment_name = lookup(each.value, "environment_name", null)

  # For org sync (null when sync_target is "repo")
  org_scope = lookup(each.value, "org_scope", null)

  depends_on = [doppler_project.projects, doppler_environment.envs]
}



