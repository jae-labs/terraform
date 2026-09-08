locals {
  datasets = {
    "gha-builds" = {
      name             = "gha-builds"
      description      = "GitHub Actions build telemetry"
      delete_protected = true
    }
  }
}
