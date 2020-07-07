resource "null_resource" "bootstrap_cluster" {
  depends_on = [openstack_lb_member_v2.member_ssh, openstack_compute_instance_v2.master_nodes]
  triggers   = {
    master = join(", ", [for instance in openstack_compute_instance_v2.master_nodes : instance.id]),
    worker = join(", ", [for instance in openstack_compute_instance_v2.worker_nodes : instance.id]),
  }
  connection {
    type        = "ssh"
    port        = 2222
    host        = openstack_networking_floatingip_v2.fip.address
    user        = "ubuntu"
    private_key = file(var.private_key_path)
  }

  provisioner "file" {
    content     = templatefile("config/kubeadm.tmpl", {
      control_plane_endpoint = var.control_plane_endpoint
    })
    destination = "/tmp/kubeadm.conf"
  }

  provisioner "file" {
    content     = templatefile("config/kubeadm-init.sh", {
      master_ips             = [for instance in openstack_compute_instance_v2.master_nodes : instance.access_ip_v4]
      worker_ips             = [for instance in openstack_compute_instance_v2.worker_nodes : instance.access_ip_v4]
      fip_address            = openstack_networking_floatingip_v2.fip.address
      control_plane_endpoint = var.control_plane_endpoint
    })
    destination = "/tmp/kubeadm-init.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'ForwardAgent yes' >> ~/.ssh/config",
      "sudo mv /tmp/kubeadm.conf ~/kubeadmconfig.yaml",
      "sudo mv /tmp/kubeadm-init.sh ~/kubeadm-init.sh",
      "sudo chmod +x kubeadm-init.sh",
      "./kubeadm-init.sh",
      "mkdir .kube && sudo cp /etc/kubernetes/admin.conf ~/.kube/config",
      "sudo chown ubuntu ~/.kube/config",
      "sleep 1",
    ]
  }
}

resource "null_resource" "install_calico" {
  depends_on = [null_resource.bootstrap_cluster]
  triggers   = {
    first_master = values(openstack_compute_instance_v2.master_nodes)[0].id,
    lol          = "lol"
  }
  connection {
    type        = "ssh"
    port        = 2222
    host        = openstack_networking_floatingip_v2.fip.address
    user        = "ubuntu"
    private_key = file(var.private_key_path)
  }

  provisioner "remote-exec" {
    inline = [
      "sudo kubectl apply -f https://docs.projectcalico.org/v3.14/manifests/calico.yaml",
      "sleep 1",
    ]
  }
}


resource "null_resource" "master_join" {
  depends_on = [null_resource.bootstrap_cluster]
  triggers   = {
    master = join(", ", [for instance in openstack_compute_instance_v2.master_nodes : instance.id])
  }
  for_each   = toset(slice(tolist(var.master_node_names), 1, length(var.master_node_names)))
  connection {
    type         = "ssh"
    bastion_host = openstack_networking_floatingip_v2.fip.address
    bastion_port = 2222
    host         = openstack_compute_instance_v2.master_nodes[each.key].access_ip_v4
    user         = "ubuntu"
    private_key  = file(var.private_key_path)
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
  depends_on = [null_resource.bootstrap_cluster]
  triggers   = {
    worker = join(", ", [for instance in openstack_compute_instance_v2.worker_nodes : instance.id])
  }
  for_each   = var.worker_node_names
  connection {
    type         = "ssh"
    bastion_host = openstack_networking_floatingip_v2.fip.address
    bastion_port = 2222
    host         = openstack_compute_instance_v2.worker_nodes[each.key].access_ip_v4
    user         = "ubuntu"
    private_key  = file(var.private_key_path)
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x worker_join.sh",
      "sudo ./worker_join.sh",
      "sleep 1",
    ]
  }
}