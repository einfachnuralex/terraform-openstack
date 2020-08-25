# Network creation
resource "openstack_networking_network_v2" "infra_net" {
  name           = "${var.cluster_name}-v4"
  admin_state_up = "true"
}

# Subnet creation
resource "openstack_networking_subnet_v2" "infra_net_v4" {
  name            = "${var.cluster_name}-subnet_v4"
  network_id      = openstack_networking_network_v2.network_v4.id
  cidr            = var.node_cidr
  dns_nameservers = ["8.8.8.8", "8.8.4.4"]
  ip_version      = 4
}

resource "openstack_networking_subnet_v2" "infra_net_v6" {
  name          = "int-a-v6"
  network_id    = openstack_networking_network_v2.int-a.id
  subnetpool_id = openstack_networking_subnetpool_v2.int-a-v6.id
  ip_version    = 6

  #no_gateway    = true
  #enable_dhcp   = false # This causes Cloud-Init to configure the interfaces "statically" and doesnt' expect any SLAAC or DHCPv6 to happen
  ipv6_ra_mode      = "slaac"
  ipv6_address_mode = "slaac"
  dns_nameservers   = ["2001:4860:4860::8888", "2001:4860:4860::8844"]
}


resource "openstack_networking_port_v2" "port_v4" {
  for_each   = setunion(var.master_node_names, var.worker_node_names)
  name       = format("%s-%s", var.cluster_name, each.key)
  network_id = openstack_networking_network_v2.network_v4.id
  security_group_ids = [
  openstack_networking_secgroup_v2.internal.id]
  admin_state_up = "true"

  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.subnet_v4.id
  }

  allowed_address_pairs {
    ip_address = var.pod_cidr
  }
}

# Router creation
resource "openstack_networking_router_v2" "generic_v4" {
  name                = "${var.cluster_name}-router-v4"
  external_network_id = data.openstack_networking_network_v2.floating_net.id
}

# Router interface creation
resource "openstack_networking_router_interface_v2" "router_interface_v4" {
  router_id = openstack_networking_router_v2.generic_v4.id
  subnet_id = openstack_networking_subnet_v2.subnet_v4.id
}

resource "openstack_networking_secgroup_v2" "internal" {
  name = "${var.cluster_name}-int"
}

resource "openstack_networking_secgroup_rule_v2" "ext_2_int" {
  for_each          = var.ext_ports
  description       = each.key
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = each.value.protocol
  port_range_min    = each.value.min
  port_range_max    = each.value.max
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.internal.id
}

resource "openstack_networking_secgroup_rule_v2" "int_2_int" {
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
