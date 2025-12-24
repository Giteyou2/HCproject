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

# WAF ARN 출력 수정
output "waf_acl_arn" {
  # 리스트의 첫 번째 요소([0])를 가져오되, 만약 count가 0이라서 리스트가 비어있으면 null을 반환합니다.
  value       = length(aws_wafv2_web_acl.this) > 0 ? aws_wafv2_web_acl.this[0].arn : null
  description = "The ARN of the WAF Web ACL"
}