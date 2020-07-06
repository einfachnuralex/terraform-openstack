resource "google_dns_record_set" "loadbalancer" {
  name = "${var.control_plane_endpoint}."
  type = "A"
  ttl  = 300

  managed_zone = data.google_dns_managed_zone.dns_zone.name
  rrdatas      = [openstack_lb_loadbalancer_v2.elastic_lb.vip_address]
}

data "google_dns_managed_zone" "dns_zone" {
  name = "gardener-test-2"
}
