provider "aws" {
  region = "ap-northeast-2"
}

# 0. 현재 내 AWS 계정 정보 가져오기 (Owner ID 자동 설정을 위함)
data "aws_caller_identity" "current" {}

# 1. Managing VPC 생성 (모듈 호출)
module "managing_vpc" {
  source = "./modules/net"

  vpc_name = "managing_vpc"
  vpc_cidr = "10.0.0.0/16"

  # Public Subnet
  public_subnet_cidr = "10.0.0.0/24"
  public_subnet_az   = "ap-northeast-2a"

  # Private Subnet A
  private_subnet_cidr_a = "10.0.10.0/24"
  private_subnet_az_a   = "ap-northeast-2a"

  # Private Subnet C
  private_subnet_cidr_c = "10.0.20.0/24"
  private_subnet_az_c   = "ap-northeast-2c"
}

# 2. Service VPC 생성 (모듈 호출)
module "service_vpc" {
  source = "./modules/net"

  vpc_name = "service_vpc"
  vpc_cidr = "10.10.0.0/16"

  # Public Subnet
  public_subnet_cidr = "10.10.0.0/24"
  public_subnet_az   = "ap-northeast-2a"

  # Private Subnet A (EKS용)
  private_subnet_cidr_a = "10.10.10.0/24"
  private_subnet_az_a   = "ap-northeast-2a"

  # Private Subnet C (EKS용)
  private_subnet_cidr_c = "10.10.20.0/24"
  private_subnet_az_c   = "ap-northeast-2c"
}

# main.tf (기존 코드 아래에 추가)

# ==========================================
# 3. VPC Peering Connection (Mng <-> Svc)
# ==========================================

resource "aws_vpc_peering_connection" "mng_svc_peering" {
  peer_owner_id = data.aws_caller_identity.current.account_id
  peer_vpc_id   = module.service_vpc.vpc_id   # 상대방(Accepter): Service VPC
  vpc_id        = module.managing_vpc.vpc_id  # 요청자(Requester): Managing VPC

  auto_accept   = true # CLI의 'accept' 명령어를 대신함 (같은 계정일 때 가능)

  tags = {
    Name = "mng-svc-peering"
  }
}

# ==========================================
# 4. Routing Rules for Peering
# ==========================================
# 피어링 연결 후, "상대방 VPC로 가는 트래픽은 피어링 연결을 타라"고 라우팅 테이블에 명시해야 합니다.

# [Managing VPC 쪽 설정] -> Service VPC(10.10.0.0/16)로 가는 길
resource "aws_route" "mng_to_svc_private" {
  route_table_id            = module.managing_vpc.private_rt_id # Managing의 Private RT
  destination_cidr_block    = "10.10.0.0/16"                    # Service VPC의 CIDR
  vpc_peering_connection_id = aws_vpc_peering_connection.mng_svc_peering.id
}

# (필요하다면 Public 서브넷에서도 접근 가능하게 추가)
resource "aws_route" "mng_to_svc_public" {
  route_table_id            = module.managing_vpc.public_rt_id
  destination_cidr_block    = "10.10.0.0/16"
  vpc_peering_connection_id = aws_vpc_peering_connection.mng_svc_peering.id
}


# [Service VPC 쪽 설정] -> Managing VPC(10.0.0.0/16)로 가는 길
resource "aws_route" "svc_to_mng_private" {
  route_table_id            = module.service_vpc.private_rt_id # Service의 Private RT
  destination_cidr_block    = "10.0.0.0/16"                    # Managing VPC의 CIDR
  vpc_peering_connection_id = aws_vpc_peering_connection.mng_svc_peering.id
}

# (필요하다면 Public 서브넷에서도 접근 가능하게 추가)
resource "aws_route" "svc_to_mng_public" {
  route_table_id            = module.service_vpc.public_rt_id
  destination_cidr_block    = "10.0.0.0/16"
  vpc_peering_connection_id = aws_vpc_peering_connection.mng_svc_peering.id
}

# ==========================================
# 5. EKS Cluster (Service VPC 기반)
# ==========================================
module "eks" {
  source = "./modules/eks"

  vpc_id             = module.service_vpc.vpc_id
  private_subnet_ids = module.service_vpc.private_subnet_ids

  cluster_name        = "hybrid-cloud-projectEKS"
  kubernetes_version = "1.34"

  node_instance_type = "t3.medium"
  node_desired_size  = 2
  node_min_size      = 1
  node_max_size      = 4
  admin_principal_arn = "arn:aws:iam::682540795004:user/projectuser"

}

# EKS가 서브넷을 LB 배치 대상으로 인식하도록 태그 추가
locals {
  eks_cluster_tag = "kubernetes.io/cluster/${module.eks.cluster_name}"
}

# Private subnets: internal load balancer 용
resource "aws_ec2_tag" "svc_private_subnet_cluster_tag" {
  count       = length(module.service_vpc.private_subnet_ids)
  resource_id = module.service_vpc.private_subnet_ids[count.index]
  key         = local.eks_cluster_tag
  value       = "shared"
}

resource "aws_ec2_tag" "svc_private_subnet_internal_elb_tag" {
  count       = length(module.service_vpc.private_subnet_ids)
  resource_id = module.service_vpc.private_subnet_ids[count.index]
  key         = "kubernetes.io/role/internal-elb"
  value       = "1"
}

# Public subnet: internet-facing LB 쓸 거면 public subnet에도 태그
resource "aws_ec2_tag" "svc_public_subnet_cluster_tag" {
  resource_id = module.service_vpc.public_subnet_id
  key         = local.eks_cluster_tag
  value       = "shared"
}

resource "aws_ec2_tag" "svc_public_subnet_elb_tag" {
  resource_id = module.service_vpc.public_subnet_id
  key         = "kubernetes.io/role/elb"
  value       = "1"
}

