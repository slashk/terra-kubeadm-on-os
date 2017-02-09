# Contained in your keystonerc file
# MUST CHANGE THESE !
region= "RegionOne"
user_name = "ken"
tenant_name = "k8s"
password = "this.is.not.my.password"
auth_url = "http://10.0.2.201:5000/v2.0"
# openstack image list
image_id = "6f5981a2-2e64-4381-ba68-e25a15c220e0"
# username of that image (ubuntu)
ssh_user_name = "ubuntu"
# floating ip pool list
pool = "lab"
# openstack flavor list
master_flavor = "kube-master"
worker_flavor = "kube-master"
# keyfile path on your laptop
ssh_key_file = "~/.ssh/terraform"
# gateway of your external network
external_gateway = "fdcb4758-44da-4d15-ad7d-d7fce1d973ce"
# customize to your cluster
worker_count = "2"
kube_token = "123456.0123456789012345"
dns_nameservers = ["10.0.2.1"]
tenant_net_cidr = "192.168.50.0/24"
kube_version = "v1.5.2"
