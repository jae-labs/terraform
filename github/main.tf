locals {
  # ============================================================================
  # Local Mapping: team_members_by_role
  #
  # Purpose:
  #   Consolidate and resolve team membership configurations from local.teams,
  #   assigning each user their respective team role.
  #
  # How it works:
  #   1. Loops over the local.teams map.
  #   2. Maps each username in try(team.members, []) to the "member" role.
  #   3. Maps each username in try(team.maintainers, []) to the "maintainer" role.
  #   4. Merges the two maps per team. If a username is listed in both, the
  #      "maintainer" role takes precedence because that map is merged second.
  #
  # Output format:
  #   {
  #     "<team_name>" = {
  #       "<username_1>" = "member"
  #       "<username_2>" = "maintainer"
  #     }
  #   }
  # ============================================================================
  team_members_by_role = {
    for team_name, team in local.teams : team_name => merge(
      { for u in try(team.members, []) : u => "member" },
      { for u in try(team.maintainers, []) : u => "maintainer" }
    )
  }

  # ============================================================================
  # Local Mapping: team_org_roles
  #
  # Purpose:
  #   Flatten the nested organization roles per team defined in local.teams into
  #   a single map, enabling the creation of individual role team assignments.
  #
  # How it works:
  #   1. Iterates over all teams in local.teams.
  #   2. Iterates over the custom org_roles configuration map within each team.
  #   3. Generates an object structure for each role assignment, mapping key,
  #      team_name, and role_id.
  #   4. Flattens the nested structures into a single list.
  #   5. Projects that list into a map keyed by "team_name:role_name".
  #
  # Output format:
  #   {
  #     "<team_name>:<role_name>" = {
  #       key       = "<team_name>:<role_name>"
  #       team_name = "<team_name>"
  #       role_id   = "<role_id>"
  #     }
  #   }
  # ============================================================================
  team_org_roles = {
    for entry in flatten([
      for team_name, team in local.teams : [
        for role_name, role_id in try(team.org_roles, {}) : {
          key       = "${team_name}:${role_name}"
          team_name = team_name
          role_id   = role_id
        }
      ]
    ]) : entry.key => entry
  }

  # ============================================================================
  # Local Mapping: repo_team_access
  #
  # Purpose:
  #   Flatten the nested team permissions defined on repositories in local.repos
  #   into a single flat map, allowing individual team repository access rules to
  #   be declared.
  #
  # How it works:
  #   1. Iterates over all repositories in local.repos.
  #   2. Loops over the team_access configuration map of each repository.
  #   3. Builds a configuration object detailing the compound key, repo name,
  #      team name, and permission.
  #   4. Flattens the nested lists of objects across all repositories.
  #   5. Projects that flat list into a map keyed by "repo_name:team_name".
  #
  # Output format:
  #   {
  #     "<repo_name>:<team_name>" = {
  #       key        = "<repo_name>:<team_name>"
  #       repo_name  = "<repo_name>"
  #       team_name  = "<team_name>"
  #       permission = "<permission>"
  #     }
  #   }
  # ============================================================================
  repo_team_access = {
    for entry in flatten([
      for repo_name, repo in local.repos : [
        for team_name, permission in try(repo.team_access, {}) : {
          key        = "${repo_name}:${team_name}"
          repo_name  = repo_name
          team_name  = team_name
          permission = permission
        }
      ]
    ]) : entry.key => entry
  }

  # ============================================================================
  # Local Mapping: repo_environments
  #
  # Purpose:
  #   Flatten the nested environments defined on repositories in local.repos
  #   into a single flat map for provisioning repository environments.
  #
  # How it works:
  #   1. Iterates over all repositories in local.repos.
  #   2. Iterates over the environments map configured on each repository.
  #   3. Constructs a structure containing a compound key, repo name, environment
  #      name, and the detailed environment configuration block (env).
  #   4. Flattens these objects into a single list.
  #   5. Projects the flat list into a map keyed by "repo_name:env_name".
  #
  # Output format:
  #   {
  #     "<repo_name>:<env_name>" = {
  #       key       = "<repo_name>:<env_name>"
  #       repo_name = "<repo_name>"
  #       env_name  = "<env_name>"
  #       env       = { ... environment configuration properties ... }
  #     }
  #   }
  # ============================================================================
  repo_environments = {
    for entry in flatten([
      for repo_name, repo in local.repos : [
        for env_name, env in try(repo.environments, {}) : {
          key       = "${repo_name}:${env_name}"
          repo_name = repo_name
          env_name  = env_name
          env       = env
        }
      ]
    ]) : entry.key => entry
  }
}

