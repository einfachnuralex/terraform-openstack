## k8s ##
variable "cluster_name" {
  type = string
}

variable "control_plane_endpoint" {
  type = string
}

## instance ##
variable "master_node_names" {
  type = set(string)
}

variable "worker_node_names" {
  type = set(string)
}

variable "image_id" {
  type = string
}

variable "pod_cidr_v4" {
  type = string
}

variable "pod_cidr_v6" {
  type = string
}

variable "node_cidr" {
  type = string
}

variable "srv_cidr" {
  type = string
}

variable "flavor_name" {
  type = string
}

variable "key_pair_name" {
  type        = string
  description = "name of an existing key, to access instance via ssh"
}

variable "private_key_path" {
  type        = string
  description = "path to private-key, to grand access for terraform provisioner"
}

variable "ext_ports" {
  type = map(object({
    min      = number
    max      = number
    protocol = string
  }))
}

variable "int_ports" {
  type = map(object({
    min      = number
    max      = number
    protocol = string
  }))
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

variable "dns_zone_credentials" {
  type = string
}

variable "dns_zone_project" {
  type = string
}

variable "dns_zone_region" {
  type = string
}
