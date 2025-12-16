variable "vpc_name" {
  description = "VPC의 이름 태그"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC의 CIDR 블록"
  type        = string
}

variable "public_subnet_cidr" {
  description = "Public Subnet의 CIDR"
  type        = string
}

variable "public_subnet_az" {
  description = "Public Subnet의 가용 영역 (예: ap-northeast-2a)"
  type        = string
}

variable "private_subnet_cidr" {
  description = "Private Subnet의 CIDR"
  type        = string
}

variable "private_subnet_az" {
  description = "Private Subnet의 가용 영역 (예: ap-northeast-2c)"
  type        = string
}
