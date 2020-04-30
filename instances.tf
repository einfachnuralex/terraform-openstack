# instance section
resource "openstack_compute_instance_v2" "ske_master" {
  for_each        = var.master_node_names
  name            = each.key
  image_id        = var.image_id
  flavor_id       = data.openstack_compute_flavor_v2.flavor.id
  key_pair        = "ske-key"
  security_groups = [openstack_networking_secgroup_v2.internal.id]

  block_device {
    uuid                  = var.image_id
    source_type           = "image"
    destination_type      = "volume"
    boot_index            = 0
    volume_size           = 20
    delete_on_termination = true
  }

  network {
    name = openstack_networking_network_v2.network_ip4.name
  }

  network {
    name = openstack_networking_network_v2.network_ip6.name
  }
}

resource "openstack_compute_instance_v2" "ske_worker" {
  for_each        = var.worker_node_names
  name            = each.key
  image_id        = var.image_id
  flavor_id       = data.openstack_compute_flavor_v2.flavor.id
  key_pair        = "ske-key"
  security_groups = [openstack_networking_secgroup_v2.internal.id]

  block_device {
    uuid                  = var.image_id
    source_type           = "image"
    destination_type      = "volume"
    boot_index            = 0
    volume_size           = 20
    delete_on_termination = true
  }

  network {
    name = openstack_networking_network_v2.network_ip4.name
  }

  network {
    name = openstack_networking_network_v2.network_ip6.name
  }
}

resource "openstack_compute_instance_v2" "ske_loadbalancer" {
  name            = var.lb_name
  image_id        = var.image_id
  flavor_id       = data.openstack_compute_flavor_v2.flavor.id
  key_pair        = "ske-key"
  security_groups = [openstack_networking_secgroup_v2.external.id]

  block_device {
    uuid                  = var.image_id
    source_type           = "image"
    destination_type      = "volume"
    boot_index            = 0
    volume_size           = 20
    delete_on_termination = true
  }

  network {
    name = openstack_networking_network_v2.network_ip4.name
  }

  network {
    name = openstack_networking_network_v2.network_ip6.name
  }
}

# data to get existing flavor id
data "openstack_compute_flavor_v2" "flavor" {
  name = var.flavor_name
}
