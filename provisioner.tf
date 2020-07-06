resource "null_resource" "first_master" {
  depends_on = [openstack_lb_loadbalancer_v2.elastic_lb]
  connection {
    type         = "ssh"
    bastion_host = openstack_lb_loadbalancer_v2.elastic_lb.vip_address
    host         = values(openstack_compute_instance_v2.master_nodes)[0].access_ip_v4
    user         = "ubuntu"
    private_key  = file(var.private_key_path)
    timeout      = "5m"
  }

  provisioner "file" {
    content = templatefile("config/kubeadm.tmpl", {
      control_plane_endpoint = var.control_plane_endpoint
    })
    destination = "/tmp/kubeadm.conf"
  }

  provisioner "file" {
    content = templatefile("config/kubeadm-init.sh", {
      master_ips             = [for instance in openstack_compute_instance_v2.master_nodes : instance.access_ip_v4]
      worker_ips             = [for instance in openstack_compute_instance_v2.worker_nodes : instance.access_ip_v4]
      control_plane_endpoint = var.control_plane_endpoint
    })
    destination = "/tmp/kubeadm-init.sh"
  }

  provisioner "remote-exec" {
    on_failure = fail
    inline = [
      "echo 'ForwardAgent yes' >> ~/.ssh/config",
      "sudo mv /tmp/kubeadm.conf ~/kubeadmconfig.yaml",
      "sudo mv /tmp/kubeadm-init.sh ~/kubeadm-init.sh",
      "sudo chmod +x kubeadm-init.sh",
      "./kubeadm-init.sh",
      "sleep 1",
    ]
  }
}

resource "null_resource" "master_join" {
  depends_on = [null_resource.first_master]
  for_each   = var.master_node_names
  connection {
    type         = "ssh"
    bastion_host = openstack_lb_loadbalancer_v2.elastic_lb.vip_address
    host         = openstack_compute_instance_v2.master_nodes[each.key].access_ip_v4
    user         = "ubuntu"
    private_key  = file(var.private_key_path)
    timeout      = "5m"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x master_join.sh",
      "sudo ./master_join.sh",
      "sleep 1",
    ]
  }
}

resource "null_resource" "worker_join" {
  depends_on = [null_resource.master_join]
  for_each   = var.worker_node_names
  connection {
    type         = "ssh"
    bastion_host = openstack_lb_loadbalancer_v2.elastic_lb.vip_address
    host         = openstack_compute_instance_v2.worker_nodes[each.key].access_ip_v4
    user         = "ubuntu"
    private_key  = file(var.private_key_path)
    timeout      = "5m"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x worker_join.sh",
      "sudo ./worker_join.sh",
      "sleep 1",
    ]
  }
}

