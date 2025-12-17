
############################
# EKS Cluster
############################
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = var.kubernetes_version

  vpc_id  = var.vpc_id
  subnet_ids = var.private_subnet_ids
  # 🔧 public subnet 사용 시 퍼블릭 노드 가능

  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true
  
  enable_irsa = true
  # 🔧 IAM Role for Service Account (보안 권장)

  eks_managed_node_groups = {
    default = {
      instance_types = [var.node_instance_type]

      desired_size = var.node_desired_size
      min_size     = var.node_min_size
      max_size     = var.node_max_size

      capacity_type = "ON_DEMAND"
      # 🔧 SPOT으로 변경 가능
    }
  }

  cluster_enabled_log_types = [
    "api",
    "audit",
    "authenticator"
    # 🔧 CloudWatch 로그 (비용 발생)
  ]

  tags = {
    Project = "Hybrid-Cloud"
    Owner   = "HCproject"
  }
}

############################
# ECR Repository
############################
resource "aws_ecr_repository" "app" {
  name = "hybrid-cloud-app"
  # 🔧 내부 이미지 / CI 결과물 저장용

  image_scanning_configuration {
    scan_on_push = true
  }

  force_delete = true
}
