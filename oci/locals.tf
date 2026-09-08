locals {
  environment  = "prod"
  project_name = "oci"

  object_storage_buckets = {
    media = {
      name         = "oci-prod-jae-pages-media"
      access_type  = "ObjectReadWithoutList"
      storage_tier = "Standard"
    }
  }

  common_freeform_tags = {
    Environment = local.environment
    ManagedBy   = "Terraform"
    Project     = local.project_name
  }
}
