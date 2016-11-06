provider "openstack" {
  user_name   = "${var.user_name}"
  tenant_name = "${var.tenant_name}"
  password    = "${var.password}"
  auth_url    = "${var.auth_url}"
}

resource "openstack_networking_network_v2" "kube" {
  name           = "kube"
  region         = "${var.region}"
  admin_state_up = "true"
}

resource "openstack_compute_keypair_v2" "kube" {
  name       = "SSH keypair for kube instances"
  region     = "${var.region}"
  public_key = "${file("${var.ssh_key_file}.pub")}"
}

resource "openstack_networking_subnet_v2" "kube" {
  name            = "kube"
  region          = "${var.region}"
  network_id      = "${openstack_networking_network_v2.kube.id}"
  cidr            = "${var.tenant_net_cidr}"
  ip_version      = 4
  enable_dhcp     = "true"
  dns_nameservers = "${var.dns_nameservers}"
}

resource "openstack_networking_router_v2" "kube" {
  name             = "kube"
  region           = "${var.region}"
  admin_state_up   = "true"
  external_gateway = "${var.external_gateway}"
}

resource "openstack_networking_router_interface_v2" "kube" {
  region    = "${var.region}"
  router_id = "${openstack_networking_router_v2.kube.id}"
  subnet_id = "${openstack_networking_subnet_v2.kube.id}"
}

resource "openstack_compute_floatingip_v2" "kube" {
  depends_on = ["openstack_networking_router_interface_v2.kube"]
  region     = "${var.region}"
  pool       = "${var.pool}"
}

resource "openstack_compute_secgroup_v2" "kube" {
  name        = "kube"
  region      = "${var.region}"
  description = "Security group for the kube instances"

  rule {
    from_port   = 1
    to_port     = 65535
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = 1
    to_port     = 65535
    ip_protocol = "udp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    ip_protocol = "icmp"
    from_port   = "-1"
    to_port     = "-1"
    cidr        = "0.0.0.0/0"
  }
}

resource "openstack_compute_instance_v2" "kube-master" {
  name            = "kube-master"
  region          = "${var.region}"
  image_id        = "${var.image_id}"
  flavor_name     = "${var.master_flavor}"
  key_pair        = "${openstack_compute_keypair_v2.kube.name}"
  security_groups = ["${openstack_compute_secgroup_v2.kube.name}"]
  floating_ip     = "${openstack_compute_floatingip_v2.kube.address}"

  network {
    uuid = "${openstack_networking_network_v2.kube.id}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo sed -i -r  's/127.0.0.1 localhost/127.0.0.1 localhost kube-master/' /etc/hosts",
      "sudo sh -c 'echo \"deb http://apt.kubernetes.io/ kubernetes-xenial main\" >> /etc/apt/sources.list.d/kubernetes.list'",
      "curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg -o /tmp/key.gpg",
      "sudo apt-key add /tmp/key.gpg",
      "sudo apt-get update",
      "sudo apt-get -y upgrade",
      "sudo apt-get install -y docker.io htop kubelet kubeadm kubectl kubernetes-cni",
      "sudo service kubelet restart",
      "sudo kubeadm init --token ${var.kube_token}",
      "sudo cp -v /etc/kubernetes/admin.conf /home/ubuntu/config",
      "sudo chown ubuntu /home/ubuntu/config",
      "kubectl apply -f https://git.io/weave-kube",
    ]

    connection {
      user        = "${var.ssh_user_name}"
      private_key = "${file("${var.ssh_key_file}")}"
    }
  }
}

resource "openstack_compute_instance_v2" "kube-worker" {
  name            = "kube-worker-${count.index}"
  count           = "${var.worker_count}"
  region          = "${var.region}"
  image_id        = "${var.image_id}"
  flavor_name     = "${var.worker_flavor}"
  key_pair        = "${openstack_compute_keypair_v2.kube.name}"
  security_groups = ["${openstack_compute_secgroup_v2.kube.name}"]
  depends_on      = ["openstack_compute_instance_v2.kube-master"]

  network {
    uuid = "${openstack_networking_network_v2.kube.id}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo sed -i -r  \"s/127.0.0.1 localhost/127.0.0.1 localhost kube-worker-${count.index}/\" /etc/hosts",
      "sudo sh -c 'echo \"deb http://apt.kubernetes.io/ kubernetes-xenial main\" >> /etc/apt/sources.list.d/kubernetes.list'",
      "curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg -o /tmp/key.gpg",
      "sudo apt-key add /tmp/key.gpg",
      "sudo apt-get update",
      "sudo apt-get -y upgrade",
      "sudo apt-get install -y docker.io htop kubelet kubeadm kubectl kubernetes-cni",
      "sudo service kubelet stop",
      "sudo service kubelet start",
      "sudo kubeadm join --token ${var.kube_token} ${openstack_compute_instance_v2.kube-master.access_ip_v4}",
    ]

    connection {
      type         = "ssh"
      user         = "${var.ssh_user_name}"
      private_key  = "${file("${var.ssh_key_file}")}"
      bastion_host = "${openstack_compute_instance_v2.kube-master.access_ip_v4}"
    }
  }
}
