#### NETWORK CONFIGURATION ####

# Network creation
resource "openstack_networking_network_v2" "network_ip4" {
  name           = "${var.network_prefix}-ipv4"
  admin_state_up = "true"
}

resource "openstack_networking_network_v2" "network_ip6" {
  name           = "${var.network_prefix}-ipv6"
  admin_state_up = "true"
}

# Subnet creation
resource "openstack_networking_subnet_v2" "subnet_ip4" {
  name            = "subnet_ip4"
  network_id      = openstack_networking_network_v2.network_ip4.id
  cidr            = "192.168.42.0/24"
  dns_nameservers = ["8.8.8.8", "8.8.8.4"]
  ip_version      = 4
}

resource "openstack_networking_subnet_v2" "subnet_ip6" {
  name              = "subnet_ip6"
  network_id        = openstack_networking_network_v2.network_ip6.id
  cidr              = "2001:cafe::/64"
  ip_version        = 6
  ipv6_address_mode = "dhcpv6-stateful"
  ipv6_ra_mode      = "dhcpv6-stateful"
}

# Router creation
resource "openstack_networking_router_v2" "generic_v4" {
  name                = "router-generic_v4"
  external_network_id = data.openstack_networking_network_v2.floating_net.id
}

resource "openstack_networking_router_v2" "generic_v6" {
  name = "router-generic_v6"
}

# Router interface creation
resource "openstack_networking_router_interface_v2" "router_interface_v4" {
  router_id = openstack_networking_router_v2.generic_v4.id
  subnet_id = openstack_networking_subnet_v2.subnet_ip4.id
}

resource "openstack_networking_router_interface_v2" "router_interface_v6" {
  router_id = openstack_networking_router_v2.generic_v6.id
  subnet_id = openstack_networking_subnet_v2.subnet_ip6.id
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

resource "openstack_networking_secgroup_rule_v2" "ext_v6_rules" {
  for_each          = var.ext_ports
  description       = each.key
  direction         = "ingress"
  ethertype         = "IPv6"
  protocol          = each.value.protocol
  port_range_min    = each.value.min
  port_range_max    = each.value.max
  remote_ip_prefix  = "::/0"
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

resource "openstack_networking_secgroup_rule_v2" "ext_to_int_v6" {
  for_each          = var.ext_ports
  description       = each.key
  direction         = "ingress"
  ethertype         = "IPv6"
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

resource "openstack_networking_secgroup_rule_v2" "int_v6" {
  for_each          = var.int_ports
  description       = each.key
  direction         = "ingress"
  ethertype         = "IPv6"
  protocol          = each.value.protocol
  port_range_min    = each.value.min
  port_range_max    = each.value.max
  remote_group_id   = openstack_networking_secgroup_v2.internal.id
  security_group_id = openstack_networking_secgroup_v2.internal.id
}

# floating-ip creation & associate
resource "openstack_compute_floatingip_v2" "fip" {
  pool = "floating-net"
}

resource "openstack_compute_floatingip_associate_v2" "fip_associate" {
  floating_ip = openstack_compute_floatingip_v2.fip.address
  instance_id = openstack_compute_instance_v2.ske_loadbalancer.id
}

# data to get existing network id
data "openstack_networking_network_v2" "floating_net" {
  name = "floating-net"
}
