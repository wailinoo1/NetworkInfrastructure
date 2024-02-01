module "network" {
  source = "./NetwrokInfra"
  vpc_cidr_block   = var.vpc_cidr_block
  vpcname = "wlo-terraform-vpc"
  subnet-name = "terraform-subnet"
  wlo-terraform-igw-name = "wlo-terraform-igw"
  natgw-name = "terraform-nat-gw"
  publicrtname = "public-subnet-routetable"
  privatertname = "private-subnet-routetable"
}

module "server" {
  source = "./EC2"
  vpcid = module.network.vpcid
  subnetid = module.network.subnetid
  ami = "ami-09eb2ed0e9c2f6126"
  instance-type = "t2.micro"
  keypair = "wlo-keypair"
  instance-name = "ec2-terraform"
  ingress-port = [22,80,443]
}

module "loadbalancer" {
  source = "./LoadBalancer"
  vpcid = module.network.vpcid
  alb-ingress-port = [80,443]
  public-subnetid = module.network.public-subnetid
  instance-id = module.server.instance-id
  certificate = "arn:aws:acm:ap-southeast-1:896836667748:certificate/31e9d408-5919-4cc4-b69e-2c1129b177e2"

}