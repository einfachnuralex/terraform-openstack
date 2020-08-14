#!/bin/bash

function bootstrapCluster() {
  # set hostname for localhost
  sudo sed -i -e '1i127.0.0.1 '"$HOSTNAME"'\' /etc/hosts

  # wait till dns entry is set
  echo -e "\n#### wait for dns entry ####\n"
  while [ "$(dig +short A ${control_plane_endpoint})" != ${fip_address} ]; do
    echo "shoud match ${fip_address} ...but doesn't"
    sudo systemd-resolve --flush-caches
    sleep 5
  done

  # kubeadm init if not already done
  set -e
  echo -e "\n#### bootstrapping new cluster ####\n"
  sudo kubeadm init --config kubeadmconfig.yaml --v=5
  mkdir .kube && sudo cp /etc/kubernetes/admin.conf ~/.kube/config
  sudo chown ubuntu ~/.kube/config
}

function cleanUp() {
  rm -rf kubeadm-init.sh
  rm -rf master_join.sh
  rm -rf worker_join.sh
  rm -rf kubeadmconfig.yaml
}

if [ ! -f /etc/kubernetes/pki/ca.key ]; then
  bootstrapCluster
  echo -e "\n#### bootstrapp finished ####\n"
fi

# create and copy worker- & master_join.sh
set -e
echo -e "\n#### create&copy master/worker joins ####\n"

sudo kubeadm token create --print-join-command >worker_join.sh 2>/dev/null
certKey=$(sudo kubeadm init phase upload-certs --upload-certs 2>/dev/null | tail -n 1)
sudo kubeadm token create --print-join-command --certificate-key $certKey >master_join.sh 2>/dev/null

%{ for master_ip in master_ips ~}
echo "copy master_join to ${master_ip}"
#to avoid yes/no request
ssh-keyscan -H ${master_ip} >>~/.ssh/known_hosts
scp master_join.sh ${master_ip}: 1>/dev/null

%{ endfor ~}

%{ for worker_ip in worker_ips ~}
echo "copy worker_join to ${worker_ip}"
ssh-keyscan -H ${worker_ip} >>~/.ssh/known_hosts
scp worker_join.sh ${worker_ip}: 1>/dev/null

%{ endfor ~}
