# Create loadbalancer
resource "openstack_lb_loadbalancer_v2" "elastic_lb" {
  name           = "${var.cluster_name}-lb-tcp"
  vip_network_id = openstack_networking_network_v2.network_v4.id
  //vip_subnet_id = openstack_networking_subnet_v2.subnet_v4.id
}

# Create listener for k8s
resource "openstack_lb_listener_v2" "listener_k8s" {
  name            = "${var.cluster_name}-listener-k8s"
  protocol        = "TCP"
  protocol_port   = 6443
  loadbalancer_id = openstack_lb_loadbalancer_v2.elastic_lb.id
}

# Create ssh listener for first_master
resource "openstack_lb_listener_v2" "listener_ssh" {
  name            = "${var.cluster_name}-listener-ssh"
  protocol        = "TCP"
  protocol_port   = 2222
  loadbalancer_id = openstack_lb_loadbalancer_v2.elastic_lb.id
}

resource "openstack_lb_pool_v2" "pool_k8s" {
  name        = "pool_k8s"
  protocol    = "TCP"
  lb_method   = "ROUND_ROBIN"
  listener_id = openstack_lb_listener_v2.listener_k8s.id
}

resource "openstack_lb_pool_v2" "pool_ssh" {
  name        = "pool_ssh"
  protocol    = "TCP"
  lb_method   = "ROUND_ROBIN"
  listener_id = openstack_lb_listener_v2.listener_ssh.id
}

# Add masters to member group
resource "openstack_lb_member_v2" "member_k8s" {
  for_each      = var.master_node_names
  name          = each.key
  address       = openstack_compute_instance_v2.master_nodes[each.key].access_ip_v4
  protocol_port = 6443
  pool_id       = openstack_lb_pool_v2.pool_k8s.id
  subnet_id     = openstack_networking_subnet_v2.subnet_v4.id
}

resource "openstack_lb_member_v2" "member_ssh" {
  name          = values(openstack_compute_instance_v2.master_nodes)[0].name
  address       = values(openstack_compute_instance_v2.master_nodes)[0].access_ip_v4
  protocol_port = 22
  pool_id       = openstack_lb_pool_v2.pool_ssh.id
  subnet_id     = openstack_networking_subnet_v2.subnet_v4.id
}

# Create health monitor for check services instances status
resource "openstack_lb_monitor_v2" "monitor_1" {
  name        = "monitor_tcp"
  pool_id     = openstack_lb_pool_v2.pool_k8s.id
  type        = "TCP"
  delay       = 2
  timeout     = 2
  max_retries = 2
}

# Associate floating-ip to the lb port
resource "openstack_networking_floatingip_v2" "fip" {
  pool    = "floating-net"
  port_id = openstack_lb_loadbalancer_v2.elastic_lb.vip_port_id
}