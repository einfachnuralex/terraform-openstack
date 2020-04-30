resource "google_dns_record_set" "loadbalancer" {
  name = var.control_plane_endpoint
  type = "AAAA"
  ttl  = 300

  managed_zone = "gardener-test-2"
  rrdatas      = [openstack_compute_instance_v2.ske_loadbalancer.access_ip_v6]
}
