# terraform-openstack

## Prerequisite
- Terraform > v0.12.24
- Openstack RC File
- Google Cloud DNS Auth file

## Usage
1. `terraform init`
1. copy `terraform.tfvars.template` to `terraform.tfvars` 
1. set values for outcommended lines in `terraform.tfvars`
1. add following to your `openstack rc file`:
```
export TF_VAR_os_authurl=$OS_AUTH_URL
export TF_VAR_os_user=$OS_USERNAME
export TF_VAR_os_pass=$OS_PASSWORD
export TF_VAR_os_project=$OS_PROJECT_NAME
export TF_VAR_os_projectid=$OS_PROJECT_ID
```
1. `source <openstack rc file>`
1. `terraform apply`
