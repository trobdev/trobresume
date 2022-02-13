# --- apigw/variables.tf ---
variable "api_name" {
  default = "ResumeAPI"
  type    = string
}

variable "stage_name" {
  default = "prod"
  type    = string
}

variable "account_id" {}
variable "function_arn" {}