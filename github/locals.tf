locals {
  org = "jae-labs"

  org_settings = {
    name                                                         = "JAE Labs"
    billing_email                                                = "luiz@justanother.engineer"
    blog                                                         = "https://justanother.engineer"
    email                                                        = null
    description                                                  = "Just Another Engineer. A home for pet projects, experiments, and OSS projects."
    location                                                     = "Ireland"
    members_can_create_repositories                              = false
    members_can_create_public_repositories                       = false
    members_can_create_private_repositories                      = false
    members_can_create_private_pages                             = false
    default_repository_permission                                = "none"
    web_commit_signoff_required                                  = false
    dependabot_alerts_enabled_for_new_repositories               = true
    dependabot_security_updates_enabled_for_new_repositories     = true
    dependency_graph_enabled_for_new_repositories                = true
    advanced_security_enabled_for_new_repositories               = false
    secret_scanning_enabled_for_new_repositories                 = false
    secret_scanning_push_protection_enabled_for_new_repositories = false
  }

  members = {
    "luiz1361"        = { role = "admin", full_name = "Luiz F. C. Martins" }
    "abubakar-abiona" = { role = "member", full_name = "Abubakar Abiona" }
  }

  teams = {
    "Maintainers" = {
      description = "Maintainers"
      privacy     = "closed"
      members     = ["luiz1361"]
      maintainers = ["luiz1361"]
      org_roles   = {}
    }
    "Collaborators" = {
      description = "Collaborators"
      privacy     = "closed"
      members     = ["abubakar-abiona"]
      maintainers = ["luiz1361"]
      org_roles   = {}
    }
  }

  repos = {
    ".github" = {
      allow_auto_merge            = false
      allow_merge_commit          = true
      allow_rebase_merge          = true
      allow_squash_merge          = true
      allow_update_branch         = false
      archived                    = false
      branch_protection           = null
      default_branch              = "main"
      delete_branch_on_merge      = false
      dependabot_security_updates = true
      description                 = "Organization-wide shared GitHub templates for internal use."
      environments = {
        "development" = {}
        "production" = {
          deployment_branch_policy = {
            protected_branches     = true
            custom_branch_policies = false
          }
        }
      }
      has_discussions      = false
      has_issues           = true
      has_projects         = false
      has_wiki             = false
      homepage_url         = null
      is_template          = false
      merge_commit_message = "PR_TITLE"
      merge_commit_title   = "MERGE_MESSAGE"
      pages                = null
      security_and_analysis = {
        secret_scanning                 = { status = "enabled" }
        secret_scanning_push_protection = { status = "enabled" }
      }
      squash_merge_commit_message = "COMMIT_MESSAGES"
      squash_merge_commit_title   = "COMMIT_OR_PR_TITLE"
      team_access                 = { "Maintainers" = "admin" }
      topics                      = ["organization-templates"]
      visibility                  = "public"
      vulnerability_alerts        = true
      web_commit_signoff_required = false
    },
    "terraform" = {
      allow_auto_merge            = false
      allow_merge_commit          = true
      allow_rebase_merge          = true
      allow_squash_merge          = true
      allow_update_branch         = false
      archived                    = false
      branch_protection           = null
      default_branch              = "main"
      delete_branch_on_merge      = false
      dependabot_security_updates = true
      description                 = "Terraform for internal use."
      environments = {
        "development" = {}
        "production" = {
          deployment_branch_policy = {
            protected_branches     = true
            custom_branch_policies = false
          }
        }
      }
      has_discussions      = false
      has_issues           = true
      has_projects         = false
      has_wiki             = false
      homepage_url         = null
      is_template          = false
      merge_commit_message = "PR_TITLE"
      merge_commit_title   = "MERGE_MESSAGE"
      pages                = null
      security_and_analysis = {
        secret_scanning                 = { status = "enabled" }
        secret_scanning_push_protection = { status = "enabled" }
      }
      squash_merge_commit_message = "COMMIT_MESSAGES"
      squash_merge_commit_title   = "COMMIT_OR_PR_TITLE"
      team_access                 = { "Maintainers" = "admin" }
      topics                      = ["terraform", "iac", "infrastructure-as-code"]
      visibility                  = "public"
      vulnerability_alerts        = true
      web_commit_signoff_required = false
    },
    "dotfiles" = {
      allow_auto_merge            = false
      allow_merge_commit          = true
      allow_rebase_merge          = true
      allow_squash_merge          = true
      allow_update_branch         = false
      archived                    = false
      branch_protection           = null
      default_branch              = "main"
      delete_branch_on_merge      = false
      dependabot_security_updates = true
      description                 = "dotfiles for macOS."
      environments = {
        "development" = {}
        "production" = {
          deployment_branch_policy = {
            protected_branches     = true
            custom_branch_policies = false
          }
        }
      }
      has_discussions      = false
      has_issues           = true
      has_projects         = false
      has_wiki             = false
      homepage_url         = null
      is_template          = false
      merge_commit_message = "PR_TITLE"
      merge_commit_title   = "MERGE_MESSAGE"
      pages                = null
      security_and_analysis = {
        secret_scanning                 = { status = "enabled" }
        secret_scanning_push_protection = { status = "enabled" }
      }
      squash_merge_commit_message = "COMMIT_MESSAGES"
      squash_merge_commit_title   = "COMMIT_OR_PR_TITLE"
      team_access                 = { "Maintainers" = "admin" }
      topics                      = ["dotfiles", "macos", "mise", "neovim", "tmux", "zsh"]
      visibility                  = "public"
      vulnerability_alerts        = true
      web_commit_signoff_required = false
    },
    "flashcards" = {
      allow_auto_merge            = true
      allow_merge_commit          = true
      allow_rebase_merge          = true
      allow_squash_merge          = true
      allow_update_branch         = true
      archived                    = false
      branch_protection           = null
      default_branch              = "main"
      delete_branch_on_merge      = true
      dependabot_security_updates = true
      description                 = "Transform notes into flashcards with local AI. Study offline, stay private, learn smarter—for free!"
      environments = {
        "development" = {}
        "production" = {
          deployment_branch_policy = {
            protected_branches     = true
            custom_branch_policies = false
          }
        }
      }
      has_discussions      = false
      has_issues           = true
      has_projects         = false
      has_wiki             = false
      homepage_url         = null
      is_template          = false
      merge_commit_message = "PR_TITLE"
      merge_commit_title   = "MERGE_MESSAGE"
      pages                = null
      security_and_analysis = {
        secret_scanning                 = { status = "enabled" }
        secret_scanning_push_protection = { status = "enabled" }
      }
      squash_merge_commit_message = "COMMIT_MESSAGES"
      squash_merge_commit_title   = "COMMIT_OR_PR_TITLE"
      team_access                 = { "Maintainers" = "admin" }
      topics                      = ["ai", "cli", "flashcards", "flashcards-cli", "golang", "llama", "ollama", "sqlite"]
      visibility                  = "public"
      vulnerability_alerts        = true
      web_commit_signoff_required = false
    },
    "pages" = {
      allow_auto_merge            = false
      allow_merge_commit          = true
      allow_rebase_merge          = true
      allow_squash_merge          = true
      allow_update_branch         = false
      archived                    = false
      branch_protection           = null
      default_branch              = "main"
      delete_branch_on_merge      = false
      dependabot_security_updates = true
      description                 = "justanother.engineer website source."
      environments = {
        "review" = {}
        "production" = {
          deployment_branch_policy = {
            protected_branches     = true
            custom_branch_policies = false
          }
        }
      }
      has_discussions      = false
      has_issues           = true
      has_projects         = false
      has_wiki             = false
      homepage_url         = "http://justanother.engineer/"
      is_template          = false
      merge_commit_message = "PR_TITLE"
      merge_commit_title   = "MERGE_MESSAGE"
      pages = {
        build_type = "workflow"
        cname      = "justanother.engineer"
      }
      security_and_analysis = {
        secret_scanning                 = { status = "enabled" }
        secret_scanning_push_protection = { status = "enabled" }
      }
      squash_merge_commit_message = "COMMIT_MESSAGES"
      squash_merge_commit_title   = "COMMIT_OR_PR_TITLE"
      team_access                 = { "Maintainers" = "admin" }
      topics                      = []
      visibility                  = "public"
      vulnerability_alerts        = true
      web_commit_signoff_required = false
    },
    "sandbox" = {
      allow_auto_merge            = false
      allow_merge_commit          = true
      allow_rebase_merge          = true
      allow_squash_merge          = true
      allow_update_branch         = false
      archived                    = false
      branch_protection           = null
      default_branch              = "main"
      delete_branch_on_merge      = false
      dependabot_security_updates = true
      description                 = "Playground for internal use."
      environments = {
        "development" = {}
        "production" = {
          deployment_branch_policy = {
            protected_branches     = true
            custom_branch_policies = false
          }
        }
      }
      has_discussions      = true
      has_issues           = true
      has_projects         = true
      has_wiki             = true
      homepage_url         = null
      is_template          = false
      merge_commit_message = "PR_TITLE"
      merge_commit_title   = "MERGE_MESSAGE"
      pages                = null
      security_and_analysis = {
        secret_scanning                 = { status = "enabled" }
        secret_scanning_push_protection = { status = "enabled" }
      }
      squash_merge_commit_message = "COMMIT_MESSAGES"
      squash_merge_commit_title   = "COMMIT_OR_PR_TITLE"
      team_access                 = { "Maintainers" = "admin" }
      topics                      = []
      visibility                  = "public"
      vulnerability_alerts        = true
      web_commit_signoff_required = false
    },
    "homebrew-formulae" = {
      allow_auto_merge            = false
      allow_merge_commit          = true
      allow_rebase_merge          = true
      allow_squash_merge          = true
      allow_update_branch         = false
      archived                    = false
      branch_protection           = null
      default_branch              = "main"
      delete_branch_on_merge      = false
      dependabot_security_updates = true
      description                 = "A Homebrew tap that provides formulae for installing my projects."
      environments = {
        "development" = {}
        "production" = {
          deployment_branch_policy = {
            protected_branches     = true
            custom_branch_policies = false
          }
        }
      }
      has_discussions      = false
      has_issues           = true
      has_projects         = false
      has_wiki             = false
      homepage_url         = null
      is_template          = false
      merge_commit_message = "PR_TITLE"
      merge_commit_title   = "MERGE_MESSAGE"
      pages                = null
      security_and_analysis = {
        secret_scanning                 = { status = "enabled" }
        secret_scanning_push_protection = { status = "enabled" }
      }
      squash_merge_commit_message = "COMMIT_MESSAGES"
      squash_merge_commit_title   = "COMMIT_OR_PR_TITLE"
      team_access                 = { "Maintainers" = "admin" }
      topics                      = ["brew", "homebrew-formulae", "homebrew-tap"]
      visibility                  = "public"
      vulnerability_alerts        = true
      web_commit_signoff_required = false
    },
    "scripts" = {
      allow_auto_merge            = false
      allow_merge_commit          = true
      allow_rebase_merge          = true
      allow_squash_merge          = true
      allow_update_branch         = false
      archived                    = false
      branch_protection           = null
      default_branch              = "main"
      delete_branch_on_merge      = false
      dependabot_security_updates = true
      description                 = "Collection of handy utility scripts."
      environments = {
        "development" = {}
        "production" = {
          deployment_branch_policy = {
            protected_branches     = true
            custom_branch_policies = false
          }
        }
      }
      has_discussions      = false
      has_issues           = true
      has_projects         = false
      has_wiki             = false
      homepage_url         = null
      is_template          = false
      merge_commit_message = "PR_TITLE"
      merge_commit_title   = "MERGE_MESSAGE"
      pages                = null
      security_and_analysis = {
        secret_scanning                 = { status = "enabled" }
        secret_scanning_push_protection = { status = "enabled" }
      }
      squash_merge_commit_message = "COMMIT_MESSAGES"
      squash_merge_commit_title   = "COMMIT_OR_PR_TITLE"
      team_access                 = { "Maintainers" = "admin" }
      topics                      = ["automation", "bash", "python", "scripting", "shell"]
      visibility                  = "public"
      vulnerability_alerts        = true
      web_commit_signoff_required = false
    },
    "template" = {
      allow_auto_merge            = false
      allow_merge_commit          = true
      allow_rebase_merge          = true
      allow_squash_merge          = true
      allow_update_branch         = false
      archived                    = false
      branch_protection           = null
      default_branch              = "main"
      delete_branch_on_merge      = false
      dependabot_security_updates = true
      description                 = "GitHub Repository Template."
      environments = {
        "development" = {}
        "production" = {
          deployment_branch_policy = {
            protected_branches     = true
            custom_branch_policies = false
          }
        }
      }
      has_discussions      = false
      has_issues           = true
      has_projects         = false
      has_wiki             = false
      homepage_url         = null
      is_template          = true
      merge_commit_message = "PR_TITLE"
      merge_commit_title   = "MERGE_MESSAGE"
      pages                = null
      security_and_analysis = {
        secret_scanning                 = { status = "enabled" }
        secret_scanning_push_protection = { status = "enabled" }
      }
      squash_merge_commit_message = "COMMIT_MESSAGES"
      squash_merge_commit_title   = "COMMIT_OR_PR_TITLE"
      team_access                 = { "Maintainers" = "admin" }
      topics                      = ["template", "bootstrap", "github-template", "repository-template"]
      visibility                  = "public"
      vulnerability_alerts        = true
      web_commit_signoff_required = false
    }
    "skills" = {
      allow_auto_merge            = false
      allow_merge_commit          = true
      allow_rebase_merge          = true
      allow_squash_merge          = true
      allow_update_branch         = false
      archived                    = false
      branch_protection           = null
      default_branch              = "main"
      delete_branch_on_merge      = false
      dependabot_security_updates = true
      description                 = "Agent Skills."
      environments = {
        "development" = {}
        "production" = {
          deployment_branch_policy = {
            protected_branches     = true
            custom_branch_policies = false
          }
        }
      }
      has_discussions      = false
      has_issues           = true
      has_projects         = false
      has_wiki             = false
      homepage_url         = null
      is_template          = false
      merge_commit_message = "PR_TITLE"
      merge_commit_title   = "MERGE_MESSAGE"
      pages                = null
      security_and_analysis = {
        secret_scanning                 = { status = "enabled" }
        secret_scanning_push_protection = { status = "enabled" }
      }
      squash_merge_commit_message = "COMMIT_MESSAGES"
      squash_merge_commit_title   = "COMMIT_OR_PR_TITLE"
      team_access                 = { "Maintainers" = "admin" }
      topics                      = ["skills", "agent", "agent-skills", "cursor", "antigravity", "claude-code", "opencode", "prompt-engineering", "ai", "codex"]
      visibility                  = "public"
      vulnerability_alerts        = true
      web_commit_signoff_required = false
    }
  }
}
