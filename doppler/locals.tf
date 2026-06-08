locals {
  projects = {
    "github" = {
      description = "Organization-wide shared templates."
      environments = {
        "prd" = {
          name             = "Production"
          personal_configs = false
        }
      }
    }
  }

  groups         = {}
  project_access = []
}
