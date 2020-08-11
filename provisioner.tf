resource "null_resource" "bootstrap_cluster" {
  depends_on = [openstack_lb_member_v2.member_ssh, openstack_compute_instance_v2.master_nodes]
  triggers = {
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
    content = templatefile("config/kubeadm.tmpl", {
      control_plane_endpoint = var.control_plane_endpoint
      cluster_name           = var.cluster_name
      fip_address            = openstack_networking_floatingip_v2.fip.address
      pod_cidr               = var.pod_cidr
      srv_cidr               = var.srv_cidr
    })
    destination = "/tmp/kubeadm.conf"
  }

  provisioner "file" {
    content = templatefile("config/kubeadm-init.sh", {
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
    first_master = values(openstack_compute_instance_v2.master_nodes)[0].id
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
  triggers = {
    master = join(", ", [for instance in openstack_compute_instance_v2.master_nodes : instance.id])
  }
  for_each = toset(slice(tolist(var.master_node_names), 1, length(var.master_node_names)))
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
  triggers = {
    worker = join(", ", [for instance in openstack_compute_instance_v2.worker_nodes : instance.id])
  }
  for_each = var.worker_node_names
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
      "echo KUBELET_EXTRA_ARGS=\"--cloud-provider=external\" | sudo tee /etc/default/kubelet",
      "sudo chmod +x worker_join.sh",
      "sudo ./worker_join.sh",
      "sleep 1",
    ]
  }
}

resource "null_resource" "get_kube_cred" {
  depends_on = [null_resource.bootstrap_cluster]

  provisioner "local-exec" {
    command = "mkdir output && scp -o \"StrictHostKeyChecking=no\" -i $DO_KEY -P $DO_PORT $DO_USER@$DO_HOST:~/.kube/config output/kubeconfig"

    environment = {
      DO_PORT = 2222
      DO_HOST = openstack_networking_floatingip_v2.fip.address
      DO_USER = "ubuntu"
      DO_KEY  = var.private_key_path
    }
  }

}

resource "local_file" "create_os_config" {
  depends_on = [null_resource.get_kube_cred]

  content = templatefile("config/cloud-config.tmpl", {
    os_user   = var.os_user
    os_pass   = var.os_pass
    os_url    = var.os_authurl
    os_tid    = var.os_projectid 
    os_subnet = openstack_networking_subnet_v2.subnet_v4.id
  })
  filename = "output/cloud-config"
}

resource "null_resource" "add_ske_stuff" {
  depends_on = [local_file.create_os_config, null_resource.get_kube_cred]

  provisioner "local-exec" {
    command = "kubectl create secret -n kube-system generic cloud-config --from-literal=cloud.conf=\"$(cat output/cloud-config)\""

    environment = {
      KUBECONFIG = "output/kubeconfig"
    }
  }

  provisioner "local-exec" {
    command = "/bin/bash config/add-ske-stuff.sh "

    environment = {
      KUBECONFIG = "output/kubeconfig"
      CLUSTER_NAME = var.cluster_name
    }
  }
}
