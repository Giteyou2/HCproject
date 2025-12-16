output "mng_vpc_id" {
  value = module.managing_vpc.vpc_id
}

output "svc_vpc_id" {
  value = module.service_vpc.vpc_id
}
