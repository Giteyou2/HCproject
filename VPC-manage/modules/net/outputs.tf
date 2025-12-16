output "vpc_id" {
  value = aws_vpc.this.id
}

output "public_subnet_id" {
  value = aws_subnet.public.id
}

output "private_subnet_id" {
  value = aws_subnet.private.id
}

# modules/standard_vpc/outputs.tf 에 추가
output "public_rt_id" {
  value = aws_route_table.public.id
}

output "private_rt_id" {
  value = aws_route_table.private.id
}
