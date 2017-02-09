variable "region" {
  default     = "RegionOne"
  description = "OS_REGION_NAME from your OpenStack rc file"
}

variable "image_id" {
  default     = "6f5981a2-2e64-4381-ba68-e25a15c220e0"
  description = "OpenStack image ID from 'openstack image list'"
}

variable "master_flavor" {
  default     = "kube-master"
  description = "Flavor _name_ to use for kube-master size from 'openstack flavor list'"
}

variable "worker_flavor" {
  default     = "kube-master"
  description = "Flavor _name_ to use for kube-worker size from 'openstack flavor list'"
}

variable "user_name" {
  default     = "ken"
  description = "OS_USERNAME from your OpenStack rc file"
}

variable "tenant_name" {
  default     = "kube"
  description = "OS_TENANT_NAME from your OpenStack rc file"
}

variable "password" {
  default     = "sekrit"
  description = "OS_PASSWORD from your OpenStack rc file"
}

variable "auth_url" {
  default     = "http://10.0.2.201:5000/v2.0"
  description = "OS_AUTH_URL from your OpenStack rc file"
}

/* TODO talk about how to generate this */
variable "ssh_key_file" {
  default     = "~/.ssh/terraform"
  description = "SSH private key (usually in your ~/.ssh/ directory)"
}

variable "ssh_user_name" {
  default     = "ubuntu"
  description = "Username for your OpenStack image (This is 'ubuntu' for Ubuntu cloud images)"
}

variable "external_gateway" {
  default     = "fdcb4758-44da-4d15-ad7d-d7fce1d973ce"
  description = "Interface ID for your router connecting to your external provider network"
}

variable "pool" {
  default     = "lab"
  description = "Floating IP address pool to draw kube-master public address"
}

variable worker_count {
  default     = "2"
  description = "Number of kube worker nodes to create"
}

/*TODO this needs to be randomized*/
variable kube_token {
  default     = "123456.0123456789012345"
  description = "Token (in form 6 digits.15 digits) to identify this cluster"
}

variable dns_nameservers {
  default     = ["8.8.8.8", "8.8.4.4"]
  description = "List (using [\"DNS server ip 1\", \"DNS server ip 2\"] to use for OpenStack network created)"
}

variable tenant_net_cidr {
  default     = "192.168.50.0/24"
  description = "CIDR (IP subnet range) to use for kubernetes private network"
}

variable kube_version {
  default     = "v1.5.2"
  description = "kubernetes version of cluster (i.e. --use-kubernetes-version v1.5.2)"
}
