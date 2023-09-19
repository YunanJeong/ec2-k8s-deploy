#############################################################
#
#############################################################
module "ubuntu" {
    source = "../modules/ec2/multi_ubuntu"

    # Module's Variables
    node_count       = var.ubuntu_node_count
    ami              = var.ubuntu_ami
    instance_type    = var.ubuntu_instance_type
    tags             = var.ubuntu_tags
    key_name         = var.ubuntu_key_name
    private_key_path = var.ubuntu_private_key_path
    work_cidr_blocks = var.ubuntu_work_cidr_blocks
}
