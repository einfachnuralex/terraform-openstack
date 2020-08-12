resource "google_dns_record_set" "loadbalancer" {
  name = "${var.control_plane_endpoint}."
  type = "A"
  ttl  = 30

  managed_zone = data.google_dns_managed_zone.dns_zone.name
  rrdatas      = [openstack_networking_floatingip_v2.fip.address]
}

data "google_dns_managed_zone" "dns_zone" {
  name = var.dns_zone_name
}
