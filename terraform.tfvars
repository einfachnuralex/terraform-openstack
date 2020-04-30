# provider vars
gcp_auth_json_path = "./auth/ske-dns-admin.json"

control_plane_endpoint = "cp6.gardener.ganter.dev"


# instance vars
private_key_path = "./auth/ske-key"
image_id         = "41c4c9fc-c8d7-4475-8989-8103b0484128"
flavor_name      = "c1.2"
master_node_names = [
  "master_1",
  "master_2",
  "master_3"
]
worker_node_names = [
  "worker_1",
  "worker_2"
]
lb_name = "lb_1"

# network vars
network_prefix  = "network"
secgroup_prefix = "secgroup"
ext_ports = {
  ssh = {
    min      = 22
    max      = 22
    protocol = "tcp"
  },
  api = {
    min      = 6443
    max      = 6443
    protocol = "tcp"
  }
}
int_ports = {
  etcd = {
    min      = 2379
    max      = 2380
    protocol = "tcp"
  },
  api = {
    min      = 6443
    max      = 6443
    protocol = "tcp"
  },
  kubelet = {
    min      = 10250
    max      = 10250
    protocol = "tcp"
  },
  scheduler = {
    min      = 10251
    max      = 10251
    protocol = "tcp"
  },
  controller = {
    min      = 10252
    max      = 10252
    protocol = "tcp"
  },
  node_port_tcp = {
    min      = 30000
    max      = 32767
    protocol = "tcp"
  },
  node_port_udp = {
    min      = 30000
    max      = 32767
    protocol = "udp"
  }
}
