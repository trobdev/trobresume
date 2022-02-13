# --- root/variables.tf ---
variable "aws_region" {
  default = "us-west-2"
}

variable "alias_region" {
    default = "us-east-1"
}

variable "domain_name" {
  type        = string
  description = "Website domain name"
}

variable "bucket_name" {
  type        = string
  description = "Name of bucket minus prefix"
}

variable "lambda_bucket_name" {
  type = string
  description = "Lambda bucket name"
}

variable "delegation_set_id" {
  type        = string
  description = "Delegation set ID for white-label R53 hosted zone"
}

variable "common_tags" {
  description = "Tags for ease of use"
}

variable "account_id" { 
  type = string
  description = "Account ID"
}