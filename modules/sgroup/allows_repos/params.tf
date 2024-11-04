variable "src_instance_ids" {}
variable "src_private_key_path" {}
variable "src_tags" {}
variable "src_basic_sgroup_id" {}

variable "nexus_instance_id" { default = "" }
variable "nexus_sgroup_id" { default = "" }  # default: 저장소 미사용
variable "gitlab_sgroup_id" { default = "" } # default: 저장소 미사용
variable "urls" {
  type = map(string)
  default = ({
    nexus           = "nexus.wai"
    docker          = "docker.wai"
    private_docker  = "private.docker.wai"
    gitlab          = "mygitlab.com"
  })
}