resource "local_file" "create_os_config" {
  content  = templatefile("config/ansible-hosts.tmpl", {
    os_user      = var.os_user
    master_nodes = [for master in openstack_compute_instance_v2.master_nodes : {
      hostname = master.name
      address = master.access_ip_v4
    }]
    worker_nodes = [for worker in openstack_compute_instance_v2.worker_nodes : {
      hostname = worker.name
      address = worker.access_ip_v4
    }]
  })
  filename = "output/cloud-config"
}