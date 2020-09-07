# terraform-openstack

## Prerequisite
- Terraform > v0.12.24
- Copy `openstack RC-File` to `auth/`
- Copy `dns Auth File` to `auth/dns-auth.json`
- Copy `private key` to `auth/ske-key`

## Installation
1. Check files and naming in `auth/` folder
1. Configure variables in `deploy.sh` (above script section)
1. run script with
```
./deploy.sh
```


