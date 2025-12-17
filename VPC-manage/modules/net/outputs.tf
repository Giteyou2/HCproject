output "vpc_id" {
  value = aws_vpc.this.id
}

output "public_subnet_id" {
  value = aws_subnet.public.id
}

output "private_subnet_ids" {
  description = "List of private subnets IDs (for EKS)"
  value       = [
    aws_subnet.private_a.id,
    aws_subnet.private_c.id
  ]
}

output "public_rt_id" {
  value = aws_route_table.public.id
}

output "private_rt_id" {
  value = aws_route_table.private.id
}

