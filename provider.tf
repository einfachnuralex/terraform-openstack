# provider (source openrc)
provider "openstack" {}

provider "google" {
  /* credentials = file(var.gcp_auth_json_path) */
  access_token = "ya29.a0Ae4lvC003SjlwFZoCGgm9cNDsdM8LTdfgGsjV3SEYRHrDPLBK0ViCjdA8qr-Hv0x8eKZXN3NDGeOTJB5J4PuDHMC1vGVvIzXsrJOWPy98H64y49fdgOjBN1_wAAYwuRrQ9i8WonON6P7r4rQp7FYyCqD3DgzX98_Mvvs-4XAjjXE"
  project      = "n-1578486715742-95072"
  region       = "eu-central1"
}
