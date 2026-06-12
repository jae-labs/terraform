locals {
  environment  = "prod"
  project_name = "oci"

  vcns = {
    main = {
      cidr_block   = "10.80.0.0/16"
      display_name = "oci-prod-vcn"
    }
  }

  internet_gateways = {
    main = {
      vcn_key      = "main"
      enabled      = true
      display_name = "oci-prod-igw"
    }
  }

  route_tables = {
    public = {
      vcn_key      = "main"
      display_name = "oci-prod-public-rt"
      route_rules = [
        {
          destination      = "0.0.0.0/0"
          destination_type = "CIDR_BLOCK"
          gateway_key      = "main"
        }
      ]
    }
  }

  security_lists = {
    public = {
      vcn_key      = "main"
      display_name = "oci-prod-public-sl"
      egress_security_rules = [
        {
          destination      = "0.0.0.0/0"
          destination_type = "CIDR_BLOCK"
          protocol         = "all"
          stateless        = false
        }
      ]
    }
  }

  subnets = {
    public = {
      vcn_key                    = "main"
      cidr_block                 = "10.80.0.0/24"
      display_name               = "oci-prod-public-subnet"
      prohibit_public_ip_on_vnic = false
      route_table_key            = "public"
      security_list_keys         = ["public"]
    }
  }

  network_security_groups = {
    main = {
      vcn_key      = "main"
      display_name = "oci-prod-nsg"
    }
  }

  network_security_group_security_rules = {
    egress_all = {
      network_security_group_key = "main"
      direction                  = "EGRESS"
      protocol                   = "all"
      destination                = "0.0.0.0/0"
      destination_type           = "CIDR_BLOCK"
      stateless                  = false
    }
  }

  instances = {
    main = {
      display_name                = "oci-prod-1"
      subnet_key                  = "public"
      network_security_group_keys = ["main"]
      private_ip                  = "10.80.0.10"
      assign_private_dns_record   = true
      assign_public_ip            = false
      shape                       = "VM.Standard.E2.2"
      shape_config                = null
      boot_volume_size_gbs        = 200
      image = {
        image_id                 = var.image_id
        operating_system         = "Canonical Ubuntu"
        operating_system_version = "24.04"
      }
    }
  }

  public_ips = {
    main = {
      instance_key = "main"
      lifetime     = "RESERVED"
      display_name = "oci-prod-1-public-ip"
    }
  }

  object_storage_buckets = {
    media = {
      name         = "oci-prod-jae-pages-media"
      access_type  = "ObjectReadWithoutList"
      storage_tier = "Standard"
    }
  }

  block_volumes = {}

  volume_attachments = {}

  common_freeform_tags = {
    Environment = local.environment
    ManagedBy   = "Terraform"
    Project     = local.project_name
  }

  internet_cidr_block = "0.0.0.0/0"
  resource_name       = "${local.project_name}-${local.environment}"

  tailscale_auth_key_escaped = replace(trimspace(var.TAILSCALE_AUTH_KEY), "'", "'\"'\"'")

  tailscale_bootstrap_user_data = <<-EOT
    #!/bin/bash
    set -euxo pipefail

    install -d -m 0700 /etc/tailscale
    curl -fsSL https://tailscale.com/install.sh | sh
    cat >/etc/sysctl.d/99-tailscale.conf <<'EOF'
    net.ipv4.ip_forward = 1
    net.ipv6.conf.all.forwarding = 1
    EOF

    sysctl --system
    printf '%s\n' '${local.tailscale_auth_key_escaped}' > /etc/tailscale/auth.key
    chmod 0600 /etc/tailscale/auth.key
    systemctl enable --now tailscaled
    tailscale up \
      --auth-key=file:/etc/tailscale/auth.key \
      --hostname=${local.instances.main.display_name} \
      --advertise-tags=tag:prod \
      --advertise-exit-node \
      --ssh
    rm -f /etc/tailscale/auth.key
  EOT
}
