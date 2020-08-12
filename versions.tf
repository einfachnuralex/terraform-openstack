terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
    }
    local = {
      source = "hashicorp/local"
    }
    null = {
      source = "hashicorp/null"
    }
    openstack = {
      source = "terraform-providers/openstack"
    }
  }
  required_version = ">= 0.13"
}
