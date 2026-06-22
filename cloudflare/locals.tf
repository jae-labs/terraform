locals {
  account_id = "9fac8f4aa513faa30a47e34439f9702c"

  zones = {
    "justanother.engineer" = {
      type                  = "full"
      dnssec                = "disabled" # DNSSEC: status of DNSSEC for the zone (disabled or active)
      universal_ssl_enabled = true       # Universal SSL: enables Cloudflare's free Universal SSL certificates
      waf_ruleset_name      = "Zone-level custom rules"
      waf_ruleset_kind      = "zone"
      waf_ruleset_phase     = "http_request_firewall_custom"
      dns_settings = {
        flatten_all_cnames  = false # CNAME Flattening: flattens all CNAMEs in the zone if true
        foundation_dns      = false # Foundation DNS: enables premium DNS infrastructure if true
        multi_provider      = false # Multi-Provider: enables multi-provider DNS setup if true
        secondary_overrides = false # Secondary Overrides: allows secondary DNS overrides if true
        ns_ttl              = 86400 # NS TTL: Time-To-Live for nameserver records (seconds)
      }
      settings = {
        "0rtt"                     = "on"              # 0-RTT Connection Resume: improves TLS performance by resuming connections instantly
        "always_online"            = "off"             # Always Online: serves cached copies of pages if the origin server goes down
        "always_use_https"         = "on"              # Always Use HTTPS: redirects all HTTP requests to HTTPS
        "automatic_https_rewrites" = "on"              # Automatic HTTPS Rewrites: rewrites HTTP links to HTTPS dynamically
        "brotli"                   = "on"              # Brotli Compression: speeds up page load times for HTTPS traffic using Brotli
        "browser_cache_ttl"        = 0                 # Browser Cache TTL: 0 means respect existing headers
        "browser_check"            = "on"              # Browser Integrity Check: checks HTTP headers from visitors for threats
        "cache_level"              = "aggressive"      # Caching Level: controls how much of static content is cached
        "challenge_ttl"            = 1800              # Challenge TTL: length of time a visitor who passes a challenge is allowed access
        "cname_flattening"         = "flatten_at_root" # CNAME Flattening: how Cloudflare handles CNAMEs at the zone apex
        "development_mode"         = "off"             # Development Mode: bypasses edge cache to load from origin directly
        "early_hints"              = "on"              # Early Hints: allows edge to send Link headers before origin response for faster preloading
        "ech"                      = "on"              # Encrypted Client Hello: encrypts server name indication (SNI) in TLS handshake
        "edge_cache_ttl"           = 7200              # Edge Cache TTL: duration Cloudflare edges cache assets (seconds)
        "email_obfuscation"        = "on"              # Email Obfuscation: encrypts email addresses on the page to prevent harvesting by bots
        "hotlink_protection"       = "off"             # Hotlink Protection: prevents other sites from linking directly to your images/assets
        "http3"                    = "on"              # HTTP/3: enables HTTP/3 (QUIC) support
        "ip_geolocation"           = "on"              # IP Geolocation: includes country code of visitor IP in CF-IPCountry header
        "ipv6"                     = "on"              # IPv6 Compatibility: enables IPv6 support on the zone
        "max_upload"               = 100               # Maximum Upload Size: limit on file upload size in MB
        "min_tls_version"          = "1.0"             # Minimum TLS Version: minimum TLS protocol version allowed for HTTPS requests
        "opportunistic_encryption" = "on"              # Opportunistic Encryption: lets browsers resolve HTTP resources securely via HTTP/2 Alt-Svc
        "opportunistic_onion"      = "on"              # Opportunistic Onion: routes traffic to Onion services for Tor browser users
        "pq_keyex"                 = "on"              # Post-Quantum Cryptography: enables post-quantum key exchange in TLS handshakes
        "privacy_pass"             = "on"              # Private Access Tokens / Privacy Pass: allows users to bypass challenges using cryptographically signed tokens
        "pseudo_ipv4"              = "off"             # Pseudo IPv4: adds an IPv4 header containing pseudo IPv4 address for IPv6-only clients
        "replace_insecure_js"      = "on"              # Replace Insecure JS: replaces known vulnerable JavaScript libraries with secure versions
        "rocket_loader"            = "on"              # Rocket Loader: improves load times for pages containing JavaScript
        "security_level"           = "essentially_off" # Security Level: controls how aggressive security challenges are presented to visitors
        "server_side_exclude"      = "on"              # Server Side Exclude: hides sensitive content from suspicious visitors
        "ssl"                      = "strict"          # SSL/TLS Encryption Mode: strict requires a valid certificate on the origin
        "tls_1_2_only"             = "off"             # TLS 1.2 Only: restricts TLS connections to version 1.2 only
        "tls_1_3"                  = "zrt"             # TLS 1.3: enables TLS 1.3 protocol and 0-RTT options
        "tls_client_auth"          = "off"             # TLS Client Auth: requires TLS client certificates for incoming requests
        "waf"                      = "off"             # Web Application Firewall: enables old-style WAF engine (superseded by custom rulesets)
        "websockets"               = "on"              # WebSockets: enables WebSocket connections to the origin server

        # Minify: minifies files dynamically to reduce size
        "minify" = {
          css  = "off" # Minify CSS: minifies CSS files dynamically (on or off)
          html = "off" # Minify HTML: minifies HTML files dynamically (on or off)
          js   = "off" # Minify JS: minifies JS files dynamically (on or off)
        }

        # Mobile Redirect: redirects mobile devices to a subdomain
        "mobile_redirect" = {
          status           = "off" # Mobile Redirect Status: enables/disables redirect (on or off)
          mobile_subdomain = null  # Mobile Subdomain: target subdomain for mobile traffic redirection
          strip_uri        = false # Strip URI: if true, drops path/query component during redirect
        }

        # Security Header (HSTS): enforces HTTPS on visitor browsers
        "security_header" = {
          strict_transport_security = {
            enabled            = false # HSTS Enabled: enforces HTTPS connections from browsers (true or false)
            max_age            = 0     # HSTS Max Age: browser caching time of HTTPS-only rule (seconds)
            include_subdomains = false # HSTS Include Subdomains: applies HSTS policy to all subdomains if true
            preload            = false # HSTS Preload: requests domain inclusion in the HSTS browser preload list
            nosniff            = false # X-Content-Type-Options: inserts nosniff header to prevent MIME sniffing
          }
        }
      }
      waf_rules = [
        {
          action      = "skip"
          expression  = "(http.host eq \"media.justanother.engineer\")"
          description = "Skip hotlink protection for media.justanother.engineer"
          enabled     = true
          action_parameters = {
            products = ["hot"]
          }
        }
      ]
    }
  }

  dns_records = {
    "justanother.engineer" = {
      "ha-a" = {
        type     = "A"
        name     = "ha"
        content  = "100.94.209.62"
        ttl      = 1
        proxied  = false
        comment  = "Home Assistant - Tailscale"
        priority = null
      }
      "oci-a" = {
        type     = "A"
        name     = "oci"
        content  = "141.147.61.91"
        ttl      = 1
        proxied  = false
        comment  = "OCI instance"
        priority = null
      }
      "oci-prod-1-tunnel" = {
        type     = "CNAME"
        name     = "oci-prod-1"
        content  = "${cloudflare_zero_trust_tunnel_cloudflared.tunnels["oci-prod-1"].id}.cfargotunnel.com"
        ttl      = 1
        proxied  = true
        comment  = "oci-prod-1 instance via Cloudflare Tunnel"
        priority = null
      }
      "root-cname" = {
        type     = "CNAME"
        name     = "justanother.engineer"
        content  = "jae-pages.pages.dev"
        ttl      = 1
        proxied  = true
        comment  = "Cloudflare Pages"
        priority = null
      }
      "www-cname" = {
        type     = "CNAME"
        name     = "www"
        content  = "justanother.engineer"
        ttl      = 1
        proxied  = true
        comment  = null
        priority = null
      }
      "mx-zoho-1" = {
        type     = "MX"
        name     = "justanother.engineer"
        content  = "mx.zoho.com"
        ttl      = 1
        proxied  = false
        comment  = null
        priority = 10
      }
      "mx-zoho-2" = {
        type     = "MX"
        name     = "justanother.engineer"
        content  = "mx2.zoho.com"
        ttl      = 1
        proxied  = false
        comment  = null
        priority = 20
      }
      "mx-zoho-3" = {
        type     = "MX"
        name     = "justanother.engineer"
        content  = "mx3.zoho.com"
        ttl      = 1
        proxied  = false
        comment  = null
        priority = 30
      }
      "txt-gh-org-pages" = {
        type     = "TXT"
        name     = "_github-pages-challenge-jae-labs"
        content  = "\"d607d0093ff674e6c0c362437b7fc4\""
        ttl      = 1
        proxied  = false
        comment  = "GitHub Org Domain Validation"
        priority = null
      }
      "txt-gh-org" = {
        type     = "TXT"
        name     = "_gh-jae-labs-o"
        content  = "\"9063a009e9\""
        ttl      = 1
        proxied  = false
        comment  = "GitHub Org Domain Validation"
        priority = null
      }
      "txt-google-verification" = {
        type     = "TXT"
        name     = "justanother.engineer"
        content  = "google-site-verification=X_3eoCG2CVQl0pCspNHhKplB2hkwJGKeqzVmqJknhzk"
        ttl      = 1
        proxied  = false
        comment  = null
        priority = null
      }
      "txt-spf" = {
        type     = "TXT"
        name     = "justanother.engineer"
        content  = "v=spf1 include:zoho.com ~all"
        ttl      = 1
        proxied  = false
        comment  = null
        priority = null
      }
    }
  }

  members = {}

  kv_namespaces = {
    "jae-pages-chat-rate-limit" = {
      title = "jae-pages-chat-rate-limit"
    }
  }

  pages_projects = {
    "jae-pages" = {
      production_branch   = "main"
      compatibility_date  = "2026-05-25"
      compatibility_flags = ["nodejs_compat"]
      build_config = {
        build_command   = null
        destination_dir = "dist"
        root_dir        = null
      }
      kv_bindings = {
        RATE_LIMIT_KV = "jae-pages-chat-rate-limit"
      }
      custom_domains = [
        "justanother.engineer"
      ]
    }
  }

  worker_scripts = {
    "media-proxy" = {
      content_file       = "worker.js"
      compatibility_date = "2026-05-25"
    }
  }

  worker_custom_domains = {
    "media-domain" = {
      hostname = "media.justanother.engineer"
      zone     = "justanother.engineer"
      service  = "media-proxy"
    }
  }

  # ============================================================================
  # Local Mapping: tunnels
  #
  # Purpose:
  #   Configure Cloudflare Zero Trust tunnels for secure outbound-only
  #   connections from origin infrastructure to the Cloudflare edge network.
  #   The tunnel connector (cloudflared) runs on the origin and establishes
  #   an outbound connection to Cloudflare, eliminating the need for public
  #   IP port exposure.
  #
  # How it works:
  #   1. Defines each tunnel by a unique key (e.g., "oci-prod-1").
  #   2. Specifies the tunnel name, the public hostname that will route
  #      traffic through the tunnel, and the local service to forward to.
  #   3. The DNS CNAME record for the tunnel is defined in dns_records,
  #      referencing the tunnel's auto-generated CNAME.
  #   4. Used by for_each in tunnel resources in main.tf to create the
  #      Cloudflare tunnel and its ingress configuration.
  #
  # Output format:
  #   {
  #     "<tunnel_key>" = {
  #       name          = "<tunnel_name>"
  #       hostname      = "<public_hostname>"
  #       local_service = "<local_service_url>"
  #     }
  #   }
  # ============================================================================
  tunnels = {
    "oci-prod-1" = {
      name              = "oci-prod-1-tunnel"
      hostname          = "oci-prod-1.justanother.engineer"
      local_service     = "http://127.0.0.1:8080"
      no_tls_verify     = true
      catch_all_service = "http_status:404"
    }
  }
}
