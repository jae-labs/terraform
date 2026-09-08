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
    "pages" = {
      name        = "pages"
      platform    = "javascript-astro"
      teams       = ["jae"]
      default_key = false
    }
  }

  keys = {
    # these are the existing default client-key ids used to adopt unmanaged keys into terraform.
    "pages:default" = {
      project = "pages"
      id      = "6ca80b329356604c3c9d65bfce559e2f"
      name    = "Default"
    }
  }
}
