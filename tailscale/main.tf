# ============================================================================
# Resource: tailscale_acl.main
#
# Purpose:
#   Manage the tailnet Access Control Policy using the HuJSON acl defined in local.tf.
# ============================================================================
resource "tailscale_acl" "main" {
  acl = local.acl
}

# ============================================================================
# Resource: tailscale_dns_preferences.main
#
# Purpose:
#   Configure MagicDNS preferences for the tailnet.
# ============================================================================
resource "tailscale_dns_preferences" "main" {
  magic_dns = local.dns_preferences.magic_dns
}

# ============================================================================
# Resource: tailscale_tailnet_settings.main
#
# Purpose:
#   Configure global tailnet options (e.g., device approvals, key expiry).
# ============================================================================
resource "tailscale_tailnet_settings" "main" {
  devices_approval_on       = local.tailnet_settings.devices_approval_on
  devices_auto_updates_on   = local.tailnet_settings.devices_auto_updates_on
  devices_key_duration_days = local.tailnet_settings.devices_key_duration_days
  users_approval_on         = local.tailnet_settings.users_approval_on
  network_flow_logging_on   = local.tailnet_settings.network_flow_logging_on
  regional_routing_on       = local.tailnet_settings.regional_routing_on
  https_enabled             = local.tailnet_settings.https_enabled
}

# ============================================================================
# Resource: tailscale_dns_nameservers.main
#
# Purpose:
#   Configure global DNS nameservers for the tailnet.
# ============================================================================
resource "tailscale_dns_nameservers" "main" {
  count = length(local.dns_nameservers) > 0 ? 1 : 0

  nameservers = length(local.dns_nameservers) > 0 ? local.dns_nameservers : local.dns_nameservers_validation_fallback
}

# ============================================================================
# Resource: tailscale_dns_search_paths.main
#
# Purpose:
#   Configure search paths for the tailnet.
# ============================================================================
resource "tailscale_dns_search_paths" "main" {
  count = length(local.dns_search_paths) > 0 ? 1 : 0

  search_paths = length(local.dns_search_paths) > 0 ? local.dns_search_paths : local.dns_search_paths_validation_fallback
}
