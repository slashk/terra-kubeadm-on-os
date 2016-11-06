#!/bin/bash

# variables
KCFG="kubectl.cfg"
KCF="--kubeconfig=${KCFG}"
PRIVADDR=`terraform output master_private_ip`
PUBADDR=`terraform output master_public_ip`
KEY=`terraform output sshkey`
USER=`terraform output username`

# TODO fix kube-master to have kube-worker ip addresses
# for x in `terraform output work-ips`; do
#    ssh -i ${KEY} ${USER}@${PUBADDR} -c "sudo echo '${x}  kube-worker-0' >> /etc/hosts"
#  ssh -i ~/.ssh/terraform ubuntu@10.0.2.139 "sudo sh -c \"echo '192.168.50.4  kube-worker-0' >> /etc/hosts\""
# done

# grab kube config file from kube-master
echo -n "Retrieving kubectl configuration ...."
scp -i ${KEY} \
  `terraform output username`@${PUBADDR}:/home/ubuntu/config \
  ${KCFG}
echo " DONE"

# rewrite config to use self-signed certs and floating ip address
echo -n "Fixing kubectl configuration ...."
for f in ${KCFG}; do printf '%s\n' 5i '    insecure-skip-tls-verify: true' . x | ex "$f"; done
sed -i -r 's/certificate-authority-data:/#&/' ${KCFG}
sed -i -r "s/${PRIVADDR}:/${PUBADDR}:/" ${KCFG}
echo " DONE"

# weavescope
echo -n "Starting weavescope addon ...."
kubectl ${KCF} apply -f 'https://cloud.weave.works/launch/k8s/weavescope.yaml'
echo " DONE"

# dashboard
echo -n "Starting kubernetes dashboard addon ...."
kubectl ${KCF} apply -f 'https://rawgit.com/kubernetes/dashboard/master/src/deploy/kubernetes-dashboard.yaml'
echo " DONE"
