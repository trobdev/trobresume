# --- ddb/main.tf ---
resource "aws_dynamodb_table" {
  name = "view-counter"
}