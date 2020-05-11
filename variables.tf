## gcp ##
variable "gcp_auth_json_path" {
  description = "google cloud auth.json path"
}

## k8s ##
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

variable "lb_name" {
  type = string
}

variable "image_id" {
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
  type = string
}

## network ##
variable "network_prefix" {
  type = string
}

variable "secgroup_prefix" {
  type = string
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
