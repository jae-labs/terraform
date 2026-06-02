locals {
  projects = {
    "github" = {
      description = "Organization-wide shared templates."
      environments = {
        "prd" = { name = "Production" }
      }
    }
  }
}
