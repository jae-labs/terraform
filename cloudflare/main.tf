locals {
  # ============================================================================
  # Local Mapping: zone_dns_records
  #
  # Purpose:
  #   Flatten the nested DNS records defined per zone in local.dns_records into
  #   a single map, enabling the creation of individual cloudflare_dns_record resources.
  #
  # How it works:
  #   1. Iterates over all DNS zones in local.dns_records.
  #   2. Iterates over the records configured for each zone.
  #   3. Generates a flat entry object containing record details, using default values
  #      for TTL (1) and proxy status (false) if omitted.
  #   4. Flattens the nested lists of entry objects.
  #   5. Projects that flat list into a map keyed by "zone_name:record_key".
  #
  # Output format:
  #   {
  #     "<zone>:<record_key>" = {
  #       composite_key = "<zone>:<record_key>"
  #       zone          = "<zone>"
  #       type          = "<type>"
  #       name          = "<name>"
  #       content       = "<content>"
  #       ttl           = <ttl_number>
  #       proxied       = <true_or_false>
  #       comment       = "<comment>"
  #       priority      = <priority_number>
  #     }
  #   }
  # ============================================================================
  zone_dns_records = {
    for entry in flatten([
      for zone, records in local.dns_records : [
        for key, r in records : {
          composite_key = "${zone}:${key}"
          zone          = zone
          type          = r.type
          name          = r.name
          content       = r.content
          ttl           = try(r.ttl, 1)
          proxied       = try(r.proxied, false)
          comment       = try(r.comment, null)
          priority      = try(r.priority, null)
        }
      ]
    ]) : entry.composite_key => entry
  }

  # ============================================================================
  # Local Mapping: pages_domains
  #
  # Purpose:
  #   Flatten the nested custom domains associated with each Cloudflare Pages
  #   project in local.pages_projects into a single flat map. This allows
  #   provisioning cloudflare_pages_domain resources for each project domain pair.
  #
  # How it works:
  #   1. Iterates over all Cloudflare Pages projects in local.pages_projects.
  #   2. Loops through the custom_domains list defined under each project.
  #   3. Builds a configuration object detailing the compound key, project name,
  #      and domain.
  #   4. Flattens the nested structures into a single list.
  #   5. Projects the flat list into a map keyed by "project_name:domain_name".
  #
  # Output format:
  #   {
  #     "<project>:<domain>" = {
  #       composite_key = "<project>:<domain>"
  #       project       = "<project>"
  #       domain        = "<domain>"
  #     }
  #   }
  # ============================================================================
  pages_domains = {
    for entry in flatten([
      for project, config in local.pages_projects : [
        for domain in try(config.custom_domains, []) : {
          composite_key = "${project}:${domain}"
          project       = project
          domain        = domain
        }
      ]
    ]) : entry.composite_key => entry
  }

  # ============================================================================
  # Local Mapping: zone_settings
  #
  # Purpose:
  #   Flatten the nested zone settings defined under each zone in local.zones
  #   into a single flat map. This allows provisioning individual setting values
  #   using the cloudflare_zone_setting resource.
  #
  # How it works:
  #   1. Iterates over all zones in local.zones.
  #   2. Loops through the settings map defined under each zone.
  #   3. Projects the nested fields into a key value map, combining them
  #      using merge.
  #
  # Output format:
  #   {
  #     "<zone>:<setting_id>" = {
  #       zone    = "<zone>"
  #       setting = "<setting_id>"
  #       value   = <setting_value>
  #     }
  #   }
  # ============================================================================
  zone_settings = merge([
    for zone, config in local.zones : {
      for setting, val in try(config.settings, {}) : "${zone}:${setting}" => {
        zone    = zone
        setting = setting
        value   = val
      }
    }
  ]...)
}

resource "cloudflare_zone" "zones" {
  for_each = local.zones

  account = {
    id = local.account_id
  }
  name = each.key
  type = try(each.value.type, "full")

  lifecycle {
    prevent_destroy = true
  }
}

resource "cloudflare_dns_record" "records" {
  for_each = local.zone_dns_records

  zone_id  = cloudflare_zone.zones[each.value.zone].id
  type     = each.value.type
  name     = each.value.name
  content  = each.value.content
  ttl      = each.value.ttl
  proxied  = each.value.proxied
  comment  = each.value.comment
  priority = each.value.priority
}

resource "cloudflare_account_member" "members" {
  for_each = local.members

  account_id = local.account_id
  email      = each.key
  roles      = each.value.roles
  status     = "accepted"
}

resource "cloudflare_workers_kv_namespace" "kv_namespaces" {
  for_each = local.kv_namespaces

  account_id = local.account_id
  title      = each.value.title
}

