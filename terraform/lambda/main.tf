# --- lambda/main.tf
data "archive_file" "lambda_get_views" {
  type = "zip"

  source_dir  = "lambda/lambda_code"
  output_path = "lambda/lambda_code.zip"
}

# resource "aws_s3_object" "lambda_get_views_function" {
#     bucket = var.lambda_bucket_name
#     key = "lambda_code.zip"
#     source = data.archive_file.lambda_get_views.output_path
#     etag = filemd5(data.archive_file.lambda_get_views.output_path)
# }

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.function_name
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "arn:aws:execute-api:${var.aws_region}:${var.account_id}:${var.apigw_rest_api}/*/${var.apigw_method}${var.apigw_resource}"
}

resource "aws_lambda_function" "lambda" {
  filename      = "lambda/lambda_code.zip"
  function_name = "GetViews"
  #s3_bucket = var.lambda_bucket_name
  role             = aws_iam_role.lambda-invoke-role.arn
  handler          = "getViews.lambda_handler"
  runtime          = "python3.9"
  source_code_hash = data.archive_file.lambda_get_views.output_base64sha256
}

# IAM
resource "aws_iam_role" "lambda-invoke-role" {
  name               = "lambda-invoke-role"
  assume_role_policy = file("templates/lambda-invoke-policy.json")
  #assume_role_policy = file("templates/lambda-invoke-policy.json")
}

resource "aws_iam_role_policy" "ddb-rw-policy" {
  name   = "ddb-rw-policy"
  role   = aws_iam_role.lambda-invoke-role.id
  policy = file("templates/ddb-policy.json")
}
# resource "aws_iam_role" "role" {
#   name = "allow-lambda-role"

#   assume_role_policy = file("templates/lambda-invoke-policy.json")
# }

# resource "aws_iam_policy" "lambdaInvoke" {
#   name = "lambdaInvoke"
#   path = "/"
#   description = "Lambda Invoke policy"
#   policy = jsonencode({
#     "Version": "2012-10-17",
#     "Statement": [
#       {
#         "Action": "sts:AssumeRole",
#         "Principal": {
#           "Service": "lambda.amazonaws.com"
#         },
#         "Effect": "Allow",
#         "Sid": ""
#       }
#     ]
#   })
# }