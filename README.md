# Terraform Your Kubernetes Cluster on OpenStack with Kubeadm

This repo provides the bootstrap scripts to create a Kubernetes cluster on an OpenStack cloud with the `kubeadm` tool.

### What Does This Do ?

A lot:

* Creates VM infrastructure for cluster (with variable number of worker nodes) on OpenStack
* Install single master node with Kubernetes software
* Installs and registers variable number of worker nodes with Kubernetes software
* Configures new cluster with Weave networking
* Writes and retrieves kubectl configuration file
* Installs KubeDNS, Dashboard and WeaveScope add-ons

### What Does This NOT Do ?

A lot:

* High availability control plane
* High availability etcd cluster
* Host on any other cloud than OpenStack
* Host on any other operating system than Ubuntu 16.04 LTS

## For The Impatient

For the impatient:

```
$ brew install kubectl terraform jq
$ curl -O http://github.com/slashk/tf.zip && unzip tf.zip && cd tf
$ terraform apply
$ ./post-install.sh
```
