# terraform-openstack

## Prerequisite
- Terraform > v0.12.24
- Openstack RC File
- Google Cloud DNS Auth file

## Installation

## Preparation 
1. Copy `openstack RC-File` to `auth/`
2. Copy `dns Auth File` to `auth/dns-auth.json`
3. Copy `private key` to `auth/ske-key`

```
export TF_VAR_os_authurl=$OS_AUTH_URL
export TF_VAR_os_user=$OS_USERNAME
export TF_VAR_os_pass=$OS_PASSWORD
export TF_VAR_os_project=$OS_PROJECT_NAME
export TF_VAR_os_projectid=$OS_PROJECT_ID
```
1. `source <openstack rc file>`
1. `terraform apply`
