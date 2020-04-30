resource "google_dns_record_set" "loadbalancer" {
  name = "${var.control_plane_endpoint}."
  type = "AAAA"
  ttl  = 300

  managed_zone = data.google_dns_managed_zone.dns_zone.name
  rrdatas      = [trim(openstack_compute_instance_v2.ske_loadbalancer.access_ip_v6, "[]")]
}

data "google_dns_managed_zone" "dns_zone" {
  name = "gardener-test-2"
}

output "blaah" {
  value = trim(openstack_compute_instance_v2.ske_loadbalancer.access_ip_v6, "[]")
}
