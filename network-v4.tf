# Network creation
resource "openstack_networking_network_v2" "network_v4" {
  name           = "${var.network_prefix}-v4"
  admin_state_up = "true"
}

# Subnet creation
resource "openstack_networking_subnet_v2" "subnet_v4" {
  name            = "subnet_v4"
  network_id      = openstack_networking_network_v2.network_v4.id
  cidr            = "192.168.42.0/24"
  dns_nameservers = ["8.8.8.8", "8.8.8.4"]
  ip_version      = 4
}

# Port creation
resource "openstack_networking_port_v2" "lb_port_v4" {
  name               = "${var.network_prefix}-lb-port-v4"
  network_id         = openstack_networking_network_v2.network_v4.id
  security_group_ids = [openstack_networking_secgroup_v2.external.id]
  admin_state_up     = "true"

  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.subnet_v4.id
  }
}

resource "openstack_networking_port_v2" "port_v4" {
  for_each           = setunion(var.master_node_names, var.worker_node_names)
  name               = "${var.network_prefix}-port-v4"
  network_id         = openstack_networking_network_v2.network_v4.id
  security_group_ids = [openstack_networking_secgroup_v2.internal.id]
  admin_state_up     = "true"

  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.subnet_v4.id
  }

  allowed_address_pairs {
    ip_address = var.allowed_address_pairs_cidr
  }
}

# Router creation
resource "openstack_networking_router_v2" "generic_v4" {
  name                = "router-generic_v4"
  external_network_id = data.openstack_networking_network_v2.floating_net.id
}

# Router interface creation
resource "openstack_networking_router_interface_v2" "router_interface_v4" {
  router_id = openstack_networking_router_v2.generic_v4.id
  subnet_id = openstack_networking_subnet_v2.subnet_v4.id
}

# securitygroup & rules creation
resource "openstack_networking_secgroup_v2" "external" {
  name = "${var.secgroup_prefix}-ext"
}

resource "openstack_networking_secgroup_v2" "internal" {
  name = "${var.secgroup_prefix}-int"
}

resource "openstack_networking_secgroup_rule_v2" "ext_v4_rules" {
  for_each          = var.ext_ports
  description       = each.key
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = each.value.protocol
  port_range_min    = each.value.min
  port_range_max    = each.value.max
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.external.id
}

resource "openstack_networking_secgroup_rule_v2" "ext_to_int_v4" {
  for_each          = var.ext_ports
  description       = each.key
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = each.value.protocol
  port_range_min    = each.value.min
  port_range_max    = each.value.max
  remote_group_id   = openstack_networking_secgroup_v2.external.id
  security_group_id = openstack_networking_secgroup_v2.internal.id
}

resource "openstack_networking_secgroup_rule_v2" "int_v4" {
  for_each          = var.int_ports
  description       = each.key
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = each.value.protocol
  port_range_min    = each.value.min
  port_range_max    = each.value.max
  remote_group_id   = openstack_networking_secgroup_v2.internal.id
  security_group_id = openstack_networking_secgroup_v2.internal.id
}

# data to get existing network id
data "openstack_networking_network_v2" "floating_net" {
  name = "floating-net"
}
