module "ubuntu" {
    source = "./modules/ec2/multi_ubuntu"

    # Module's Variables
    node_count       = var.node_count
    ami              = var.ami
    instance_type    = var.instance_type
    tags             = var.tags
    key_name         = var.key_name
    private_key_path = var.private_key_path
    work_cidr_blocks = var.work_cidr_blocks
}

resource "null_resource" "k8s_nodes"{
  count = var.node_count - 1 
  connection {
    type        = "ssh"
    host        = module.ubuntu.public_ip_list[count.index]
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
    ]
  }
}

resource "null_resource" "k8s_controlplane"{
  connection {
    type        = "ssh"
    host        = module.ubuntu.public_ip_list[var.node_count - 1]
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
}
