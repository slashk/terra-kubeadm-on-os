output "master_public_ip" {
  value = "${openstack_compute_floatingip_v2.kube.address}"
}

output "sshkey" {
  value = "${var.ssh_key_file}"
}

output "master_private_ip" {
  value = "${openstack_compute_instance_v2.kube-master.network.0.fixed_ip_v4}"
}

output "username" {
  value = "${var.ssh_user_name}"
}

output "token" {
  value = "${var.kube_token}"
}

output "worker_private_ip" {
  value = ["${openstack_compute_instance_v2.kube-worker.*.network.0.fixed_ip_v4}"]
}
