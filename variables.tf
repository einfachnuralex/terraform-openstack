# DEFAULTS
## nodes
variable "image_id" {
  type        = string
  default     = "38e194d3-16b9-43a7-af1d-9ffcaa98c746"
  description = "id of the os-image for nodes (default: ubuntu)"
}

variable "flavor_name" {
  type        = string
  default     = "c1.2"
  description = "flavor of the node instances"
}

variable "private_key_path" {
  type        = string
  default     = "auth/ske-key"
  description = "path to private-key, to grand access for terraform provisioner"
}

variable "dns_zone_credentials" {
  type        = string
  default     = "auth/dns-auth"
  description = "Authentication file for public dns"
}

## security rules
variable "ext_ports" {
  type    = map(object({
    min      = number
    max      = number
    protocol = string
  }))
  default = {
    ssh           = {
      min      = 22
      max      = 22
      protocol = "tcp"
    },
    node_port_tcp = {
      min      = 30000
      max      = 32767
      protocol = "tcp"
    },
    api           = {
      min      = 6443
      max      = 6443
      protocol = "tcp"
    }
  }
}

variable "int_ports" {
  type    = map(object({
    min      = number
    max      = number
    protocol = string
  }))
  default = {
    ssh           = {
      min      = 22
      max      = 22
      protocol = "tcp"
    },
    etcd          = {
      min      = 2379
      max      = 2380
      protocol = "tcp"
    },
    api           = {
      min      = 6443
      max      = 6443
      protocol = "tcp"
    },
    kubelet       = {
      min      = 10250
      max      = 10250
      protocol = "tcp"
    },
    scheduler     = {
      min      = 10251
      max      = 10251
      protocol = "tcp"
    },
    controller    = {
      min      = 10252
      max      = 10252
      protocol = "tcp"
    },
    node_port_tcp = {
      min      = 30000
      max      = 32767
      protocol = "tcp"
    },
    bgp           = {
      min      = 179
      max      = 179
      protocol = "tcp"
    },
    ip_in_ip      = {
      min      = 0
      max      = 0
      protocol = "4"
    }
  }
}

# SOURCED VARIABLES
## nodes
variable "cluster_name" {
  type        = string
  description = "Name of the Cluster (set via source-file)"
}

variable "control_plane_endpoint" {
  type        = string
  description = "control-plane dns endpoint (set via source-file)"
}

variable "k8s_version" {
  type        = string
  description = "kubernetes version (set via source-file)"
}

variable "master_node_count" {
  type        = number
  description = "number of master nodes (set via source-file)"
}

variable "worker_node_count" {
  type        = number
  description = "number of worker nodes (set via source-file)"
}

variable "pod_cidr_v4" {
  type        = string
  description = "ipv4 cidr for the pod-network (set via source-file)"
}

variable "pod_cidr_v6" {
  type        = string
  description = "ipv6 cidr for the pod-network (set via source-file)"
}

variable "node_cidr_v4" {
  type        = string
  description = "ipv4 cidr for the node-network (set via source-file)"
}

variable "node_cidr_v6" {
  type        = string
  description = "ipv6 pod cidr for the node-network (set via source-file)"
}

variable "srv_cidr_v4" {
  type        = string
  description = "ipv4 pod cidr for the service-network (set via source-file)"
}

variable "srv_cidr_v6" {
  type        = string
  description = "ipv6 pod cidr for the service-network (set via source-file)"
}

variable "key_pair_name" {
  type        = string
  description = "name of an existing key, to access instance via ssh (set via source-file)"
}

variable "os_user" {
  type = string
}

variable "os_pass" {
  type = string
}

variable "os_project" {
  type = string
}

variable "os_projectid" {
  type = string
}

variable "os_authurl" {
  type = string
}

variable "dns_zone_name" {
  type = string
}

variable "dns_zone_project" {
  type = string
}

variable "dns_zone_region" {
  type = string
}
