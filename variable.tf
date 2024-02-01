variable "ami" {
  default = "ami-09eb2ed0e9c2f6126" 
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

variable "ssh-port" {
  default = 22
}

variable "http-port" {
  default = 80
}

variable "https-port" {
   default = 443
}

variable "certificate" {
  default = "your cert arn"
}

variable "alb-ingress-port" {
  type = list 
  default = [80,443]
}