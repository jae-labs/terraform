moved {
  from = oci_core_vcn.main
  to   = oci_core_vcn.main["main"]
}

moved {
  from = oci_core_internet_gateway.main
  to   = oci_core_internet_gateway.main["main"]
}

moved {
  from = oci_core_route_table.public
  to   = oci_core_route_table.public["public"]
}

moved {
  from = oci_core_security_list.public
  to   = oci_core_security_list.public["public"]
}

moved {
  from = oci_core_subnet.public
  to   = oci_core_subnet.public["public"]
}

moved {
  from = oci_core_network_security_group.main
  to   = oci_core_network_security_group.main["main"]
}

moved {
  from = oci_core_network_security_group_security_rule.egress_all
  to   = oci_core_network_security_group_security_rule.main["egress_all"]
}

moved {
  from = oci_core_network_security_group_security_rule.ssh_ingress
  to   = oci_core_network_security_group_security_rule.main["ssh_ingress"]
}

moved {
  from = oci_core_instance.main[0]
  to   = oci_core_instance.main["main"]
}

moved {
  from = oci_core_public_ip.main[0]
  to   = oci_core_public_ip.main["main"]
}

moved {
  from = oci_objectstorage_bucket.media
  to   = oci_objectstorage_bucket.media["media"]
}

