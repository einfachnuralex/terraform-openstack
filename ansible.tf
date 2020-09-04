resource "local_file" "create_ansible_cfg" {
  depends_on = [
    openstack_lb_loadbalancer_v2.elastic_lb
  ]
  content  = <<-EOF
    [defaults]
    inventory = ./hosts.ini

    [ssh_connection]
    ssh_args = -o ProxyCommand="ssh -F ./ssh_config -W %h:%p ${var.ssh_user}@${openstack_networking_floatingip_v2.fip.address} -p 22"
  EOF
  filename = "ansible/ansible.cfg"
}

resource "local_file" "create_ansible_inventory" {
  depends_on = [
    openstack_compute_instance_v2.master_nodes,
    openstack_compute_instance_v2.worker_nodes
  ]

  content = templatefile("config/ansible-host.tmpl", {
    ssh_user = var.ssh_user
    master_nodes = [for master in openstack_compute_instance_v2.master_nodes : {
      hostname = master.name
      address  = master.access_ip_v4
    }]
    worker_nodes = [for worker in openstack_compute_instance_v2.worker_nodes : {
      hostname = worker.name
      address  = worker.access_ip_v4
    }]
  })
  filename = "ansible/hosts.ini"
}

resource "local_file" "create_kubeadm_config" {
  depends_on = [
    openstack_networking_floatingip_v2.fip
  ]

  content = templatefile("config/kubeadm.tmpl", {
    control_plane_endpoint = var.control_plane_endpoint
    cluster_name           = var.cluster_name
    k8s_version            = var.k8s_version
    fip_address            = openstack_networking_floatingip_v2.fip.address
    pod_dual_cidr          = "${var.pod_cidr_v4},${var.pod_cidr_v6}"
    svc_dual_cidr          = "${var.svc_cidr_v4},${var.svc_cidr_v6}"
  })
  filename = "output/kubeadm.yaml"
}

resource "local_file" "create_os_config" {
  content = templatefile("config/cloud-config.tmpl", {
    os_user   = var.openstack_user
    os_pass   = var.openstack_pass
    os_url    = var.openstack_authurl
    os_tid    = var.openstack_projectid
    os_subnet = openstack_networking_subnet_v2.subnet_v4.id
  })
  filename = "output/cloud-config"
}

resource "null_resource" "ansible_runner" {
  depends_on = [
    local_file.create_ansible_inventory,
    local_file.create_ansible_cfg,
    openstack_lb_loadbalancer_v2.elastic_lb,
    openstack_lb_member_v2.member_k8s,
    openstack_lb_member_v2.member_ssh,
  ]
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = "cd ansible && ansible-playbook playbook.yaml"

    environment = {
      ANSIBLE_HOST_KEY_CHECKING = false
      ANSIBLE_FORCE_COLOR       = 1
    }
  }
}