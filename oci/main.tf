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
