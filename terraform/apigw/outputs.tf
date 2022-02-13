output "apigw_resource" {
    value = aws_api_gateway_resource.ResumeAPIResource.path
}
output "apigw_method" {
    value = aws_api_gateway_method.get_method.http_method
}
output "apigw_rest_api" {
    value = aws_api_gateway_rest_api.ResumeAPI.id
}