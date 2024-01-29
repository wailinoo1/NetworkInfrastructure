output "subnetid" {
  value = [for id in aws_route_table_association.privateassociation : id.subnet_id]

}

output "vpcid" {
  value = aws_vpc.main.id
}