resource "github_organization_settings" "org" {
  name                                                         = try(local.org_settings.name, null)
  billing_email                                                = local.org_settings.billing_email
  blog                                                         = try(local.org_settings.blog, null)
  email                                                        = try(local.org_settings.email, null)
  description                                                  = try(local.org_settings.description, null)
  location                                                     = try(local.org_settings.location, null)
  members_can_create_repositories                              = local.org_settings.members_can_create_repositories
  members_can_create_public_repositories                       = try(local.org_settings.members_can_create_public_repositories, false)
  members_can_create_private_repositories                      = try(local.org_settings.members_can_create_private_repositories, false)
  members_can_create_private_pages                             = try(local.org_settings.members_can_create_private_pages, false)
  default_repository_permission                                = local.org_settings.default_repository_permission
  web_commit_signoff_required                                  = local.org_settings.web_commit_signoff_required
  dependabot_alerts_enabled_for_new_repositories               = try(local.org_settings.dependabot_alerts_enabled_for_new_repositories, true)
  dependabot_security_updates_enabled_for_new_repositories     = try(local.org_settings.dependabot_security_updates_enabled_for_new_repositories, true)
  dependency_graph_enabled_for_new_repositories                = try(local.org_settings.dependency_graph_enabled_for_new_repositories, true)
  advanced_security_enabled_for_new_repositories               = try(local.org_settings.advanced_security_enabled_for_new_repositories, false)
  secret_scanning_enabled_for_new_repositories                 = try(local.org_settings.secret_scanning_enabled_for_new_repositories, false)
  secret_scanning_push_protection_enabled_for_new_repositories = try(local.org_settings.secret_scanning_push_protection_enabled_for_new_repositories, false)
}

resource "github_membership" "members" {
  for_each = local.members

  username = each.key
  role     = each.value.role
}

resource "github_team" "teams" {
  for_each = local.teams

  name        = each.key
  description = try(each.value.description, null)
  privacy     = try(each.value.privacy, "secret")
}

resource "github_team_members" "teams" {
  for_each = local.teams

  team_id = github_team.teams[each.key].id

  dynamic "members" {
    for_each = local.team_members_by_role[each.key]
    content {
      username = members.key
      role     = members.value
    }
  }

  depends_on = [github_membership.members]
}

resource "github_organization_role_team" "team_roles" {
  for_each = local.team_org_roles

  team_slug = github_team.teams[each.value.team_name].slug
  role_id   = each.value.role_id
}

resource "github_repository" "repos" {
  for_each = local.repos

  name                        = each.key
  description                 = try(each.value.description, null)
  visibility                  = try(each.value.visibility, "private")
  has_issues                  = try(each.value.has_issues, true)
  has_wiki                    = try(each.value.has_wiki, false)
  has_projects                = try(each.value.has_projects, false)
  has_discussions             = try(each.value.has_discussions, false)
  homepage_url                = try(each.value.homepage_url, null)
  allow_auto_merge            = try(each.value.allow_auto_merge, false)
  allow_merge_commit          = try(each.value.allow_merge_commit, true)
  allow_rebase_merge          = try(each.value.allow_rebase_merge, true)
  allow_squash_merge          = try(each.value.allow_squash_merge, true)
  allow_update_branch         = try(each.value.allow_update_branch, false)
  archived                    = try(each.value.archived, false)
  delete_branch_on_merge      = try(each.value.delete_branch_on_merge, false)
  is_template                 = try(each.value.is_template, false)
  merge_commit_title          = try(each.value.merge_commit_title, "MERGE_MESSAGE")
  merge_commit_message        = try(each.value.merge_commit_message, "PR_TITLE")
  squash_merge_commit_title   = try(each.value.squash_merge_commit_title, "COMMIT_OR_PR_TITLE")
  squash_merge_commit_message = try(each.value.squash_merge_commit_message, "COMMIT_MESSAGES")
  web_commit_signoff_required = try(each.value.web_commit_signoff_required, false)
  topics                      = try(each.value.topics, [])

  dynamic "security_and_analysis" {
    for_each = try(each.value.security_and_analysis, null) != null ? [each.value.security_and_analysis] : []
    content {
      dynamic "advanced_security" {
        for_each = each.value.visibility != "public" && try(security_and_analysis.value.advanced_security, null) != null ? [security_and_analysis.value.advanced_security] : []
        content {
          status = advanced_security.value.status
        }
      }
      dynamic "secret_scanning" {
        for_each = try(security_and_analysis.value.secret_scanning, null) != null ? [security_and_analysis.value.secret_scanning] : []
        content {
          status = secret_scanning.value.status
        }
      }
      dynamic "secret_scanning_push_protection" {
        for_each = try(security_and_analysis.value.secret_scanning_push_protection, null) != null ? [security_and_analysis.value.secret_scanning_push_protection] : []
        content {
          status = secret_scanning_push_protection.value.status
        }
      }
    }
  }

  lifecycle {
    precondition {
      condition     = each.value.visibility != "public" || try(each.value.security_and_analysis.advanced_security, null) == null
      error_message = "Public repositories must omit security_and_analysis.advanced_security."
    }

    prevent_destroy = false #TODO: Review
  }
}

