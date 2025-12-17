# =======================================================================
# 1. VPC 정의
# VPC 전체 네트워크 공간(CIDR)을 설정하는 기본 틀입니다.
# =======================================================================
resource "aws_vpc" "this" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"
  tags = { Name = var.vpc_name }
}

# =======================================================================
# 2. 서브넷 정의
# VPC 내에서 트래픽 성격에 따라 분리된 IP 대역(Subnet)을 정의합니다.
# =======================================================================

# Public Subnet: 외부 인터넷 통신이 가능하며, 로드밸런서나 NAT Gateway가 위치합니다.
resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.public_subnet_cidr
  availability_zone = var.public_subnet_az
  tags = { Name = "${var.vpc_name}-publicSN" }
}

# Private Subnet: 외부 인터넷 통신이 차단되며, DB, 애플리케이션 서버 등 중요 자원이 위치합니다.
# Private Subnet 1 (AZ-a)
resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnet_cidr_a
  availability_zone = var.private_subnet_az_a
  tags = { Name = "${var.vpc_name}-privateSN-a" }
}

# Private Subnet 2 (AZ-c)
resource "aws_subnet" "private_c" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnet_cidr_c
  availability_zone = var.private_subnet_az_c
  tags = { Name = "${var.vpc_name}-privateSN-c" }
}

# =======================================================================
# 3. 게이트웨이 정의
# VPC와 외부 인터넷을 연결하고 Private Subnet의 아웃바운드 통신을 가능하게 합니다.
# =======================================================================

# Internet Gateway (IGW): VPC가 인터넷과 직접 통신할 수 있도록 연결합니다.
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags = { Name = "${var.vpc_name}-IGW" }
}

# Elastic IP (EIP): NAT Gateway에 할당할 고정 공인 IP 주소를 생성합니다.
resource "aws_eip" "nat" {
  domain = "vpc"
  tags   = { Name = "${var.vpc_name}-NAT-EIP" }
}

# NAT Gateway: Private Subnet의 인스턴스가 인터넷으로 아웃바운드 통신(업데이트, 외부 API 호출 등)을 할 수 있도록 합니다.
resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id # NAT Gateway는 Public Subnet에 위치해야 합니다.
  tags          = { Name = "${var.vpc_name}-NATGW" }
  depends_on    = [aws_internet_gateway.this]
}

# =======================================================================
# 4. 라우팅 테이블 정의
# 서브넷을 통과하는 트래픽의 목적지(Next Hop)를 결정하는 규칙 세트입니다.
# =======================================================================

# Public Route Table: 0.0.0.0/0 트래픽을 IGW로 보내 인터넷 통신을 가능하게 합니다.
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }
  tags = { Name = "${var.vpc_name}-publicRT" }
}

# Private Route Table: 0.0.0.0/0 트래픽을 NAT Gateway로 보내 아웃바운드 통신만 허용합니다.
resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_c" {
  subnet_id      = aws_subnet.private_c.id
  route_table_id = aws_route_table.private.id
}


# =======================================================================
# 5. 라우팅 테이블 연결 (Association)
# 정의된 라우트 테이블을 해당 서브넷에 실제로 적용합니다.
# =======================================================================

# Public Subnet에 Public Route Table을 연결합니다.
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Private Subnet에 Private Route Table을 연결합니다.
resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

# =======================================================================
# 6. 보안 그룹 정의 (Web Server Security Group)
# 웹 서버에 필요한 HTTP, HTTPS, ICMP 트래픽을 허용합니다.
# =======================================================================
resource "aws_security_group" "web_server_security_group" {
  name        = "allow-HTTP-HTTPS-ICMP"
  description = "allow HTTP, HTTPS, ICMP"
  vpc_id      = aws_vpc.this.id 

  # --- 인바운드 규칙 (Ingress) ---

  # 1. HTTP (TCP 80) 허용
  ingress {
    description = "HTTP access from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # 2. HTTPS (TCP 443) 허용
  ingress {
    description = "HTTPS access from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # 3. ICMP 허용
  ingress {
    description = "ICMP (ping) access from anywhere"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # --- 아웃바운드 규칙 (Egress) ---
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
