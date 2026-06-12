# --- Data Sources ---

data "grafana_oncall_user" "luiz" {
  username = "luiz1361"
}

data "grafana_oncall_team" "admins" {
  name = "Administrators"
}

data "grafana_oncall_slack_channel" "grafana" {
  name = "grafana"
}

# --- Internal OnCall Mappings ---

locals {
  oncall_user_ids = {
    "luiz1361" = data.grafana_oncall_user.luiz.id
  }

  oncall_shifts = merge([
    for s_key, s_val in local.oncall_schedules : {
      for shift_key, shift_val in s_val.shifts :
      "${s_key}-${shift_key}" => shift_val
    }
  ]...)

  oncall_escalations = merge([
    for chain_key, chain_val in local.oncall_escalation_chains : {
      for step_key, step_val in chain_val.steps :
      "${chain_key}-${step_key}" => merge(step_val, {
        escalation_chain_id = grafana_oncall_escalation_chain.chains[chain_key].id
      })
    }
  ]...)
}

# --- Git Sync ---

resource "grafana_apps_provisioning_repository_v0alpha1" "git_sync" {
  metadata {
    uid = local.git_sync.uid
  }

  spec {
    title     = local.git_sync.title
    type      = local.git_sync.type
    workflows = local.git_sync.workflows

    sync {
      enabled          = local.git_sync.sync_enabled
      target           = local.git_sync.sync_target
      interval_seconds = local.git_sync.interval_seconds
    }

    github {
      url    = local.git_sync.github_url
      branch = local.git_sync.github_branch
    }
  }
}

# --- SLOs ---

resource "grafana_slo" "slos" {
  for_each = local.slos

  name        = each.value.name
  description = each.value.description

  destination_datasource {
    uid = local.slo_destination_datasource_uid
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
  enabled            = try(each.value.enabled, true)
  probes             = each.value.probes
  basic_metrics_only = each.value.basic_metrics_only

  dynamic "settings" {
    for_each = each.value.type == "http" ? [each.value.settings.http] : []
    content {
      http {
        fail_if_not_ssl = lookup(settings.value, "fail_if_not_ssl", false)
        method          = lookup(settings.value, "method", "GET")
        ip_version      = lookup(settings.value, "ip_version", "V4")
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

# --- k6 Performance Projects ---

resource "grafana_k6_project" "projects" {
  for_each = local.k6_projects

  name = each.value.name
}

# --- k6 Performance Load Tests ---

resource "grafana_k6_load_test" "load_tests" {
  for_each = local.k6_load_tests

  project_id = grafana_k6_project.projects[each.value.project_key].id
  name       = each.value.name
  script     = file("${path.module}/${each.value.script_file}")
}

# --- OnCall Shifts ---

resource "grafana_oncall_on_call_shift" "shifts" {
  for_each = local.oncall_shifts

  name       = each.value.name
  type       = each.value.type
  start      = each.value.start
  duration   = each.value.duration
  frequency  = each.value.frequency
  interval   = each.value.interval
  week_start = each.value.week_start
  level      = lookup(each.value, "level", null)
  team_id    = lookup(each.value, "team_name", null) != null ? data.grafana_oncall_team.admins.id : null

  rolling_users = [
    [for u in each.value.rolling_users : local.oncall_user_ids[u]]
  ]
}

# --- OnCall Schedules ---

resource "grafana_oncall_schedule" "schedules" {
  for_each = local.oncall_schedules

  name                 = each.value.name
  type                 = each.value.type
  time_zone            = each.value.time_zone
  enable_web_overrides = each.value.enable_web_overrides
  team_id              = lookup(each.value, "team_name", null) != null ? data.grafana_oncall_team.admins.id : null
  shifts               = [for shift_key, shift_val in each.value.shifts : grafana_oncall_on_call_shift.shifts["${each.key}-${shift_key}"].id]

  dynamic "slack" {
    for_each = lookup(each.value, "slack_channel", null) != null ? [1] : []
    content {
      channel_id = data.grafana_oncall_slack_channel.grafana.slack_id
    }
  }
}

# --- OnCall Escalation Chains ---

resource "grafana_oncall_escalation_chain" "chains" {
  for_each = local.oncall_escalation_chains

  name    = each.value.name
  team_id = each.value.team_name != null ? data.grafana_oncall_team.admins.id : null
}

# --- OnCall Escalation Steps ---

resource "grafana_oncall_escalation" "escalations" {
  for_each = local.oncall_escalations

  escalation_chain_id          = each.value.escalation_chain_id
  type                         = each.value.type
  position                     = each.value.position
  duration                     = lookup(each.value, "duration", null)
  persons_to_notify            = lookup(each.value, "persons_to_notify", null) != null ? [for u in each.value.persons_to_notify : local.oncall_user_ids[u]] : null
  notify_on_call_from_schedule = lookup(each.value, "notify_on_call_from_schedule", null) != null ? grafana_oncall_schedule.schedules[each.value.notify_on_call_from_schedule].id : null
  important                    = lookup(each.value, "important", null)
}
