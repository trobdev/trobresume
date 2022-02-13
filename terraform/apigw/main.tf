# --- apigw/main.tf ---
resource "aws_api_gateway_rest_api" "ResumeAPI" {
    name = "ResumeAPI"
    description = "This API supports the Cloud Resume website"
}

resource "aws_api_gateway_resource" "ResumeAPIResource" {
    rest_api_id = aws_api_gateway_rest_api.ResumeAPI.id
    parent_id = aws_api_gateway_rest_api.ResumeAPI.root_resource_id
    path_part = "resume-api-resource"
}

resource "aws_api_gateway_method" "GetMethod" {
    rest_api_id = aws_api_gateway_rest_api.ResumeAPI.id
    resource_id = aws_api_gateway_resource.ResumeAPIResource.id
    http_method = "GET"
    authorization = "NONE"
}

resource "aws_api_gateway_stage" "prod-stage" {
    deployment_id = aws_api_gateway_deployment.resume-api-prod-deployment.id
    rest_api_id = aws_api_gateway_rest_api.ResumeAPI.id
    stage_name = var.stage_name
}
# resource "aws_api_gateway_integration" "lambda-api-integration" { 
#     rest_api_id = aws_api_gateway_rest_api.ResumeAPI.id
#     resource_id = aws_api_gateway_resource.ResumeAPIResource.id
#     type = "AWS"
#     integration_http_method = "GET"

# }

resource "aws_api_gateway_deployment" "resume-api-prod-deployment" {
    rest_api_id = aws_api_gateway_rest_api.ResumeAPI.id
    
    lifecycle { 
        create_before_destroy = true
    }
}