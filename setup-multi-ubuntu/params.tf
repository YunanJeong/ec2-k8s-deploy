# ubuntu 모듈에 입력될 variables
variable "ubuntu_node_count"{}
variable "ubuntu_ami"{}
variable "ubuntu_instance_type"{}
variable "ubuntu_tags"{}
variable "ubuntu_key_name"{}
variable "ubuntu_private_key_path"{}
variable "ubuntu_work_cidr_blocks"{}

## 출력
output "id" {
  description = "ID of the EC2 instance"
  value       = module.ubuntu.id_list
}
output "public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = module.ubuntu.public_ip_list
}
output "tags" {
  description = "Instance Tags"
  value = module.ubuntu.tags_list
}