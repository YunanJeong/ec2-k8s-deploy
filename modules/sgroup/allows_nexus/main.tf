
######################################################################
# EC2로 띄워놓은 사설 저장소(NEXUS)에 보안그룹 추가하기
######################################################################

# 저장소 인스턴스 정보 가져오기
data "aws_instance" "nexus" {
  count       = var.nexus_enabled ? 1 : 0
  instance_id = var.nexus_instance_id
}

resource "null_resource" "preset"{
  count = length(var.src_ips)
  connection {
    type        = "ssh"
    host        = var.src_ips[count.index]
    user        = "ubuntu"
    private_key = file(var.src_private_key_path)
    agent       = false
  }
  provisioner "file"{
    source = "${path.module}/daemon.json"
    destination = "/home/ubuntu/daemon.json"
  }
  provisioner "remote-exec" {
    inline = [
      "cloud-init status --wait",
      "sudo mkdir -p /etc/docker && sudo cp ~/daemon.json /etc/docker/daemon.json",
      "sudo su -c 'echo ${data.aws_instance.nexus[count.index].public_ip} nexus.wai >> /etc/hosts' ",
      "sudo su -c 'echo ${data.aws_instance.nexus[count.index].public_ip} docker.wai >> /etc/hosts' ",
      "sudo su -c 'echo ${data.aws_instance.nexus[count.index].public_ip} private.docker.wai >> /etc/hosts' ",
    ]
  }
}

# 저장소에 추가할 보안그룹
resource "aws_security_group" "allows_nexus"{
  name = "allows_from_${var.src_tags.Name}"
  ingress{
    from_port   = 80
    to_port     = 80
    description = "allows_nexus"
    protocol    = "tcp"

    # 할당된 인스턴스 ip에 문자열 '/32'를 붙이고 리스트로 반환
    cidr_blocks = [ for ip in var.src_ips[*]: replace(ip,ip,"${ip}/32") ]
  }
}

# 저장소에 보안그룹 추가하기
resource "aws_network_interface_sg_attachment" "nexus_attach" {
    count                = var.nexus_enabled ? 1 : 0
    security_group_id    = aws_security_group.allows_nexus.id
    network_interface_id = data.aws_instance.nexus[count.index].network_interface_id
}