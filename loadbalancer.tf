# Create loadbalancer
resource "openstack_lb_loadbalancer_v2" "elastic_lb" {
  name          = "elastic_lb_tcp"
  vip_subnet_id = openstack_networking_subnet_v2.subnet_v4.id
}

# Create listener
resource "openstack_lb_listener_v2" "listener_1" {
  name            = "listener_tcp"
  protocol        = "TCP"
  protocol_port   = 6443
  loadbalancer_id = openstack_lb_loadbalancer_v2.elastic_lb.id
}

# Set methode for load balance charge between instance
resource "openstack_lb_pool_v2" "pool_1" {
  name        = "pool_tcp"
  protocol    = "TCP"
  lb_method   = "ROUND_ROBIN"
  listener_id = openstack_lb_listener_v2.listener_1.id
}

# Add masters to member group
resource "openstack_lb_member_v2" "members" {
  for_each      = var.master_node_names
  address       = openstack_compute_instance_v2.master_nodes[each.key].access_ip_v4
  protocol_port = 6443
  pool_id       = openstack_lb_pool_v2.pool_1.id
  subnet_id     = openstack_networking_subnet_v2.subnet_v4.id
}

# Create health monitor for check services instances status
resource "openstack_lb_monitor_v2" "monitor_1" {
  name        = "monitor_tcp"
  pool_id     = openstack_lb_pool_v2.pool_1.id
  type        = "TCP"
  delay       = 2
  timeout     = 2
  max_retries = 2
}

# Associate floating-ip to the lb port
resource "openstack_networking_floatingip_v2" "fip" {
  pool = "floating-net"
  port_id = openstack_lb_loadbalancer_v2.elastic_lb.vip_port_id
}