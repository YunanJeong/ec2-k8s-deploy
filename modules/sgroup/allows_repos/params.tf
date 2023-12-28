variable "src_instance_ids"    {}
variable "src_private_key_path"{}
variable "src_tags"            {}
variable "nexus_instance_id"   { default = "" }  # default: 저장소 미사용
variable "gitlab_instance_id"  { default = "" }  # default: 저장소 미사용
variable "nexus_url"           { default = "" }
variable "gitlab_url"          { default = "" }
