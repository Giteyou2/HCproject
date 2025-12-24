########################################
# 1. VPC 생성
########################################
resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = var.vpc_name
  }
}

########################################
# 2. Public Subnet (기존)
########################################
resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.public_subnet_cidr
  availability_zone = var.public_subnet_az
  tags = {
    Name = "${var.vpc_name}-publicSN"
  }
}

########################################
# 3. Private Subnets (2개)
########################################

# Private Subnet in AZ-a
resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnet_cidr_a
  availability_zone = var.private_subnet_az_a
  tags = {
    Name = "${var.vpc_name}-privateSN-a"
  }
}

# Private Subnet in AZ-c
resource "aws_subnet" "private_c" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnet_cidr_c
  availability_zone = var.private_subnet_az_c
  tags = {
    Name = "${var.vpc_name}-privateSN-c"
  }
}

########################################
# 4. Internet Gateway / NAT Gateway
########################################

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
}

resource "aws_eip" "nat" {
  domain = "vpc"
}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id
  depends_on    = [aws_internet_gateway.this]
}

########################################
# 5. Route Tables
########################################

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this.id
  }
}

########################################
# 6. Route Table Association
########################################

# Public
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Private A
resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private.id
}

# Private C
resource "aws_route_table_association" "private_c" {
  subnet_id      = aws_subnet.private_c.id
  route_table_id = aws_route_table.private.id
}

# WAF 생성
resource "aws_wafv2_web_acl" "this" {
  count       = var.vpc_name == "service_vpc" ? 1 : 0
  name        = var.name
  description = var.description
  scope       = "REGIONAL" # API Gateway, ALB는 REGIONAL 설정 필수

  default_action {
    allow {}
  }

  # AWS 관리형 규칙: Core Rule Set (CRS)
  rule {
    name     = "AWS-AWSManagedRulesCommonRuleSet"
    priority = 1

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.name}-common-rules"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = var.name
    sampled_requests_enabled   = true
  }
}
