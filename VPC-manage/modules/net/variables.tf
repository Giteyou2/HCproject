########################################
# VPC 기본 설정
########################################

variable "vpc_name" {
  description = "VPC의 이름 태그"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC의 CIDR 블록"
  type        = string
}

########################################
# Public Subnet 설정 (기존 유지)
########################################

variable "public_subnet_cidr" {
  description = "Public Subnet의 CIDR"
  type        = string
}

variable "public_subnet_az" {
  description = "Public Subnet의 가용 영역 (예: ap-northeast-2a)"
  type        = string
}

########################################
# Private Subnet 설정 (🔥 수정됨)
# EKS 요구사항 충족을 위해
# 서로 다른 AZ에 Private Subnet 2개 사용
########################################

variable "private_subnet_cidr_a" {
  description = "Private Subnet CIDR (AZ-a)"
  type        = string
}

variable "private_subnet_az_a" {
  description = "Private Subnet 가용 영역 (예: ap-northeast-2a)"
  type        = string
}

variable "private_subnet_cidr_c" {
  description = "Private Subnet CIDR (AZ-c)"
  type        = string
}

variable "private_subnet_az_c" {
  description = "Private Subnet 가용 영역 (예: ap-northeast-2c)"
  type        = string
}
