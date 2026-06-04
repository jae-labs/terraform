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
    "n8n-webhook-availability" = {
      name        = "n8n Webhook Availability"
      description = "n8n webhook check success rate metric"
      query = {
        success_metric = "probe_success{job=\"n8n-prod-webhook-availability\"}"
        total_metric   = "probe_success{job=\"n8n-prod-webhook-availability\"}"
      }
      objective = 0.995
      window    = "28d"
    }
    "telemetry-availability" = {
      name        = "Telemetry Availability"
      description = "Telemetry availability metric"
      query = {
        success_metric = "up{job=~\"integrations/(alloy|cadvisor|concierge|nginx|unix)\"}"
        total_metric   = "up{job=~\"integrations/(alloy|cadvisor|concierge|nginx|unix)\"}"
      }
      objective = 0.995
      window    = "28d"
    }
  }

  synthetic_checks = {
    "justanother-engineer" = {
      target             = "https://justanother.engineer"
      job                = "justanother.engineer"
      type               = "http"
      frequency          = 1800000 # in milliseconds (30m)
      timeout            = 3000
      probes             = [7, 8, 18, 20, 21, 27, 901, 903]
      basic_metrics_only = false
      settings = {
        http = {
          fail_if_not_ssl = true
          method          = "GET"
        }
      }
    }
    "oci-n8n-webhook" = {
      target             = "https://oci.justanother.engineer/n8n/webhook/health"
      job                = "oci.justanother.engineer/n8n/webhook/health"
      type               = "http"
      frequency          = 1800000 # in milliseconds (30m)
      timeout            = 3000
      probes             = [7]
      basic_metrics_only = true
      settings = {
        http = {
          fail_if_not_ssl = true
          method          = "GET"
        }
      }
    }
    "oci-health" = {
      target              = "https://oci.justanother.engineer/health"
      job                 = "oci.justanother.engineer/health"
      type                = "browser"
      frequency           = 1800000 # in milliseconds (30m)
      timeout             = 3000
      probes              = [7]
      basic_metrics_only  = true
      browser_script_file = "scripts/oci_health_check.js"
    }
  }
}
