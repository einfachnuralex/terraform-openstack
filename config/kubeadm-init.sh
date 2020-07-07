#!/bin/bash
while [ "$(dig +short A ${control_plane_endpoint})" != ${fip_address} ]; do
  echo "waiting for dns entry..."
  echo "shoud match ${fip_address}"
  echo "but is" $(dig +short A ${control_plane_endpoint})
  sleep 5
done

set -e
# kubeadm init if not already done
if [ ! -f /etc/kubernetes/pki/ca.key ]; then
  echo "Bootstrapping new Cluster"
  sudo kubeadm init --config kubeadmconfig.yaml --v=5
fi
echo "#### Bootstrapp finished or skipped ####"

# get worker join
echo "create worker join"
sudo kubeadm token create --print-join-command >worker_join.sh 2>/dev/null

# get master join
echo "create master join"
certKey=$(sudo kubeadm init phase upload-certs --upload-certs 2>/dev/null | tail -n 1)
sudo kubeadm token create --print-join-command --certificate-key $certKey >master_join.sh 2>/dev/null

# copy join to master / worker
%{ for master_ip in master_ips ~}
echo "copy master_join to ${master_ip} ..."
ssh-keyscan -H ${master_ip} >>~/.ssh/known_hosts
scp master_join.sh ${master_ip}:

%{ endfor ~}

%{ for worker_ip in worker_ips ~}
echo "copy worker_join to ${worker_ip} ..."
ssh-keyscan -H ${worker_ip} >>~/.ssh/known_hosts
scp worker_join.sh ${worker_ip}:

%{ endfor ~}
