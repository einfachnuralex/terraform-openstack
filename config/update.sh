while [ ! -f /var/lib/cloud/instance/boot-finished ]
do 
    echo 'Waiting for cloud-init...' 2>$1
    sleep 2
done

set +e
false
while [ $? != 0 ]
do
    yes | sudo apt-get update
    sleep 2
done
set -e
yes | sudo apt-get install kubeadm=1.18.2-00 kubectl=1.18.2-00 kubelet=1.18.2-00