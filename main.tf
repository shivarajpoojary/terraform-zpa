terraform {
  required_providers {
    zpa = {
      source  = "zscaler/zpa"
      version = "~> 2.0"
    }
  }
}

provider "zpa" {
  client_id     = ""
  client_secret = ""
  customer_id   = ""
}

resource "zpa_segment_group" "default_segment_group" {
  name        = "Terraform-Segment-Group"
  description = "Segment group created via Terraform"
  enabled     = true
}

resource "zpa_app_connector_group" "prod_connectors" {
  name        = "Terraform-App-Connectors"
  description = "Production App Connector Group"
  enabled     = true
  location    = "India"
}

resource "zpa_application_segment" "internal_app" {
  name             = "internal-web-app"
  description      = "Internal Web App via ZPA"
  enabled          = true
  health_reporting = "ON_ACCESS"
  bypass_type      = "NEVER"

  domain_names = [
    "internal.example.local"
  ]

  tcp_port_range {
    from = "443"
    to   = "443"
  }

  segment_group_id = zpa_segment_group.default_segment_group.id
  server_group_ids = [zpa_app_connector_group.prod_connectors.id]
}

resource "zpa_policy_access_rule" "allow_internal_app" {
  name        = "Allow-Internal-Web-App"
  description = "Allow Employees to access internal web app"
  action      = "ALLOW"
  enabled     = true

  conditions {
    operator = "AND"

    operands {
      object_type = "APP"
      lhs         = "id"
      rhs         = zpa_application_segment.internal_app.id
    }

  }
}


