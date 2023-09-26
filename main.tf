module "ubuntu" {
    source = "./modules/ec2/multi_ubuntu"

    # Module's Variables
    node_count       = var.node_count
    ami              = var.ami
    instance_type    = var.instance_type
    volume_size      = var.volume_size
    tags             = var.tags
    key_name         = var.key_name
    private_key_path = var.private_key_path
    work_cidr_blocks = var.work_cidr_blocks

}

resource "null_resource" "k3s_server"{
  connection {
    type        = "ssh"
    host        = module.ubuntu.public_ip_list[0]
    user        = "ubuntu"
    private_key = file(var.private_key_path)
    agent       = false
  }
  provisioner "file"{
    source = "${path.module}/init"
    destination = "/home/ubuntu/init"
  }
  # 실행된 원격 인스턴스에서 수행할 cli명령어
  provisioner "remote-exec" {
    inline = [
      "cloud-init status --wait",
      "sudo chmod +x ~/init/*", 
      "~/init/docker.sh",
      "~/init/controlplane.sh",
    ]
  }
  provisioner "local-exec" {
    command = <<EOT
      chmod 400 ${var.private_key_path}
      ssh -o "StrictHostKeyChecking=no" -i ${var.private_key_path} ubuntu@${module.ubuntu.public_ip_list[0]} 'sudo cat /var/lib/rancher/k3s/server/node-token' > ${path.module}/init/server.token
      ssh -o "StrictHostKeyChecking=no" -i ${var.private_key_path} ubuntu@${module.ubuntu.public_ip_list[0]} 'sudo cat /etc/rancher/k3s/k3s.yaml' > ${path.module}/init/k3s.yaml
      sed -i 's/127.0.0.1/${module.ubuntu.private_ip_list[0]}/g' ${path.module}/init/k3s.yaml
    EOT
  }
}

resource "null_resource" "k3s_agents"{
  depends_on = [ null_resource.k3s_server ]
  count = var.node_count - 1 
  connection {
    type        = "ssh"
    host        = module.ubuntu.public_ip_list[count.index + 1]  # 0번째 인스턴스(controlplane) 제외
    user        = "ubuntu"
    private_key = file(var.private_key_path)
    agent       = false
  }
  provisioner "file"{
    source = "${path.module}/init"
    destination = "/home/ubuntu/init"
  }
  # 실행된 원격 인스턴스에서 수행할 cli명령어
  provisioner "remote-exec" {
    inline = [
      "cloud-init status --wait",
      "sudo chmod +x ~/init/*", 
      "~/init/docker.sh",
      "export K3S_URL=https://${module.ubuntu.private_ip_list[0]}:6443",
      "export K3S_TOKEN=$(cat /home/ubuntu/init/server.token)",
      "~/init/node.sh",
      "sudo mkdir -p /etc/rancher/k3s && sudo cp ~/init/k3s.yaml /etc/rancher/k3s/k3s.yaml",
    ]
  }
}