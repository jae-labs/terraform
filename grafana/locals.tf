locals {
  # Synthetic Monitoring Probe Mapping:
  # 7   -> London
  # 8   -> Sydney
  # 18  -> Singapore
  # 20  -> SaoPaulo
  # 21  -> CapeTown
  # 27  -> Ohio
  # 901 -> Montreal
  # 903 -> UAE

  # --- Git Sync Configuration ---
  git_sync = {
    uid              = "repository-2f10cee"
    title            = "jae-labs/grafana-git-sync"
    type             = "github"
    workflows        = ["write"]
    sync_enabled     = true
    sync_target      = "folder"
    interval_seconds = 300
    github_url       = "https://github.com/jae-labs/grafana-git-sync"
    github_branch    = "main"
  }

  # --- SLOs Destination Datasource ---
  slo_destination_datasource_uid = "grafanacloud-prom"

  # --- SLOs ---
  slos = {
    "concierge-success-rate" = {
      name        = "Concierge Workflow Success Rate"
      description = "Concierge Slack workflow success rate metric"
      query = {
        success_metric = "concierge_slack_workflow_total{outcome=\"success\"}"
        total_metric   = "concierge_slack_workflow_total"
      }
      objective = 0.995
      window    = "28d"
    }
    "telemetry-availability" = {
      name        = "Telemetry Availability"
      description = "Telemetry availability metric"
      query = {
        success_metric = "up{job=~\"integrations/(alloy|cadvisor|concierge|traefik|unix)\"}"
        total_metric   = "up{job=~\"integrations/(alloy|cadvisor|concierge|traefik|unix)\"}"
      }
      objective = 0.995
      window    = "28d"
    }
  }

  # --- Synthetic Monitoring Checks ---
  synthetic_checks = {
    "justanother-engineer" = {
      target              = "https://justanother.engineer"
      job                 = "justanother.engineer - Website Availability"
      type                = "http"
      frequency           = 1800000 # in milliseconds (30m)
      timeout             = 3000
      enabled             = true
      probes              = [7, 8, 18, 20, 21, 27, 901, 903]
      basic_metrics_only  = false
      browser_script_file = null
      settings = {
        http = {
          fail_if_not_ssl = true
          method          = "GET"
          ip_version      = "V4"
        }
      }
    }
    "oci-prod-1-health" = {
      target              = "https://oci-prod-1.justanother.engineer/healthz"
      job                 = "oci-prod-1.justanother.engineer/healthz - Concierge Availability"
      type                = "http"
      frequency           = 1800000 # in milliseconds (30m)
      timeout             = 3000
      enabled             = true
      probes              = [7]
      basic_metrics_only  = true
      browser_script_file = null
      settings = {
        http = {
          fail_if_not_ssl = true
          method          = "GET"
          ip_version      = "V4"
        }
      }
    }
  }

  # --- k6 Performance Projects ---
  k6_projects = {
    "justanother-engineer" = {
      name = "justanother.engineer"
    }
  }

  # --- k6 Performance Load Tests ---
  k6_load_tests = {
    "browser-ramp-test" = {
      name        = "justanother.engineer - Browser Ramp Test"
      project_key = "justanother-engineer"
      script_file = "scripts/browser_ramp_test.js"
    }
    "health-vitals-test" = {
      name        = "justanother.engineer - Health/Vitals Test"
      project_key = "justanother-engineer"
      script_file = "scripts/health_vitals_test.js"
    }
  }

  # --- OnCall (IRM) Schedules ---
  oncall_schedules = {
    "always" = {
      name                 = "Always"
      type                 = "calendar"
      time_zone            = "Europe/Dublin"
      enable_web_overrides = true
      team_name            = "Administrators"
      slack_channel        = "grafana"
      shifts = {
        "layer-1-rotation" = {
          name          = "Layer 1 Rotation"
          type          = "rolling_users"
          start         = "2026-05-25T00:00:00"
          duration      = 86400 # 24h
          frequency     = "daily"
          interval      = 1
          week_start    = "MO"
          level         = 1
          team_name     = "Administrators"
          rolling_users = ["luiz1361"]
        }
      }
    }
  }

  # --- OnCall (IRM) Escalation Chains ---
  oncall_escalation_chains = {
    "default" = {
      name      = "Default"
      team_name = null
      steps = {
        "step-0" = {
          position                     = 0
          type                         = "notify_persons"
          duration                     = null
          persons_to_notify            = ["luiz1361"]
          notify_on_call_from_schedule = null
          important                    = null
        }
      }
    }
    "default-escalation" = {
      name      = "Default Escalation"
      team_name = "Administrators"
      steps = {
        "step-0" = {
          position                     = 0
          type                         = "wait"
          duration                     = 300
          persons_to_notify            = null
          notify_on_call_from_schedule = null
          important                    = null
        }
        "step-1" = {
          position                     = 1
          type                         = "notify_on_call_from_schedule"
          duration                     = null
          persons_to_notify            = null
          notify_on_call_from_schedule = "always"
          important                    = true
        }
      }
    }
  }
}
