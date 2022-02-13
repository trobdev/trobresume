# --- lambda/outputs.tf ---
output "function_arn" {
  value = aws_lambda_function.lambda.invoke_arn
}