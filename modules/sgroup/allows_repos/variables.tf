variable "src_ips" {}
variable "src_private_key_path"{}
variable "src_tags"{}

variable "nexus_enabled"{
  type = bool
  default = true
}
variable "nexus_instance_id"  {}
variable "gitlab_enabled"{
  type = bool
  default = true
}
variable "gitlab_instance_id"  {}

