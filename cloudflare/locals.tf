locals {
  account_id = "9fac8f4aa513faa30a47e34439f9702c"

  zones = {
    "justanother.engineer" = {}
  }

  dns_records = {
    "justanother.engineer" = {
      "ha-a" = {
        type    = "A"
        name    = "ha"
        content = "100.94.209.62"
        proxied = false
        comment = "Home Assistant - Tailscale"
      }
      "oci-a" = {
        type    = "A"
        name    = "oci"
        content = "144.21.38.6"
        proxied = false
        comment = "OCI instance"
      }
      "root-cname" = {
        type    = "CNAME"
        name    = "justanother.engineer"
        content = "jae-pages.pages.dev"
        proxied = true
        comment = "Cloudflare Pages"
      }
      "www-cname" = {
        type    = "CNAME"
        name    = "www"
        content = "justanother.engineer"
        proxied = true
      }
      "mx-zoho-1" = {
        type     = "MX"
        name     = "justanother.engineer"
        content  = "mx.zoho.com"
        priority = 10
      }
      "mx-zoho-2" = {
        type     = "MX"
        name     = "justanother.engineer"
        content  = "mx2.zoho.com"
        priority = 20
      }
      "mx-zoho-3" = {
        type     = "MX"
        name     = "justanother.engineer"
        content  = "mx3.zoho.com"
        priority = 30
      }
      "txt-gh-org-pages" = {
        type    = "TXT"
        name    = "_github-pages-challenge-jae-labs"
        content = "\"d607d0093ff674e6c0c362437b7fc4\""
        comment = "GitHub Org Domain Validation"
      }
      "txt-gh-org" = {
        type    = "TXT"
        name    = "_gh-jae-labs-o"
        content = "\"9063a009e9\""
        comment = "GitHub Org Domain Validation"
      }
      "txt-google-verification" = {
        type    = "TXT"
        name    = "justanother.engineer"
        content = "google-site-verification=X_3eoCG2CVQl0pCspNHhKplB2hkwJGKeqzVmqJknhzk"
      }
      "txt-spf" = {
        type    = "TXT"
        name    = "justanother.engineer"
        content = "v=spf1 include:zoho.com ~all"
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
        destination_dir = "dist"
      }
      kv_bindings = {
        RATE_LIMIT_KV = "jae-pages-chat-rate-limit"
      }
      custom_domains = [
        "justanother.engineer"
      ]
    }
  }
}
