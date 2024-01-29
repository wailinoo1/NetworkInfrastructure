module "network" {
  source = "./NetwrokInfra"
  vpc_cidr_block   = var.vpc_cidr_block
}

module "server" {
  source = "./EC2"
  vpcid = module.network.vpcid
  subnetid = module.network.subnetid
  ami = var.ami
  instance-type = var.instance_type
  keypair = var.keypair
  instance-name = var.instance_name
}