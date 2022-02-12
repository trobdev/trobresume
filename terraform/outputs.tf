# --- root/outputs.tf ---
output "root_domain_name" {
  value = module.cloudfront.root_domain_name
}
output "root_hosted_zone_id" {
  value = module.cloudfront.root_hosted_zone_id
}
output "www_domain_name" {
  value = module.cloudfront.www_domain_name
}
output "www_hosted_zone_id" {
  value = module.cloudfront.www_hosted_zone_id
}
output "www_website_endpoint" {
  value = module.storage.www_website_endpoint
}
output "root_website_endpoint" {
  value = module.storage.root_website_endpoint
}