# ============================================================================
# Resource: github_repository_pages.repos
#
# Purpose:
#   Configures GitHub Pages settings for repositories that have a defined
#   pages block in local.repos.
#
# How it works:
#   1. Filters local.repos, selecting only repositories where repo.pages is
#      configured and not null.
#   2. Binds the resource to the corresponding repository using each.key.
#   3. Optionally configures a custom CNAME and custom build type, default workflow.
#   4. Conditionally declares a source block if source settings are provided.
#
# Output format:
#   Enables and configures GitHub Pages publishing on targeted repositories.
# ============================================================================
resource "github_repository_pages" "repos" {
  for_each = {
    for repo_name, repo in local.repos : repo_name => repo.pages
    if try(repo.pages, null) != null
  }

  repository = github_repository.repos[each.key].name
  build_type = try(each.value.build_type, "workflow")
  cname      = try(each.value.cname, null)

  dynamic "source" {
    for_each = try(each.value.source, null) != null ? [each.value.source] : []
    content {
      branch = source.value.branch
      path   = try(source.value.path, "/")
    }
  }
}

resource "github_repository_vulnerability_alerts" "repos" {
  for_each = local.repos

  repository = github_repository.repos[each.key].name
  enabled    = try(each.value.vulnerability_alerts, true)
}

resource "github_repository_dependabot_security_updates" "repos" {
  for_each = local.repos

  repository = github_repository.repos[each.key].name
  enabled    = try(each.value.dependabot_security_updates, true)
}

resource "github_team_repository" "repos" {
  for_each = local.repo_team_access

  team_id    = github_team.teams[each.value.team_name].id
  repository = github_repository.repos[each.value.repo_name].name
  permission = each.value.permission
}

resource "github_repository_environment" "envs" {
  for_each = local.repo_environments

  repository          = github_repository.repos[each.value.repo_name].name
  environment         = each.value.env_name
  wait_timer          = try(each.value.env.wait_timer, 0)
  prevent_self_review = try(each.value.env.prevent_self_review, false)
  can_admins_bypass   = try(each.value.env.can_admins_bypass, true)

  dynamic "reviewers" {
    for_each = try(each.value.env.reviewers, null) != null ? [each.value.env.reviewers] : []
    content {
      users = try(reviewers.value.users, [])
      teams = try(reviewers.value.teams, [])
    }
  }

  dynamic "deployment_branch_policy" {
    for_each = try(each.value.env.deployment_branch_policy, null) != null ? [each.value.env.deployment_branch_policy] : []
    content {
      protected_branches     = deployment_branch_policy.value.protected_branches
      custom_branch_policies = deployment_branch_policy.value.custom_branch_policies
    }
  }
}

# ============================================================================
# Resource: github_branch_protection.repos
#
# Purpose:
#   Configures default branch protection rules (e.g. reviews, linear history)
#   for repositories that have a defined branch_protection block in local.repos.
#
# How it works:
#   1. Filters local.repos, targeting only repositories where the
#      branch_protection configuration is defined.
#   2. Resolves the repository node ID from the github_repository.repos resource map.
#   3. Sets the protected branch pattern matching default_branch (defaulting to "main").
#   4. Enforces linear history, PR review count requirements, stale review dismissal,
#      conversation resolution, and force push bypass permissions based on the config.
#
# Output format:
#   Provisions strict branch protections on the default branch of targeted repositories.
# ============================================================================
resource "github_branch_protection" "repos" {
  for_each = {
    for k, v in local.repos : k => v if try(v.branch_protection, null) != null
  }

  repository_id = github_repository.repos[each.key].node_id
  pattern       = try(each.value.default_branch, "main")

  required_linear_history         = try(each.value.branch_protection.require_linear_history, false)
  require_conversation_resolution = try(each.value.branch_protection.require_conversation_resolution, false)
  force_push_bypassers            = try(each.value.branch_protection.force_push_bypassers, [])

  required_pull_request_reviews {
    required_approving_review_count = try(each.value.branch_protection.required_reviews, 1)
    dismiss_stale_reviews           = try(each.value.branch_protection.dismiss_stale_reviews, false)
  }
}
