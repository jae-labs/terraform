terraform {
  required_version = ">= 1.5"

  required_providers {
    honeycombio = {
      source  = "honeycombio/honeycombio"
      version = "~> 0.50.0"
    }
  }

  backend "pg" {
    schema_name = "honeycomb"
  }
}
