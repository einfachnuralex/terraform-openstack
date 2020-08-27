#!/bin/bash
# set infrastructure vars
OPENSTACK_PROJECT=""

# set cluster vars
CLUSTER_NAME=""
K8S_VERSION=""
MASTER_NODE_COUNT=""
WORKER_NODE_COUNT=""
KEY_PAIR_NAME=""

#set network vars
POD_CIDR_v4=""
POD_CIDR_v6=""
SVC_CIDR_v4=""
SVC_CIDR_v6=""
NODE_CIDR_v4=""
NODE_CIDR_v6=""

# set DNS vars
DOMAIN=""
DNS_ZONE_NAME=""
DNS_ZONE_PROJECT=""
DNS_ZONE_REGION=""

# script section
source auth/${OPENSTACK_PROJECT}-openrc.sh

export TF_VAR_os_authurl=$OS_AUTH_URL
export TF_VAR_os_user=$OS_USERNAME
export TF_VAR_os_pass=$OS_PASSWORD
export TF_VAR_os_project=$OS_PROJECT_NAME
export TF_VAR_os_projectid=$OS_PROJECT_ID
export TF_VAR_cluster_name=$CLUSTER_NAME
export TF_VAR_k8s_version=$K8S_VERSION
export TF_VAR_master_node_count=$MASTER_NODE_COUNT
export TF_VAR_worker_node_count=$WORKER_NODE_COUNT
export TF_VAR_key_pair_name=$KEY_PAIR_NAME
export TF_VAR_pod_cidr_v4=$POD_CIDR_v4
export TF_VAR_pod_cidr_v6=$POD_CIDR_v6
export TF_VAR_svc_cidr_v4=$SVC_CIDR_v4
export TF_VAR_svc_cidr_v6=$SVC_CIDR_v6
export TF_VAR_node_cidr_v4=$NODE_CIDR_v4
export TF_VAR_node_cidr_v6=$NODE_CIDR_v6
export TF_VAR_control-plane-endpoint=${CLUSTER_NAME}.${DOMAIN}
