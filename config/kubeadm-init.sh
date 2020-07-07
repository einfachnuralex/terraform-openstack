#!/bin/bash
while [ "$(dig +short A cp6.gardener.ganter.dev)" != ${fip_address} ]; do
  echo "waiting for dns entry..."
  echo "shoud match ${fip_address}"
  echo "but is" $(dig +short A cp6.gardener.ganter.dev)
  sleep 5
done

set -e
# kubeadm init first master
sudo kubeadm init --config kubeadmconfig.yaml --v=3

# get worker join
sudo kubeadm token create --print-join-command >worker_join.sh

# get master join
certKey=$(sudo kubeadm init phase upload-certs --upload-certs 2>0 | tail -n 1)
sudo kubeadm token create --print-join-command --certificate-key $certKey >master_join.sh

# copy join to master / worker
%{ for master_ip in master_ips ~}
ssh-keyscan -H ${master_ip} >>~/.ssh/known_hosts
scp master_join.sh ${master_ip}:

%{ endfor ~}

%{ for worker_ip in worker_ips ~}
ssh-keyscan -H ${worker_ip} >>~/.ssh/known_hosts
scp worker_join.sh ${worker_ip}:

%{ endfor ~}
