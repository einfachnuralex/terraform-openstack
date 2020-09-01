resource "local_file" "create_ansible_cfg" {
  depends_on = [
    openstack_lb_loadbalancer_v2.elastic_lb
  ]

  content  = <<-EOF
    [defaults]
    inventory = ./hosts.ini

    [ssh_connection]
    ssh_args = -o ControlMaster=auto -o ControlPersist=30m -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o ForwardAgent=yes -o ProxyCommand="ssh -W %h:%p ${var.ssh_user}@${openstack_networking_floatingip_v2.fip.address} -p 2222"
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

resource "null_resource" "ansible" {
  depends_on = [
    local_file.create_ansible_inventory,
    local_file.create_ansible_cfg,
    openstack_lb_member_v2.member_ssh
  ]

  provisioner "local-exec" {
    command = "cd ansible && ansible-playbook playbook.yaml"

    environment = {
      ANSIBLE_HOST_KEY_CHECKING = false
    }
  }
}
