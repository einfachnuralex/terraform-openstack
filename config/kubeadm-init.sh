#!/bin/bash
scp kubeadmconfig.yaml ${master_1_ip}:
printf "Cheching for correct IP on LB.."; 
while [ $(dig +short AAAA ${control_plane_endpoint}) != '${lb_ip_v6}' ]; 
do 
    echo " is $(dig +short AAAA ${control_plane_endpoint}) expected ${lb_ip_v6} ..still wrong.";
    printf "Cheching for correct IP on LB..";
    sleep 5;
done
kubeadm_join=$(yes | ssh ${master_1_ip} sudo kubeadm init --config kubeadmconfig.yaml --upload-certs 2>&1; echo $? | grep -A 2 "kubeadm join")
echo "#####kubeadm_join####"
echo $kubeadm_join
echo "#####master2 output####"
echo $(yes | ssh ${master_2_ip} sudo $kubeadm_join 2>&1; echo $?)
