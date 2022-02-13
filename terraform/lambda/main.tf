# --- lambda/main.tf
data "archive_file" "lambda_get_views" {
    type = "zip"

    source_dir = "${path.module}/get-views"
    output_path = "${path.module}/get-views.zip"
}

resource "aws_s3_object" "lambda_get_views_function" {
    bucket = aws_s3_bucket.lambda_functions_bucket.id
    key = "get-views.zip"
    source = data.archive_file.lambda_get_views.output_path
    etag = filemd5(data.archive_file.lambda_get_views.output_path)
}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.function_name
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "arn:aws:execute-api:${var.aws_region}:${var.account_id}:${aws_api_gateway_rest_api.ResumeAPI.id}/*/${aws_api_gateway_method.get_method.http_method}${aws_api_gateway_resource.ResumeAPIResource.path}"
}

resource "aws_lambda_function" "lambda" {
  filename      = "lambda.zip"
  function_name = "GetViews"
  role          = aws_iam_role.role.arn
  handler       = "lambda.lambda_handler"
  runtime       = "python3.9"

  source_code_hash = filebase64sha256("lambda.zip")
}

# IAM
resource "aws_iam_role" "role" {
  name = "allow-lambda-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
}