# ubuntu 모듈에 입력될 variables
variable "node_count" {}
variable "ami" {}
variable "instance_type" {}
variable "tags" {}
variable "key_name" {}
variable "private_key_path" {}
variable "work_cidr_blocks" {}
variable "volume_size" {}

variable "nexus_instance_id" { default = "" }
variable "nexus_sgroup_id" { default = "" }
variable "gitlab_sgroup_id" { default = "" }
variable "subnet_id_list" { default = [] }
variable "urls" {
  type = map(string)
  default = ({
    nexus           = "nexus.wai"
    docker          = "docker.wai"
    gitlab          = "mygitlab.com"
  })
}

## 출력
output "id" {
  description = "ID of the EC2 instance"
  value       = module.ubuntu.id_list
}
output "public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = module.ubuntu.public_ip_list
}
output "private_ip" {
  description = "Private IP address of the EC2 instance"
  value       = module.ubuntu.private_ip_list
}
output "subnet_id" {
  description = "AWS Subnet ID"
  value       = module.ubuntu.subnet_id_list
}
output "tags" {
  description = "Instance Tags"
  value       = module.ubuntu.tags_list
}
output "controlplane" {
  description = "K3s Server"
  value = [
    module.ubuntu.id_list[0],
    module.ubuntu.public_ip_list[0],
    module.ubuntu.private_ip_list[0],
    module.ubuntu.tags_list[0]
  ]
}