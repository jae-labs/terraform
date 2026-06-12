terraform {
  required_version = ">= 1.5"

  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 8.15"
    }
  }

  backend "pg" {
    schema_name = "oci"
  }
}
