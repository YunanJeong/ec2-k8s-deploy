######################################################################
# Set Up Basic
######################################################################
variable "node_count"   {default = 1}
variable "ami"          {default = "ami-063454de5fe8eba79"} # "Canonical, Ubuntu, 22.04 LTS, amd64 jammy image build on 2022-04-20"
variable "instance_type"{default = "t2.micro"}
variable "tags"{
  type = map(string)
  default = ({
    Name    = "yunan-ubuntu-terraform"
    Owner   = "xxxxx@gmail.com"
    Service = "tag-Service"
  })
}
######################################################################
# Key Pair for Secure Connection
######################################################################
variable "key_name"        {default = "my_keypair_name"}
variable "private_key_path"{default = "/home/ubuntu/.ssh/my_keypair_name.pem"}
variable "work_cidr_blocks"{
  description = "인스턴스에서 접속을 허가해줄 로컬PC의 public ip 목록"
  type = list(string)
  default = ["0.0.0.0/32", ]  # e.g.) my pc's public ip
}


output "id_list" {
  description = "ID of the EC2 instance"
  # count로 인해 aws_instance.server가 여러개 있으므로, index를 지정해줘야 값을 호출가능
  # index 자리에 *(asterisk)를 쓰면 value에 전체 list 할당
  value       = aws_instance.server[*].id
}
output "public_ip_list" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.server[*].public_ip
}
output "mutual_cidr_blocks" {
  description = "public_ip_list 내용에 /32 붙임"
  value       = [
    for ip in aws_instance.server[*].public_ip:
      replace(ip,ip,"${ip}/32")
  ]
}
output "tags_list" {
  description = "Instance Tags"
  # 다음과 같이 대괄호 대신 .(dot)으로 써도 전체 list 할당 (위의 대괄호 방식과 동일)
  value = aws_instance.server.*.tags
}

