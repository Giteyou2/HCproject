variable "aws_region" {
  description = "AWS region where EKS will be created"
  default     = "ap-northeast-2"
  # 🔧 AWS 리전 변경 가능
}

variable "cluster_name" {
  description = "EKS Cluster name"
  default     = "hybrid-cloud-projectEKS"
}

variable "kubernetes_version" {
  description = "Kubernetes version for EKS"
  default     = "1.34"
  # ⚠️ 중요:
  # EKS에서 공식 지원하는 버전만 사용 가능
  # apply 에러 발생 시 1.29 / 1.30 등으로 변경
}

variable "vpc_id" {
  description = "VPC ID from VPC terraform output"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for EKS worker nodes"
  type        = list(string)
}

variable "node_instance_type" {
  description = "EC2 instance type for worker nodes"
  default     = "t3.medium"
  # 🔧 노드 사양 조절 가능
}

variable "node_desired_size" {
  description = "Desired number of worker nodes"
  default     = 2
}

variable "node_min_size" {
  description = "Minimum number of worker nodes"
  default     = 1
}

variable "node_max_size" {
  description = "Maximum number of worker nodes"
  default     = 4
}
