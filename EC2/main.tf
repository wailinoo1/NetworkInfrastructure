resource "aws_security_group" "ec2-sg" {
  name   = "ec2-sg"
  vpc_id = var.vpcid
  
  dynamic "ingress" {
    for_each = var.ingress-port
    content {
      from_port        = ingress.value
      to_port          = ingress.value
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
    }
  }
  egress {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "instance" {
  ami                     = var.ami
  instance_type           = var.instance-type
  key_name                = var.keypair
  count = length(var.subnetid)
  subnet_id               = var.subnetid[count.index]
  vpc_security_group_ids = [aws_security_group.ec2-sg.id]
  user_data = file("/mnt/d/Terraform/NetworkInfrastructure/EC2/install-nginx.sh")
  root_block_device {
     encrypted = false
     iops = 3000
     volume_size = 30
  }
  tags = {
    Name = var.instance-name
  }
  depends_on = [ aws_security_group.ec2-sg ]
}
