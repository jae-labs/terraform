terraform {
  required_version = ">= 1.5"

  required_providers {
    grafana = {
      source  = "grafana/grafana"
      version = "~> 4.28"
    }
    external = {
      source  = "hashicorp/external"
      version = "~> 2.3"
    }
  }

  backend "pg" {
    schema_name = "grafana"
  }
}
