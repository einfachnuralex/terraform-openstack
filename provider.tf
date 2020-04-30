# provider (source openrc)
provider "openstack" {}

provider "google" {
  /* credentials = file(var.gcp_auth_json_path) */
  access_token = "ya29.a0Ae4lvC1sPdOc7dRDrSM11qCLGfLcjFF-4ieKteY_MQSyh-RYYtih0Fr7T6bR6QPiFhRgaANxTNfjLMduZPce6tLnS_ECvQuh_BoP-5_15r5ljiF8ZhgidJMU2dlr_dJfm_JepHWROCFiKZ-kUAGXs2C5KJ-V0yxH2rJjysv5QH4"
  project      = "n-1578486715742-95072"
  region       = "eu-central1"
}
