#!/bin/bash
kubeadm_join=$(ssh ${master_1_ip} sudo kubeadm init --config kubeadmconfig.yaml --upload-certs 2>&1; echo $? | grep -A 2 "kubeadm join")
echo $(ssh ${master_2_ip} sudo $kubeadm_join 2>&1; echo $?)
