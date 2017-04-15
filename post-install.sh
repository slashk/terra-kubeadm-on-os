#!/bin/bash
# Connects Mac to Kubernetes cluster and then install add-ons for
#   - Kuberntes Dashboard
#   - Weavescope
# this script requires bash, kubectl, terraform and jq
# Install on a mac with
#  $ brew install jq terraform kubectl
#

# variables
KCFG="kubectl.cfg"
KCF="--kubeconfig=${KCFG}"
PRIVADDR=`terraform output master_private_ip`
PUBADDR=`terraform output master_public_ip`
KEY=`terraform output sshkey`
USER=`terraform output username`
WORKER_IPS=`terraform output -json worker_private_ip | jq -r '.value[]'`

# add kube-worker entries to /etc/hosts in case they didn't register in DNS
# this is still problematic until kube 1.5
I=0
for x in $WORKER_IPS; do
  ssh -i ${KEY} ${USER}@${PUBADDR} "sudo sed -i '1 a ${x} kube-worker-${I}' /etc/hosts"
  ((I = I + 1))
done

# grab kube config file from kube-master
echo -n "Retrieving kubectl configuration ...."
scp -i ${KEY} ${USER}@${PUBADDR}:/home/ubuntu/admin.conf ${KCFG}
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
kubectl ${KCF} apply -f 'https://cloud.weave.works/launch/k8s/weavescope.yaml'
echo " DONE"

kubectl --kubeconfig=./kubectl.cfg cluster-info
kubectl --kubeconfig=./kubectl.cfg version
echo "SCRIPT COMPLETE."
