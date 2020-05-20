# Instance creation
resource "openstack_compute_instance_v2" "loadbalancer" {
  name      = var.lb_name
  image_id  = var.image_id
  flavor_id = data.openstack_compute_flavor_v2.flavor.id
  key_pair  = var.key_pair_name

  block_device {
    uuid                  = var.image_id
    source_type           = "image"
    destination_type      = "volume"
    boot_index            = 0
    volume_size           = 20
    delete_on_termination = true
  }

  network {
    port = openstack_networking_port_v2.lb_port_v4.id
  }

  network {
    port = openstack_networking_port_v2.lb_port_v6.id
  }
}

resource "openstack_compute_instance_v2" "master_nodes" {
  for_each  = var.master_node_names
  name      = each.key
  image_id  = var.image_id
  flavor_id = data.openstack_compute_flavor_v2.flavor.id
  key_pair  = var.key_pair_name

  block_device {
    uuid                  = var.image_id
    source_type           = "image"
    destination_type      = "volume"
    boot_index            = 0
    volume_size           = 20
    delete_on_termination = true
  }

  network {
    port = openstack_networking_port_v2.port_v4[each.key].id
  }

  network {
    port = openstack_networking_port_v2.port_v6[each.key].id
  }
}

resource "openstack_compute_instance_v2" "worker_nodes" {
  for_each  = var.worker_node_names
  name      = each.key
  image_id  = var.image_id
  flavor_id = data.openstack_compute_flavor_v2.flavor.id
  key_pair  = var.key_pair_name

  block_device {
    uuid                  = var.image_id
    source_type           = "image"
    destination_type      = "volume"
    boot_index            = 0
    volume_size           = 20
    delete_on_termination = true
  }

  network {
    port = openstack_networking_port_v2.port_v4[each.key].id
  }

  network {
    port = openstack_networking_port_v2.port_v6[each.key].id
  }
}

# data to get existing flavor id
data "openstack_compute_flavor_v2" "flavor" {
  name = var.flavor_name
}
