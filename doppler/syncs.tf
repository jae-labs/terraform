locals {
  # Explicit list of secrets sync configurations due to licensing limits
  sync_targets = {
    "github:prd" = {
      project_key = "github"
      config      = "prd"
      sync_target = "org"
      org_scope   = "all"
    }
  }
}

resource "doppler_secrets_sync_github_actions" "github_sync" {
  for_each = local.sync_targets

  project     = module.doppler.project_names[each.value.project_key]
  config      = each.value.config
  integration = "0e4c99e3-d0ef-4e3d-ad67-d3fad271c510"
  sync_target = lookup(each.value, "sync_target", "repo")

  # For repo sync (null when sync_target is "org")
  repo_name        = lookup(each.value, "repo_name", null)
  environment_name = lookup(each.value, "environment_name", null)

  # For org sync (null when sync_target is "repo")
  org_scope = lookup(each.value, "org_scope", null)

  depends_on = [module.doppler]
}



