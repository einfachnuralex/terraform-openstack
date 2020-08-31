resource "local_file" "create_ansible_bastion_config" {
  depends_on = [openstack_networking_floatingip_v2.fip]

  content  = "ansible_ssh_common_args: '-o ProxyCommand=\"ssh -v -W %h:%p ubuntu@${openstack_networking_floatingip_v2.fip.address} -p 2222\"'"
  filename = "ansible/group_vars/all.yaml"
}

resource "local_file" "create_ansible_inventory" {
  depends_on = [
    openstack_compute_instance_v2.master_nodes,
    openstack_compute_instance_v2.worker_nodes
  ]

  content  = templatefile("config/ansible-host.tmpl", {
    ssh_user     = "ubuntu"
    master_nodes = [for master in openstack_compute_instance_v2.master_nodes : {
      hostname = master.name
      address  = master.access_ip_v4
    }]
    worker_nodes = [for worker in openstack_compute_instance_v2.worker_nodes : {
      hostname = worker.name
      address  = worker.access_ip_v4
    }]
  })
  filename = "ansible/hosts"
}

resource "null_resource" "ansible" {
  depends_on = [local_file.create_ansible_inventory]

  provisioner "local-exec" {
    command = "ansible-playbook -i ansible/hosts ansible/playbook.yaml"
  }
}