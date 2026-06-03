locals {
  # DNS Preferences: MagicDNS state
  dns_preferences = {
    magic_dns = true # MagicDNS: enables automatic DNS resolution of tailnet devices
  }

  # DNS Nameservers: Custom global nameservers (none currently configured)
  dns_nameservers = []

  # DNS Search Paths: Custom search paths (none currently configured)
  dns_search_paths = []

  # Tailnet settings: global device and user security options
  tailnet_settings = {
    devices_approval_on       = true  # Device Authorization: requires manual approval for new devices
    devices_auto_updates_on   = true  # Device Auto-Updates: toggles automatic client updates for all devices on the tailnet
    devices_key_duration_days = 180   # Key Expiry Duration: default key expiry in days for devices (1-365)
    users_approval_on         = true  # User Approval: requires administrator approval before new users can access the tailnet
    network_flow_logging_on   = false # Network Flow Logging: logs connection flows for all devices in the tailnet
    regional_routing_on       = false # Regional Routing: enables regional routing optimizations for tailnet nodes
    https_enabled             = false # HTTPS Certificates: provisions HTTPS certificates using Let's Encrypt for MagicDNS hostnames
  }

  # Access Control List (ACL) in HuJSON format
  acl = jsonencode({
    # Declare static groups of users (optional)
    # groups = {
    #   "group:example" = ["alice@example.com", "bob@example.com"]
    # }

    # Define the tags which can be applied to devices and by which users (optional)
    # tagOwners = {
    #   "tag:example" = ["autogroup:admin"]
    # }

    # Allow all connections from any device to any device
    grants = [
      {
        src = ["*"]
        dst = ["*"]
        ip  = ["*"]
      }
    ]

    # SSH policies for managing access via Tailscale SSH
    ssh = [
      {
        action = "check"
        src    = ["autogroup:member"]
        dst    = ["autogroup:self"]
        users  = ["autogroup:nonroot", "root"]
      }
    ]
  })
}
