locals {
  organization = {
    slug        = "jae-ij"
    name        = "JAE"
    agree_terms = true
  }

  teams = {
    "jae" = {
      name = "JAE"
    }
  }

  projects = {
    "concierge" = {
      # sentry already has this project named "go"; keep the name stable during import adoption.
      name     = "go"
      platform = "go"
      teams    = ["jae"]
    }
    "pages" = {
      name     = "pages"
      platform = "javascript-astro"
      teams    = ["jae"]
    }
  }

  keys = {
    # these are the existing default client-key ids used to adopt unmanaged keys into terraform.
    "concierge:default" = {
      project = "concierge"
      id      = "a05aa867c95aa4083bd55252cdf5048b"
      name    = "Default"
    }
    "pages:default" = {
      project = "pages"
      id      = "6ca80b329356604c3c9d65bfce559e2f"
      name    = "Default"
    }
  }
}
