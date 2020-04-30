resource "null_resource" "lb_provisioner" {
  depends_on = [openstack_compute_floatingip_associate_v2.fip_associate]
  connection {
    type        = "ssh"
    host        = openstack_compute_floatingip_v2.fip.address
    user        = "ubuntu"
    private_key = file(var.private_key_path)
    timeout     = "5m"
  }

  provisioner "file" {
    content = templatefile("config/nginx.tmpl", {
      ip_addrs = [for instance in openstack_compute_instance_v2.ske_master : instance.access_ip_v6],
      port     = 6443
    })
    destination = "/tmp/nginx.conf"
  }

  provisioner "file" {
    content = templatefile("config/kubeadm.tmpl", {
      control_plane_endpoint = var.control_plane_endpoint
    })
    destination = "/tmp/kubeadm.conf"
  }

  provisioner "file" {
    content = templatefile("config/kubeadm-init.sh", {
      master_1_ip = values(openstack_compute_instance_v2.ske_master)[0].access_ip_v4
      master_2_ip = values(openstack_compute_instance_v2.ske_master)[1].access_ip_v4
    })
    destination = "/tmp/kubeadm-init.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get install -y nginx",
      "sudo apt-get install -y nginx libnginx-mod-stream",
      "sudo mv /tmp/nginx.conf /etc/nginx/nginx.conf",
      "sudo mv /tmp/kubeadm.conf /home/ubuntu/kubeadmconfig.yaml",
      "sudo mv /tmp/kubeadm-init.sh /home/ubuntu/kubeadmconfig.kubeadm-init.sh",
      "sudo systemctl restart nginx",
      "sleep 20",
    ]
  }
}

resource "null_resource" "kubeadm_provisioner" {
  depends_on = [null_resource.lb_provisioner]
  connection {
    type        = "ssh"
    host        = openstack_compute_floatingip_v2.fip.address
    user        = "ubuntu"
    private_key = file(var.private_key_path)
    timeout     = "5m"
  }

  /*   provisioner "file" {
    content = templatefile("config/nginx.tmpl", {
      ip_addrs = [for instance in openstack_compute_instance_v2.ske_master : instance.access_ip_v6],
      port     = 6443
    })
    destination = "/tmp/nginx.conf"
  } */

  provisioner "remote-exec" {
    inline = [
      "echo lol"
    ]
  }
}

