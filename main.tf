module "network" {
  source = "./NetwrokInfra"
  vpc_cidr_block   = "10.200.0.0/16"
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
  certificate = "your certificate arn from AWS ACM"

}
