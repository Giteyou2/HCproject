variable "vpc_name" {
  description = "VPC의 이름 태그"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC의 CIDR 블록"
  type        = string
}

# Public Subnet (기존 유지)
variable "public_subnet_cidr" {
  description = "Public Subnet의 CIDR"
  type        = string
}

variable "public_subnet_az" {
  description = "Public Subnet의 가용 영역 (예: ap-northeast-2a)"
  type        = string
}

# Private Subnets (2개, EKS 필요조건)
variable "private_subnet_cidr_a" {
  description = "Private Subnet CIDR (AZ-a)"
  type        = string
}

variable "private_subnet_az_a" {
  description = "Private Subnet 가용 영역 (AZ-a)"
  type        = string
}

variable "private_subnet_cidr_c" {
  description = "Private Subnet CIDR (AZ-c)"
  type        = string
}

variable "private_subnet_az_c" {
  description = "Private Subnet 가용 영역 (AZ-c)"
  type        = string
}

# WAF 변수
variable "name" {
  description = "WAF Web ACL Name"
  type        = string
  default     = "basic-waf" # 기본값 설정
}

variable "description" {
  description = "WAF Description"
  type        = string
  default     = "WAF for application protection"
}
