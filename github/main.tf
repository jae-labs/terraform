module "github" {
  source = "../modules/github"

  org          = local.org
  email_domain = local.email_domain
  members      = local.members
  teams        = local.teams
  repos        = local.repos
  org_settings = local.org_settings
}
