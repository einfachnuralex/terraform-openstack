# terraform-openstack

## Branches / states

### master
Automated Provisioning of:
- master / worker instances
- nginx loadbalancer (ipv6-lb to masters)

Supported OS: Ubuntu

### kubeadm-enablement
Automated Provisioning of:
- master worker instances
- kubeadm init on first_master
- kubeadm join on masters / workers

Suppoted OS: Ubuntu   
Supported Kubernetes Version: 18.02

## Prerequisite
- Terraform > v0.12.24
- Openstack RC File
- Google Cloud DNS Auth file (only for kubeadm-enablement)

## Usage
1. `terraform init`
1. `source <openstack rc file>`
1. set value for all outcommended lines in `terraform.tfvars`
1. `terraform apply`
