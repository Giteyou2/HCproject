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

output "web_server_sg_id" {
  description = "The ID of the Web Server Security Group created in this VPC."
  value       = aws_security_group.web_server_security_group.id
}

output "private_subnet_ids" {
  description = "List of private subnet IDs for EKS"
  value = [
    aws_subnet.private_a.id,
    aws_subnet.private_c.id
  ]
}

