locals {
  datasets = {
    "oci-host-telemetry" = {
      name             = "oci-host-telemetry"
      description      = "Telemetry for OCI hosts"
      delete_protected = true
    }
    "concierge" = {
      name             = "concierge"
      description      = "Concierge service telemetry"
      delete_protected = true
    }
    "metrics" = {
      name             = "Metrics"
      description      = "System and service metrics"
      delete_protected = true
    }
    "gha-builds" = {
      name             = "gha-builds"
      description      = "GitHub Actions build telemetry"
      delete_protected = true
    }
  }
}
