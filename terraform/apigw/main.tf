# --- apigw/main.tf ---
resource "aws_api_gateway_rest_api" "ResumeAPI" {
  name        = var.api_name
  description = "This API supports the Cloud Resume website"
}

resource "aws_api_gateway_resource" "ResumeAPIResource" {
  rest_api_id = aws_api_gateway_rest_api.ResumeAPI.id
  parent_id   = aws_api_gateway_rest_api.ResumeAPI.root_resource_id
  path_part   = "views"
}

resource "aws_api_gateway_method" "get_method" {
  rest_api_id      = aws_api_gateway_rest_api.ResumeAPI.id
  resource_id      = aws_api_gateway_resource.ResumeAPIResource.id
  http_method      = "GET"
  authorization    = "NONE"
  api_key_required = false
}

resource "aws_api_gateway_method" "options_method" {
  rest_api_id      = aws_api_gateway_rest_api.ResumeAPI.id
  resource_id      = aws_api_gateway_resource.ResumeAPIResource.id
  http_method      = "OPTIONS"
  authorization    = "NONE"
  api_key_required = false
}

resource "aws_api_gateway_method" "post_method" {
  rest_api_id      = aws_api_gateway_rest_api.ResumeAPI.id
  resource_id      = aws_api_gateway_resource.ResumeAPIResource.id
  http_method      = "POST"
  authorization    = "NONE"
  api_key_required = false
}

resource "aws_api_gateway_integration" "get_api_integration" {
  rest_api_id             = aws_api_gateway_rest_api.ResumeAPI.id
  resource_id             = aws_api_gateway_resource.ResumeAPIResource.id
  http_method             = aws_api_gateway_method.get_method.http_method
  type                    = "AWS"
  integration_http_method = "POST"
  uri                     = var.function_arn
}

resource "aws_api_gateway_integration" "post_api_integration" {
  rest_api_id             = aws_api_gateway_rest_api.ResumeAPI.id
  resource_id             = aws_api_gateway_resource.ResumeAPIResource.id
  http_method             = aws_api_gateway_method.post_method.http_method
  type                    = "AWS"
  integration_http_method = "POST"
  uri                     = var.function_arn
}

resource "aws_api_gateway_method_response" "get_method_response" {
  rest_api_id = aws_api_gateway_rest_api.ResumeAPI.id
  resource_id = aws_api_gateway_resource.ResumeAPIResource.id
  http_method = aws_api_gateway_method.get_method.http_method
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_method_response" "options_method_response" {
  rest_api_id = aws_api_gateway_rest_api.ResumeAPI.id
  resource_id = aws_api_gateway_resource.ResumeAPIResource.id
  http_method = aws_api_gateway_method.options_method.http_method
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration" "mock_api_integration" {
  rest_api_id          = aws_api_gateway_rest_api.ResumeAPI.id
  resource_id          = aws_api_gateway_resource.ResumeAPIResource.id
  http_method          = "OPTIONS"
  type                 = "MOCK"
  passthrough_behavior = "WHEN_NO_MATCH"
  request_templates = {
    "application/json" : "{\"statusCode\": 200}"
  }
}


resource "aws_api_gateway_integration_response" "lambda_api_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.ResumeAPI.id
  resource_id = aws_api_gateway_resource.ResumeAPIResource.id
  http_method = aws_api_gateway_method.get_method.http_method
  status_code = "200"
  depends_on  = [aws_api_gateway_integration.post_api_integration]
  response_templates = {
    "application/xml" = <<EOF
#set($inputRoot = $input.path('$'))
<?xml version="1.0" encoding="UTF-8"?>
<message>
    $inputRoot.body
</message>
EOF
  }
}

resource "aws_api_gateway_integration_response" "options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.ResumeAPI.id
  resource_id = aws_api_gateway_resource.ResumeAPIResource.id
  http_method = aws_api_gateway_method.options_method.http_method
  status_code = "200"
  # depends_on = [aws_api_gateway_integration.mock_api_integration]
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'POST,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
}

resource "aws_api_gateway_deployment" "resume_api_prod_deployment" {
  rest_api_id = aws_api_gateway_rest_api.ResumeAPI.id
  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.ResumeAPIResource.id,
      aws_api_gateway_method.get_method.id,
      aws_api_gateway_integration.post_api_integration.id
    ]))
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "prod_stage" {
  stage_name    = var.stage_name
  deployment_id = aws_api_gateway_deployment.resume_api_prod_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.ResumeAPI.id
}
