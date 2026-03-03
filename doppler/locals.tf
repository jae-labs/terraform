locals {
  projects = {
    "api" = {
      description  = "API service secrets"
      environments = ["dev", "staging", "production"]
    }
    "infra" = {
      description  = "Infrastructure secrets"
      environments = ["dev", "production"]
    }
  }

  groups = {
    "engineering" = { description = "Engineering access group" }
  }

  project_access = [
    {
      project      = "api"
      group        = "engineering"
      role         = "collaborator"
      environments = null
    },
    {
      project      = "infra"
      group        = "engineering"
      role         = "viewer"
      environments = null
    },
  ]
}
