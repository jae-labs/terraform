locals {
  org = "jae-labs"

  org_settings = {
    name                                                     = "JAE Labs"
    billing_email                                            = "luiz@justanother.engineer"
    blog                                                     = "https://justanother.engineer"
    description                                              = "Just Another Engineer playing with code. A home for pet projects, open-source experiments, and community contributions."
    location                                                 = "Ireland"
    members_can_create_repositories                          = false
    default_repository_permission                            = "none"
    web_commit_signoff_required                              = false
    dependabot_alerts_enabled_for_new_repositories           = true
    dependabot_security_updates_enabled_for_new_repositories = true
    dependency_graph_enabled_for_new_repositories            = true
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
      org_roles = {
        all_repo_admin    = 8136
        all_repo_maintain = 8135
        all_repo_read     = 8132
        all_repo_triage   = 8133
        all_repo_write    = 8134
        app_manager       = 33679
        ci_cd_admin       = 26237
        security_manager  = 138
      }
    }
    "Collaborators" = {
      description = "Collaborators"
      privacy     = "closed"
      members     = ["abubakar-abiona"]
      maintainers = ["luiz1361"]
    }
  }

  repos = {
    "conCIerge" = {
      description                 = "A Slack ChatOps Bot written in GoLang which provisions resources, manages access, and automates workflows across various vendors via Terraform."
      visibility                  = "public"
      has_issues                  = true
      vulnerability_alerts        = true
      dependabot_security_updates = true
      has_wiki                    = false
      default_branch              = "main"
      topics                      = ["chatops", "slack", "golang", "iac", "bot", "terraform"]
      team_access                 = { "Maintainers" = "admin" }
      branch_protection = {
        required_reviews                = 1
        dismiss_stale_reviews           = true
        require_linear_history          = true
        require_conversation_resolution = true
        force_push_bypassers            = ["/luiz1361"]
      }
      security_and_analysis = {
        secret_scanning                 = { status = "enabled" }
        secret_scanning_push_protection = { status = "enabled" }
      }
      environments = {
        "development" = {}
        "production" = {
          deployment_branch_policy = {
            protected_branches     = true
            custom_branch_policies = false
          }
        }
      }
    }
    ".github" = {
      description                 = "Organization-wide shared GitHub templates for internal use."
      visibility                  = "public"
      has_issues                  = true
      vulnerability_alerts        = true
      dependabot_security_updates = true
      has_wiki                    = false
      default_branch              = "main"
      topics                      = ["organization-templates"]
      team_access                 = { "Maintainers" = "admin" }
      branch_protection           = null
      environments = {
        "development" = {}
        "production" = {
          deployment_branch_policy = {
            protected_branches     = true
            custom_branch_policies = false
          }
        }
      }
      security_and_analysis = {
        secret_scanning                 = { status = "enabled" }
        secret_scanning_push_protection = { status = "enabled" }
      }
    }
    "terraform" = {
      description                 = "Terraform for internal use."
      visibility                  = "public"
      has_issues                  = true
      vulnerability_alerts        = true
      dependabot_security_updates = true
      has_wiki                    = false
      default_branch              = "main"
      topics                      = ["terraform", "iac", "infrastructure-as-code"]
      team_access                 = { "Maintainers" = "admin" }
      branch_protection           = null
      environments = {
        "development" = {}
        "production" = {
          deployment_branch_policy = {
            protected_branches     = true
            custom_branch_policies = false
          }
        }
      }
      security_and_analysis = {
        secret_scanning                 = { status = "enabled" }
        secret_scanning_push_protection = { status = "enabled" }
      }
    }
    "ansible" = {
      description                 = "Ansible for internal use."
      visibility                  = "public"
      has_issues                  = true
      vulnerability_alerts        = true
      dependabot_security_updates = true
      has_wiki                    = false
      default_branch              = "main"
      topics                      = ["ansible", "configuration-management", "provisioning"]
      team_access                 = { "Maintainers" = "admin" }
      branch_protection           = null
      environments = {
        "development" = {}
        "production" = {
          deployment_branch_policy = {
            protected_branches     = true
            custom_branch_policies = false
          }
        }
      }
      security_and_analysis = {
        secret_scanning                 = { status = "enabled" }
        secret_scanning_push_protection = { status = "enabled" }
      }
    }
    "dotfiles" = {
      description                 = "dotfiles for macOS."
      visibility                  = "public"
      has_issues                  = true
      vulnerability_alerts        = true
      dependabot_security_updates = true
      default_branch              = "main"
      topics                      = ["dotfiles", "macos", "mise", "neovim", "tmux", "zsh"]
      team_access                 = { "Maintainers" = "admin" }
      branch_protection           = null
      environments = {
        "development" = {}
        "production" = {
          deployment_branch_policy = {
            protected_branches     = true
            custom_branch_policies = false
          }
        }
      }
      security_and_analysis = {
        secret_scanning                 = { status = "enabled" }
        secret_scanning_push_protection = { status = "enabled" }
      }
    }
    "flashcards" = {
      description                 = "Transform notes into flashcards with local AI. Study offline, stay private, learn smarter—for free!"
      visibility                  = "public"
      has_issues                  = true
      vulnerability_alerts        = true
      dependabot_security_updates = true
      allow_auto_merge            = true
      allow_update_branch         = true
      delete_branch_on_merge      = true
      default_branch              = "main"
      topics                      = ["ai", "cli", "flashcards", "flashcards-cli", "golang", "llama", "ollama", "sqlite"]
      team_access                 = { "Maintainers" = "admin" }
      branch_protection           = null
      environments = {
        "development" = {}
        "production" = {
          deployment_branch_policy = {
            protected_branches     = true
            custom_branch_policies = false
          }
        }
      }
      security_and_analysis = {
        secret_scanning                 = { status = "enabled" }
        secret_scanning_push_protection = { status = "enabled" }
      }
    }
    "pages" = {
      description                 = "justanother.engineer website source."
      visibility                  = "public"
      has_issues                  = true
      vulnerability_alerts        = true
      dependabot_security_updates = true
      has_discussions             = true
      has_wiki                    = true
      has_projects                = true
      homepage_url                = "http://justanother.engineer/"
      default_branch              = "main"
      topics                      = []
      team_access                 = { "Maintainers" = "admin" }
      branch_protection           = null
      environments = {
        "review" = {}
        "production" = {
          deployment_branch_policy = {
            protected_branches     = true
            custom_branch_policies = false
          }
        }
      }
      pages = {
        build_type = "workflow"
        cname      = "justanother.engineer"
      }
      security_and_analysis = {
        secret_scanning                 = { status = "enabled" }
        secret_scanning_push_protection = { status = "enabled" }
      }
    }
    "sandbox" = {
      description                 = "Playground for internal use."
      visibility                  = "public"
      has_issues                  = true
      vulnerability_alerts        = true
      dependabot_security_updates = true
      default_branch              = "main"
      team_access                 = { "Maintainers" = "admin" }
      branch_protection           = null
      security_and_analysis = {
        secret_scanning                 = { status = "enabled" }
        secret_scanning_push_protection = { status = "enabled" }
      }
      environments = {
        "development" = {}
        "production" = {
          deployment_branch_policy = {
            protected_branches     = true
            custom_branch_policies = false
          }
        }
      }
    }
    "homebrew-formulae" = {
      description                 = "A Homebrew tap that provides formulae for installing my projects."
      visibility                  = "public"
      has_issues                  = true
      vulnerability_alerts        = true
      dependabot_security_updates = true
      default_branch              = "main"
      topics                      = ["brew", "homebrew-formulae", "homebrew-tap"]
      team_access                 = { "Maintainers" = "admin" }
      branch_protection           = null
      environments = {
        "development" = {}
        "production" = {
          deployment_branch_policy = {
            protected_branches     = true
            custom_branch_policies = false
          }
        }
      }
      security_and_analysis = {
        secret_scanning                 = { status = "enabled" }
        secret_scanning_push_protection = { status = "enabled" }
      }
    }
    "scripts" = {
      description                 = "Collection of handy utility scripts."
      visibility                  = "public"
      has_issues                  = true
      vulnerability_alerts        = true
      dependabot_security_updates = true
      has_wiki                    = false
      default_branch              = "main"
      topics                      = ["automation", "bash", "python", "scripting", "shell"]
      team_access                 = { "Maintainers" = "admin" }
      branch_protection           = null
      environments = {
        "development" = {}
        "production" = {
          deployment_branch_policy = {
            protected_branches     = true
            custom_branch_policies = false
          }
        }
      }
      security_and_analysis = {
        secret_scanning                 = { status = "enabled" }
        secret_scanning_push_protection = { status = "enabled" }
      }
    }
  }
}
