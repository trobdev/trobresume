# --- apigw/main.tf ---
resource "aws_api_gateway_rest_api" "ResumeAPI" {
  name        = var.api_name
  description = "This API supports the Cloud Resume website"
}

resource "aws_api_gateway_resource" "ResumeAPIResource" {
  rest_api_id = aws_api_gateway_rest_api.ResumeAPI.id
  parent_id   = aws_api_gateway_rest_api.ResumeAPI.root_resource_id
  path_part   = "resume-api-resource"
}

resource "aws_api_gateway_method" "get_method" {
  rest_api_id   = aws_api_gateway_rest_api.ResumeAPI.id
  resource_id   = aws_api_gateway_resource.ResumeAPIResource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_api_integration" {
  rest_api_id             = aws_api_gateway_rest_api.ResumeAPI.id
  resource_id             = aws_api_gateway_resource.ResumeAPIResource.id
  http_method             = aws_api_gateway_method.get_method.http_method
  type                    = "AWS"
  integration_http_method = "GET"
  uri                     = var.function_arn
}
#DEMO INTEGRATION (MOCK)
resource "aws_api_gateway_integration" "MyDemoIntegration" {
  rest_api_id = aws_api_gateway_rest_api.ResumeAPI.id
  resource_id = aws_api_gateway_resource.ResumeAPIResource.id
  http_method = aws_api_gateway_method.get_method.http_method
  type        = "MOCK"
}

resource "aws_api_gateway_method_response" "response_200" {
  rest_api_id = aws_api_gateway_rest_api.ResumeAPI.id
  resource_id = aws_api_gateway_resource.ResumeAPIResource.id
  http_method = aws_api_gateway_method.get_method.http_method
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "MyDemoIntegrationResponse" {
  rest_api_id = aws_api_gateway_rest_api.ResumeAPI.id
  resource_id = aws_api_gateway_resource.ResumeAPIResource.id
  http_method = aws_api_gateway_method.get_method.http_method
  status_code = aws_api_gateway_method_response.response_200.status_code

  # Transforms the backend JSON response to XML
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
resource "aws_api_gateway_deployment" "resume_api_prod_deployment" {
  rest_api_id = aws_api_gateway_rest_api.ResumeAPI.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.ResumeAPIResource.id,
      aws_api_gateway_method.get_method.id,
      aws_api_gateway_integration.MyDemoIntegration.id #use mock for testing
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "prod_stage" {
  deployment_id = aws_api_gateway_deployment.resume_api_prod_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.ResumeAPI.id
  stage_name    = var.stage_name
}