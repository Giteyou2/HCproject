output "mng_vpc_id" {
  value = module.managing_vpc.vpc_id
}

output "svc_vpc_id" {
  value = module.service_vpc.vpc_id
}

# Managing VPC Route Tables
output "mng_public_rt_id" {
  value = module.managing_vpc.public_rt_id
}

output "mng_private_rt_id" {
  value = module.managing_vpc.private_rt_id
}

# Service VPC Route Tables
output "svc_public_rt_id" {
  value = module.service_vpc.public_rt_id
}

output "svc_private_rt_id" {
  value = module.service_vpc.private_rt_id
}
