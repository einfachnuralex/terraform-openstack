resource "google_dns_record_set" "loadbalancer" {
  name = "${var.control_plane_endpoint}."
  type = "A"
  ttl  = 300

  managed_zone = data.google_dns_managed_zone.dns_zone.name
  rrdatas      = openstack_compute_instance_v2.loadbalancer.access_ip_v4
}

data "google_dns_managed_zone" "dns_zone" {
  name = "gardener-test-2"
}