data "oci_core_images" "ubuntu_24" {
  for_each = {
    for key, instance in local.instances : key => instance
    if try(instance.image.image_id, null) == null
  }

  compartment_id           = var.OCI_COMPARTMENT_OCID
  operating_system         = try(each.value.image.operating_system, "Canonical Ubuntu")
  operating_system_version = try(each.value.image.operating_system_version, "24.04")
  shape                    = each.value.shape
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

resource "oci_core_vcn" "main" {
  for_each = local.vcns

  compartment_id = var.OCI_COMPARTMENT_OCID
  cidr_block     = each.value.cidr_block
  display_name   = try(each.value.display_name, "${local.resource_name}-${each.key}-vcn")
  freeform_tags  = local.common_freeform_tags
}

resource "oci_core_internet_gateway" "main" {
  for_each = local.internet_gateways

  compartment_id = var.OCI_COMPARTMENT_OCID
  display_name   = try(each.value.display_name, "${local.resource_name}-${each.key}-igw")
  enabled        = try(each.value.enabled, true)
  freeform_tags  = local.common_freeform_tags
  vcn_id         = oci_core_vcn.main[each.value.vcn_key].id
}

resource "oci_core_route_table" "public" {
  for_each = local.route_tables

  compartment_id = var.OCI_COMPARTMENT_OCID
  display_name   = try(each.value.display_name, "${local.resource_name}-${each.key}-rt")
  freeform_tags  = local.common_freeform_tags
  vcn_id         = oci_core_vcn.main[each.value.vcn_key].id

  dynamic "route_rules" {
    for_each = each.value.route_rules

    content {
      destination       = route_rules.value.destination
      destination_type  = try(route_rules.value.destination_type, "CIDR_BLOCK")
      network_entity_id = oci_core_internet_gateway.main[route_rules.value.gateway_key].id
    }
  }
}

resource "oci_core_security_list" "public" {
  for_each = local.security_lists

  compartment_id = var.OCI_COMPARTMENT_OCID
  display_name   = try(each.value.display_name, "${local.resource_name}-${each.key}-sl")
  freeform_tags  = local.common_freeform_tags
  vcn_id         = oci_core_vcn.main[each.value.vcn_key].id

  dynamic "ingress_security_rules" {
    for_each = try(each.value.ingress_security_rules, [])

    content {
      protocol    = ingress_security_rules.value.protocol
      source      = ingress_security_rules.value.source
      source_type = try(ingress_security_rules.value.source_type, "CIDR_BLOCK")
      stateless   = try(ingress_security_rules.value.stateless, false)

      dynamic "tcp_options" {
        for_each = try(ingress_security_rules.value.tcp_options, null) == null ? [] : [ingress_security_rules.value.tcp_options]

        content {
          min = tcp_options.value.min
          max = tcp_options.value.max
        }
      }
    }
  }

  dynamic "egress_security_rules" {
    for_each = try(each.value.egress_security_rules, [])

    content {
      destination      = egress_security_rules.value.destination
      destination_type = try(egress_security_rules.value.destination_type, "CIDR_BLOCK")
      protocol         = egress_security_rules.value.protocol
      stateless        = try(egress_security_rules.value.stateless, false)
    }
  }
}

resource "oci_core_subnet" "public" {
  for_each = local.subnets

  cidr_block                 = each.value.cidr_block
  compartment_id             = var.OCI_COMPARTMENT_OCID
  display_name               = try(each.value.display_name, "${local.resource_name}-${each.key}-subnet")
  freeform_tags              = local.common_freeform_tags
  prohibit_public_ip_on_vnic = try(each.value.prohibit_public_ip_on_vnic, false)
  route_table_id             = oci_core_route_table.public[each.value.route_table_key].id
  security_list_ids          = [for key in each.value.security_list_keys : oci_core_security_list.public[key].id]
  vcn_id                     = oci_core_vcn.main[each.value.vcn_key].id
}

resource "oci_core_network_security_group" "main" {
  for_each = local.network_security_groups

  compartment_id = var.OCI_COMPARTMENT_OCID
  display_name   = try(each.value.display_name, "${local.resource_name}-${each.key}-nsg")
  freeform_tags  = local.common_freeform_tags
  vcn_id         = oci_core_vcn.main[each.value.vcn_key].id
}

resource "oci_core_network_security_group_security_rule" "main" {
  for_each = local.network_security_group_security_rules

  destination               = try(each.value.destination, null)
  destination_type          = try(each.value.destination_type, null)
  direction                 = each.value.direction
  network_security_group_id = oci_core_network_security_group.main[each.value.network_security_group_key].id
  protocol                  = each.value.protocol
  source                    = try(each.value.source, null)
  source_type               = try(each.value.source_type, null)
  stateless                 = try(each.value.stateless, false)

  dynamic "tcp_options" {
    for_each = try(each.value.tcp_options, null) == null ? [] : [each.value.tcp_options]

    content {
      dynamic "destination_port_range" {
        for_each = try(tcp_options.value.destination_port_range, null) == null ? [] : [tcp_options.value.destination_port_range]

        content {
          min = destination_port_range.value.min
          max = destination_port_range.value.max
        }
      }
    }
  }
}

resource "oci_core_instance" "main" {
  for_each = local.instances

  availability_domain = var.OCI_AVAILABILITY_DOMAIN
  compartment_id      = var.OCI_COMPARTMENT_OCID
  display_name        = try(each.value.display_name, "${local.resource_name}-${each.key}")
  freeform_tags       = local.common_freeform_tags
  shape               = each.value.shape

  create_vnic_details {
    assign_private_dns_record = try(each.value.assign_private_dns_record, true)
    assign_public_ip          = try(each.value.assign_public_ip, false)
    nsg_ids                   = [for key in each.value.network_security_group_keys : oci_core_network_security_group.main[key].id]
    private_ip                = each.value.private_ip
    subnet_id                 = oci_core_subnet.public[each.value.subnet_key].id
  }

  metadata = {
    ssh_authorized_keys = trimspace(var.OCI_SSH_AUTHORIZED_KEYS)
    user_data           = base64encode(local.tailscale_bootstrap_user_data)
  }

  dynamic "shape_config" {
    for_each = try(each.value.shape_config, null) == null ? [] : [each.value.shape_config]

    content {
      memory_in_gbs = shape_config.value.memory_in_gbs
      ocpus         = shape_config.value.ocpus
    }
  }

  source_details {
    boot_volume_size_in_gbs = each.value.boot_volume_size_gbs
    source_id               = coalesce(try(each.value.image.image_id, null), data.oci_core_images.ubuntu_24[each.key].images[0].id)
    source_type             = "IMAGE"
  }
}

data "oci_core_private_ips" "main" {
  for_each = local.public_ips

  ip_address = local.instances[each.value.instance_key].private_ip
  subnet_id  = oci_core_subnet.public[local.instances[each.value.instance_key].subnet_key].id

  depends_on = [oci_core_instance.main]
}

resource "oci_core_public_ip" "main" {
  for_each = local.public_ips

  compartment_id = var.OCI_COMPARTMENT_OCID
  display_name   = try(each.value.display_name, "${local.resource_name}-${each.key}-public-ip")
  lifetime       = try(each.value.lifetime, "RESERVED")
  private_ip_id  = data.oci_core_private_ips.main[each.key].private_ips[0].id
}

resource "oci_core_volume" "data" {
  for_each = local.block_volumes

  availability_domain = var.OCI_AVAILABILITY_DOMAIN
  compartment_id      = var.OCI_COMPARTMENT_OCID
  display_name        = "${local.resource_name}-${each.key}-volume"
  freeform_tags       = local.common_freeform_tags
  size_in_gbs         = each.value.size_in_gbs
}

resource "oci_core_volume_attachment" "data" {
  for_each = local.volume_attachments

  attachment_type = try(each.value.attachment_type, "paravirtualized")
  instance_id     = oci_core_instance.main[each.value.instance_key].id
  volume_id       = oci_core_volume.data[each.value.volume_key].id
}

data "oci_objectstorage_namespace" "main" {
  compartment_id = var.OCI_COMPARTMENT_OCID
}

resource "oci_objectstorage_bucket" "media" {
  for_each = local.object_storage_buckets

  compartment_id = var.OCI_COMPARTMENT_OCID
  name           = each.value.name
  namespace      = data.oci_objectstorage_namespace.main.namespace
  access_type    = each.value.access_type
  storage_tier   = each.value.storage_tier
  freeform_tags  = local.common_freeform_tags
}
