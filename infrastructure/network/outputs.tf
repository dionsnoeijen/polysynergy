output "vpc_id" {
  value = aws_vpc.main.id
}

output "subnet1_id" {
  value = aws_subnet.subnet1.id
}

output "subnet2_id" {
  value = aws_subnet.subnet2.id
}

output "igw_id" {
  value = aws_internet_gateway.igw.id
}

output "public_rt_id" {
  value = aws_route_table.public_rt.id
}