#!/bin/bash
# set infrastructure vars
OPENSTACK_PROJECT="ske-testing-3"

# set cluster vars
CLUSTER_NAME="rapsn-test-refactor"
K8S_VERSION="v1.18.6"
MASTER_COUNT="1"
WORKER_COUNT="1"
KEY_PAIR_NAME="ske-key"

#set network vars
POD_CIDR_v4="10.244.0.0/16"
POD_CIDR_v6="fd02::/80"
SVC_CIDR_v4="172.16.0.0/16"
SVC_CIDR_v6="fd03::/112"
NODE_CIDR_v4="192.168.42.0/24"
NODE_CIDR_v6="fd00:0:1::/60"

# set DNS vars
DOMAIN="gardener.ganter.dev"
DNS_ZONE_NAME="gardener-test-2"
DNS_ZONE_PROJECT="n-1578486715742-95072"
DNS_ZONE_REGION="eu-central1"

# script section
declare -a requiredFiles=("auth/${OPENSTACK_PROJECT}-openrc.sh" "auth/ske-key" "auth/dns-auth.json")
for file in "${requiredFiles[@]}" ; do
  result+=$(test -f "$file" || echo "$file\n";)
done
if [ ! -z "$result" ]; then
  echo -e "Following files are missing: "
  echo -e "$result"
  exit
fi

if [ "$1" == "destroy" ]; then
  terraform destroy
  exit
else
  echo "Usage: deploy.sh <command>
        deploy.sh           deploy infrastructure with terraform and ansible
        deploy.sh destroy   destroy managed infrastructure"
fi

# shellcheck source=auth/${OPENSTACK_PROJECT}-openrc.sh
source auth/${OPENSTACK_PROJECT}-openrc.sh

export TF_VAR_os_authurl=$OS_AUTH_URL
export TF_VAR_os_user=$OS_USERNAME
export TF_VAR_os_pass=$OS_PASSWORD
export TF_VAR_os_project=$OS_PROJECT_NAME
export TF_VAR_os_projectid=$OS_PROJECT_ID
export TF_VAR_cluster_name=$CLUSTER_NAME
export TF_VAR_k8s_version=$K8S_VERSION
export TF_VAR_master_count=$MASTER_COUNT
export TF_VAR_worker_count=$WORKER_COUNT
export TF_VAR_key_pair_name=$KEY_PAIR_NAME
export TF_VAR_pod_cidr_v4=$POD_CIDR_v4
export TF_VAR_pod_cidr_v6=$POD_CIDR_v6
export TF_VAR_svc_cidr_v4=$SVC_CIDR_v4
export TF_VAR_svc_cidr_v6=$SVC_CIDR_v6
export TF_VAR_node_cidr_v4=$NODE_CIDR_v4
export TF_VAR_node_cidr_v6=$NODE_CIDR_v6
export TF_VAR_control_plane_endpoint=${CLUSTER_NAME}.${DOMAIN}
export TF_VAR_dns_zone_name=$DNS_ZONE_NAME
export TF_VAR_dns_zone_project=$DNS_ZONE_PROJECT
export TF_VAR_dns_zone_region=$DNS_ZONE_REGION

terraform apply