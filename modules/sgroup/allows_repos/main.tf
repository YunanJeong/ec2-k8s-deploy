######################################################################
# 기존 저장소 보안그룹에 "보안규칙" 등록하기

# 참고) 신규 보안그룹을 생성 후 저장소 인스턴스에 추가하는 방식은 불가
# => 인스턴스 당 등록가능한 보안그룹 개수가 매우 적기 때문에 금방 한계에 도달한다.
######################################################################



######################################################################
# 저장소에 접근할 소스 인스턴스 정보
######################################################################
# 인스턴스 id 목록으로 인스턴스의 정보 가져오기
data "aws_instance" "srcs" {
  count       = length(var.src_instance_ids)
  instance_id = var.src_instance_ids[count.index]
}
locals {
  src_public_ips = [for src in data.aws_instance.srcs : src.public_ip]
  # src_private_ips = [for src in data.aws_instance.srcs : src.private_ip]
}

######################################################################
# 저장소 보안그룹에 신규 규칙 추가
######################################################################

# 도커저장소는 http기반으로 사용 중이므로, 보안을 위해 VPC 내 Private IP 통신만 허용
# IP 대신 보안그룹 허용방식으로 간결하게 보안규칙 생성
resource "aws_security_group_rule" "rule_nexus_docker" {
  description              = "allows_${var.src_tags.Name}(docker)(private)"
  count                    = var.nexus_sgroup_id == "" ? 0 : 1
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = var.nexus_sgroup_id
  source_security_group_id = var.src_basic_sgroup_id
}

# 파일저장소는 Public으로 허용. 컨테이너 내부에서 접근시 공인망 통신해야 편함
resource "aws_security_group_rule" "rule_nexus_file" {
  description       = "allows_${var.src_tags.Name}(file)(public)"
  count             = var.nexus_sgroup_id == "" ? 0 : 1
  type              = "ingress"
  from_port         = 8081
  to_port           = 8081
  protocol          = "tcp"
  security_group_id = var.nexus_sgroup_id
  cidr_blocks       = [for ip in local.src_public_ips[*] : replace(ip, ip, "${ip}/32")]
}

# gitlab 접근 허용 규칙
resource "aws_security_group_rule" "rule_gitlab" {
  description       = "allows_${var.src_tags.Name}-0"
  count             = var.gitlab_sgroup_id == "" ? 0 : 1
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = var.gitlab_sgroup_id
  cidr_blocks       = ["${local.src_public_ips[0]}/32"] # 0번 노드(k3s server)만 허용
  # cidr_blocks       = [for ip in local.src_public_ips[*] : replace(ip, ip, "${ip}/32")]  # 모든 노드 허용
}


######################################################################
# /etc/hosts 파일설정
######################################################################
# Nexus IP 가져오기
data "aws_instance" "nexus" {
  count       = var.nexus_instance_id == "" ? 0 : 1
  instance_id = var.nexus_instance_id
}
locals {
  nexus_ip = var.nexus_instance_id == "" ? "N/A" : data.aws_instance.nexus[0].private_ip
}

resource "null_resource" "preset" {
  count = var.nexus_sgroup_id == "" ? 0 : length(local.src_public_ips)
  connection {
    type        = "ssh"
    host        = local.src_public_ips[count.index]
    user        = "ubuntu"
    private_key = file(var.src_private_key_path)
    agent       = false
  }
  provisioner "remote-exec" {
    inline = [
      "cloud-init status --wait",
      "sudo su -c 'echo ${local.nexus_ip} ${var.urls.nexus} >> /etc/hosts' ",
      "sudo su -c 'echo ${local.nexus_ip} ${var.urls.docker} >> /etc/hosts' ",
      # /etc/docker/daemon.json에서 사설 저장소 허용 등록이 필요한데, 메인모듈의 도커설치과정에서 처리한다.
    ]
  }
}