# provider (source openrc)
provider "openstack" {}

provider "google" {
  credentials = "auth/gcp-dns-auth.json"
  project     = "n-1578486715742-95072"
  region      = "eu-central1"
}