# ============================================================================
# Resource: cloudflare_pages_project.pages_projects
#
# Purpose:
#   Provision Cloudflare Pages projects from local.pages_projects, defining
#   build commands, destination directories, and environment-specific settings.
#
# How it works:
#   1. Iterates over all projects configured in local.pages_projects.
#   2. Dynamically builds the optional `build_config` if specified.
#   3. Dynamically builds `deployment_configs` for preview and production environments
#      when any compatibility variables or KV namespace bindings are specified.
#   4. Maps each KV namespace binding key to its corresponding ID from the
#      `cloudflare_workers_kv_namespace.kv_namespaces` resource map.
#
# Output format (for deployment_configs):
#   {
#     preview = {
#       compatibility_date  = "2026-05-25"
#       compatibility_flags = ["nodejs_compat"]
#       kv_namespaces = {
#         RATE_LIMIT_KV = {
#           namespace_id = "<resolved_kv_namespace_uuid>"
#         }
#       }
#     }
#     production = {
#       compatibility_date  = "2026-05-25"
#       compatibility_flags = ["nodejs_compat"]
#       kv_namespaces = {
#         RATE_LIMIT_KV = {
#           namespace_id = "<resolved_kv_namespace_uuid>"
#         }
#       }
#     }
#   }
# ============================================================================
resource "cloudflare_pages_project" "pages_projects" {
  for_each = local.pages_projects

  account_id        = local.account_id
  name              = each.key
  production_branch = try(each.value.production_branch, "main")

  # Nested build configuration mapping:
  # Maps raw build command, destination, and root directory if configured.
  build_config = try(each.value.build_config, null) != null ? {
    build_command   = try(each.value.build_config.build_command, null)
    destination_dir = try(each.value.build_config.destination_dir, null)
    root_dir        = try(each.value.build_config.root_dir, null)
  } : null

  # Nested deployment environment configurations:
  # Evaluates and creates preview/production definitions including KV namespace bindings.
  deployment_configs = (
    length(try(each.value.kv_bindings, {})) > 0 ||
    try(each.value.compatibility_date, null) != null ||
    length(try(each.value.compatibility_flags, [])) > 0
    ) ? {
    preview = {
      compatibility_date  = try(each.value.compatibility_date, null)
      compatibility_flags = try(each.value.compatibility_flags, [])

      # Maps binding keys (e.g. RATE_LIMIT_KV) to resolved KV Namespace resource IDs
      kv_namespaces = {
        for binding, namespace_key in try(each.value.kv_bindings, {}) :
        binding => {
          namespace_id = cloudflare_workers_kv_namespace.kv_namespaces[namespace_key].id
        }
      }
    }
    production = {
      compatibility_date  = try(each.value.compatibility_date, null)
      compatibility_flags = try(each.value.compatibility_flags, [])

      # Maps binding keys (e.g. RATE_LIMIT_KV) to resolved KV Namespace resource IDs
      kv_namespaces = {
        for binding, namespace_key in try(each.value.kv_bindings, {}) :
        binding => {
          namespace_id = cloudflare_workers_kv_namespace.kv_namespaces[namespace_key].id
        }
      }
    }
  } : null

  lifecycle {
    ignore_changes = [
      build_config,
      deployment_configs,
    ]
  }
}

resource "cloudflare_pages_domain" "pages_domains" {
  for_each = local.pages_domains

  account_id   = local.account_id
  project_name = cloudflare_pages_project.pages_projects[each.value.project].name
  name         = each.value.domain
}

# ============================================================================
# Resource: cloudflare_zone_setting.settings
#
# Purpose:
#   Configure individual Cloudflare zone settings by iterating over the
#   flattened local.zone_settings map.
# ============================================================================
resource "cloudflare_zone_setting" "settings" {
  for_each = local.zone_settings

  zone_id    = cloudflare_zone.zones[each.value.zone].id
  setting_id = each.value.setting
  value      = each.value.value
}

# ============================================================================
# Resource: cloudflare_ruleset.custom_waf
#
# Purpose:
#   Create custom zone-level WAF rulesets for security and traffic control,
#   such as bypassing hotlink protection.
# ============================================================================
resource "cloudflare_ruleset" "custom_waf" {
  for_each = {
    for zone, config in local.zones : zone => config if try(config.waf_rules, null) != null && length(try(config.waf_rules, [])) > 0
  }

  zone_id = cloudflare_zone.zones[each.key].id
  name    = "Zone-level custom rules"
  kind    = "zone"
  phase   = "http_request_firewall_custom"

  rules = [
    for rule in each.value.waf_rules : {
      action            = rule.action
      action_parameters = try(rule.action_parameters, null)
      expression        = rule.expression
      description       = try(rule.description, null)
      enabled           = try(rule.enabled, true)
    }
  ]
}

# ============================================================================
# Resource: cloudflare_zone_dnssec.dnssec
#
# Purpose:
#   Configure DNSSEC status (active or disabled) per zone.
# ============================================================================
resource "cloudflare_zone_dnssec" "dnssec" {
  for_each = {
    for zone, config in local.zones : zone => config if try(config.dnssec, null) != null
  }

  zone_id = cloudflare_zone.zones[each.key].id
  status  = each.value.dnssec
}

# ============================================================================
# Resource: cloudflare_universal_ssl_setting.universal_ssl
#
# Purpose:
#   Enable or disable Cloudflare Universal SSL settings for the zone.
# ============================================================================
resource "cloudflare_universal_ssl_setting" "universal_ssl" {
  for_each = {
    for zone, config in local.zones : zone => config if try(config.universal_ssl_enabled, null) != null
  }

  zone_id = cloudflare_zone.zones[each.key].id
  enabled = each.value.universal_ssl_enabled
}

# ============================================================================
# Resource: cloudflare_zone_dns_settings.dns_settings
#
# Purpose:
#   Configure zone-specific DNS resolution settings such as CNAME flattening
#   and TTLs. Ignore computed settings to prevent state drift.
# ============================================================================
resource "cloudflare_zone_dns_settings" "dns_settings" {
  for_each = {
    for zone, config in local.zones : zone => config if try(config.dns_settings, null) != null
  }

  zone_id             = cloudflare_zone.zones[each.key].id
  flatten_all_cnames  = try(each.value.dns_settings.flatten_all_cnames, null)
  foundation_dns      = try(each.value.dns_settings.foundation_dns, null)
  multi_provider      = try(each.value.dns_settings.multi_provider, null)
  secondary_overrides = try(each.value.dns_settings.secondary_overrides, null)
  ns_ttl              = try(each.value.dns_settings.ns_ttl, null)

  lifecycle {
    ignore_changes = [
      internal_dns,
      nameservers,
      soa,
      zone_mode,
    ]
  }
}
