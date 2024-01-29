variable "ami" {
  default = "ami-02453f5468b897e31"
}
variable "instance_type" {
  default = "t2.micro"
}

variable "wlo-keypair" {
  default = "ec2-terraform"
}
variable "keypair" {
  default = "wlo-keypair"
}

variable "vpc_cidr_block" {
  default = "10.200.0.0/16"
}

variable "instance_name" {
  default = "ec2-terraform"
}