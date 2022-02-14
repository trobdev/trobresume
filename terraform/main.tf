# --- root/main.tf ---

module "storage" {
  source      = "./storage"
  domain_name = var.domain_name
  bucket_name = var.bucket_name
  # lambda_bucket_name = var.lambda_bucket_name
  common_tags = var.common_tags
}

module "acm" {
  source      = "./acm"
  domain_name = var.domain_name
  common_tags = var.common_tags
}

module "cloudfront" {
  source                = "./cloudfront"
  bucket_name           = var.bucket_name
  domain_name           = var.domain_name
  common_tags           = var.common_tags
  root_website_endpoint = module.storage.root_website_endpoint
  www_website_endpoint  = module.storage.www_website_endpoint
  certificate_arn       = module.acm.certificate_arn
}

module "dns" {
  source              = "./dns"
  domain_name         = var.domain_name
  common_tags         = var.common_tags
  delegation_set_id   = var.delegation_set_id
  root_domain_name    = module.cloudfront.root_domain_name
  www_domain_name     = module.cloudfront.www_domain_name
  root_hosted_zone_id = module.cloudfront.root_hosted_zone_id
  www_hosted_zone_id  = module.cloudfront.www_hosted_zone_id
}

module "apigw" {
  source       = "./apigw"
  account_id   = var.account_id
  function_arn = module.lambda.function_arn
}

module "lambda" {
  source     = "./lambda"
  aws_region = var.aws_region
  account_id = var.account_id
  #lambda_bucket_name = module.storage.lambda_bucket
  apigw_resource = module.apigw.apigw_resource
  apigw_method   = module.apigw.apigw_method
  apigw_rest_api = module.apigw.apigw_rest_api
}

module "ddb" {
  source         = "./ddb"
  ddb_table_name = var.ddb_table_name
  ddb_hash_key   = var.ddb_hash_key
}