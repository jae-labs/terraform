resource "sentry_organization" "org" {
  name        = local.organization.name
  slug        = local.organization.slug
  agree_terms = local.organization.agree_terms
}

resource "sentry_team" "teams" {
  for_each = local.teams

  organization = sentry_organization.org.slug
  slug         = each.key
  name         = each.value.name
}

resource "sentry_project" "projects" {
  for_each = local.projects

  organization = sentry_organization.org.slug
  slug         = each.key
  name         = each.value.name
  platform     = each.value.platform
  teams        = [for team in each.value.teams : sentry_team.teams[team].slug]
  default_key  = false
}

resource "sentry_key" "keys" {
  for_each = local.keys

  organization = sentry_organization.org.slug
  project      = sentry_project.projects[each.value.project].slug
  name         = each.value.name
}
