output "master_ipv6" {
  description = "Instance information map, providing instance name and IP address"
  value = "${zipmap(
    [for instance in openstack_compute_instance_v2.master_nodes : instance.name],
    [for instance in openstack_compute_instance_v2.master_nodes : instance.access_ip_v6],
  )}"
}

output "worker_info" {
  description = "Instance information map, providing instance name and IP address"
  value = "${zipmap(
    [for instance in openstack_compute_instance_v2.worker_nodes : instance.name],
    [for instance in openstack_compute_instance_v2.worker_nodes : instance.access_ip_v6],
  )}"
}

output "lb_public_ip" {
  value = openstack_networking_floatingip_v2.fip.address
}
