# provider (source openrc)
provider "openstack" {
  use_octavia = true
}

provider "google" {
  credentials = var.dns_zone_credentials
  project     = var.dns_zone_project
  region      = var.dns_zone_region
}
