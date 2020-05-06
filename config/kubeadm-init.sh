#!/bin/bash
while [[ -z $(dig +short AAAA ${control_plane_endpoint}) ]]
do
    echo "waiting for dns entry..."
    sleep 5
done
sudo kubeadm init --config kubeadmconfig.yaml --upload-certs | tee result.log
grep -B2 \\--certificate-key result.log > master_join.sh
tail -n 2 result.log > worker_join.sh

%{ for master_ip in master_ips ~}
ssh-keyscan -H ${master_ip} >> ~/.ssh/known_hosts
scp master_join.sh ${master_ip}:

%{ endfor ~}

%{ for worker_ip in worker_ips ~}
ssh-keyscan -H ${worker_ip} >> ~/.ssh/known_hosts
scp worker_join.sh ${worker_ip}:

%{ endfor ~}