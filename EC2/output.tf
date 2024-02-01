output "instance-id" {
  value = [ for ec2id in aws_instance.instance : ec2id.id ]
}