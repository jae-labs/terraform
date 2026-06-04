# --- Git Sync ---

resource "grafana_apps_provisioning_repository_v0alpha1" "git_sync" {
  metadata {
    uid = "repository-2f10cee"
  }

  spec {
    title     = "jae-labs/grafana-git-sync"
    type      = "github"
    workflows = ["write"]

    sync {
      enabled          = true
      target           = "folder"
      interval_seconds = 300
    }

    github {
      url    = "https://github.com/jae-labs/grafana-git-sync"
      branch = "main"
    }
  }
}

# --- SLOs ---

resource "grafana_slo" "slos" {
  for_each = local.slos

  name        = each.value.name
  description = each.value.description

  destination_datasource {
    uid = "grafanacloud-prom"
  }

  query {
    type = "ratio"
    ratio {
      success_metric = each.value.query.success_metric
      total_metric   = each.value.query.total_metric
    }
  }

  objectives {
    value  = each.value.objective
    window = each.value.window
  }
}

# --- Synthetic Monitoring Checks ---

resource "grafana_synthetic_monitoring_check" "checks" {
  for_each = local.synthetic_checks

  target             = each.value.target
  job                = each.value.job
  frequency          = each.value.frequency
  timeout            = each.value.timeout
  enabled            = true
  probes             = each.value.probes
  basic_metrics_only = each.value.basic_metrics_only

  dynamic "settings" {
    for_each = each.value.type == "http" ? [each.value.settings.http] : []
    content {
      http {
        fail_if_not_ssl = lookup(settings.value, "fail_if_not_ssl", false)
        method          = lookup(settings.value, "method", "GET")
        ip_version      = "V4"
      }
    }
  }

  dynamic "settings" {
    for_each = each.value.type == "browser" ? [1] : []
    content {
      browser {
        script = file("${path.module}/${each.value.browser_script_file}")
      }
    }
  }
}
