#!/bin/bash
sudo kubeadm init --config kubeadmconfig.yaml --upload-certs | tee result.log
grep -B2 \\--certificate-key result.log > master_join_cmd
tail -n 2 result.log > worker_join_cmd

scp master_join_cmd ${master_2_ip}: