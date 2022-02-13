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
output "function_arn" {
  value = module.lambda.function_arn
}
output "lambda_bucket" {
  value = module.storage.lambda_bucket
}
output "apigw_resource" {
  value = module.apigw.apigw_resource
}
output "apigw_method" {
  value = module.apigw.apigw_method
}
output "apigw_rest_api" {
  value = module.apigw.apigw_rest_api
}