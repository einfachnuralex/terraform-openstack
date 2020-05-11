# provider (source openrc)
provider "openstack" {}

provider "google" {
  /* credentials = */
  access_token = "insert-new-token-here!"
  project      = "n-1578486715742-95072"
  region       = "eu-central1"
}
