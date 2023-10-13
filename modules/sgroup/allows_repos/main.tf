
######################################################################
# EC2로 띄워놓은 사설 저장소(NEXUS)에 보안그룹 추가하기
######################################################################

# 저장소 인스턴스 정보 가져오기
data "aws_instance" "nexus" {
  count       = var.nexus_enabled ? 1 : 0
  instance_id = var.nexus_instance_id
}
locals {
  nexus_ip = var.nexus_enabled ? data.aws_instance.nexus[0].public_ip : "N/A"
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
      "sudo su -c 'echo ${local.nexus_ip} nexus.wai >> /etc/hosts' ",
      "sudo su -c 'echo ${local.nexus_ip} docker.wai >> /etc/hosts' ",
      "sudo su -c 'echo ${local.nexus_ip} private.docker.wai >> /etc/hosts' ",
    ]
  }
}

# 저장소에 추가할 보안그룹
resource "aws_security_group" "nexus_allows"{
  name = "nexus_allows_${var.src_tags.Name}"
  ingress{
    from_port   = 80
    to_port     = 80
    description = "nexus_allows"
    protocol    = "tcp"

    # 할당된 인스턴스 ip에 문자열 '/32'를 붙이고 리스트로 반환
    cidr_blocks = [ for ip in var.src_ips[*]: replace(ip,ip,"${ip}/32") ]
  }
}
# 저장소에 보안그룹 추가하기
resource "aws_network_interface_sg_attachment" "nexus_attach" {
    count                = var.nexus_enabled ? 1 : 0
    security_group_id    = aws_security_group.nexus_allows.id
    network_interface_id = data.aws_instance.nexus[count.index].network_interface_id
}


######################################################################
# EC2로 띄워놓은 사설 저장소(Gitlab)에 보안그룹 추가하기
######################################################################
# 저장소 인스턴스 정보 가져오기
data "aws_instance" "gitlab" {
  count       = var.gitlab_enabled ? 1 : 0
  instance_id = var.gitlab_instance_id
}

# 저장소에 추가할 보안그룹
resource "aws_security_group" "gitlab_allows"{
  name = "gitlab_allows_${var.src_tags.Name}"
  ingress{
    from_port   = 443
    to_port     = 443
    description = "gitlab_allows"
    protocol    = "tcp"

    # 할당된 인스턴스 ip에 문자열 '/32'를 붙이고 리스트로 반환
    cidr_blocks = [ for ip in var.src_ips[*]: replace(ip,ip,"${ip}/32") ]
  }
}
# 저장소에 보안그룹 추가하기
resource "aws_network_interface_sg_attachment" "gitlab_attach" {
    count                = var.gitlab_enabled ? 1 : 0
    security_group_id    = aws_security_group.gitlab_allows.id
    network_interface_id = data.aws_instance.gitlab[count.index].network_interface_id
}