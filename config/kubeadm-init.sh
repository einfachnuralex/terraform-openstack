#!/bin/bash
while [[ -z $(dig +short AAAA ${control_plane_endpoint}) ]]
do
    echo "waiting for dns entry..."
    sleep 5
done

set -e
sudo kubeadm init --config kubeadmconfig.yaml --v=5 | tee result.log
sudo kubeadm --print-join-command > worker_join.sh
(cat worker_join.sh ; echo '--control-plane')

%{ for master_ip in master_ips ~}
ssh-keyscan -H ${master_ip} >> ~/.ssh/known_hosts
scp master_join.sh ${master_ip}:

%{ endfor ~}

%{ for worker_ip in worker_ips ~}
ssh-keyscan -H ${worker_ip} >> ~/.ssh/known_hosts
scp worker_join.sh ${worker_ip}:

%{ endfor ~}