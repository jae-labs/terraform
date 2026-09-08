terraform {
  required_version = ">= 1.5"

  required_providers {
    sentry = {
      source  = "jianyuan/sentry"
      version = "~> 0.15.1"
    }
  }

  backend "pg" {
    schema_name = "sentry"
  }
}
