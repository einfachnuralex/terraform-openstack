# provider (source openrc)
provider "openstack" {
  use_octavia = true
}

provider "google" {
  credentials = "auth/gcp-dns-auth.json"
  project     = "n-1578486715742-95072"
  region      = "eu-central1"
}
