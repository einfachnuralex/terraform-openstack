# provider (source openrc)
provider "openstack" {}

provider "google" {
  credentials = file(var.gcp_auth_json_path)
  project     = "gardener-test"
  region      = "eu-central1"
}
