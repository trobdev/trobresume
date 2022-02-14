# --- ddb/main.tf ---

resource "aws_dynamodb_table" "ddb_table" {
  name           = var.ddb_table_name
  hash_key       = var.ddb_hash_key
  read_capacity  = 1
  write_capacity = 1
  # timeouts {
  #   create = 2
  #   update = 2
  # }
  attribute {
    name = var.ddb_hash_key
    type = "S"
  }
  # attribute {
  #   name = "visitor_url"
  #   type = "S"
  # }
  # attribute {
  #   name = "last_updated"
  #   type = "S"
  # }
  # attribute {
  #   name = "visitor_count"
  #   type = "N"
  # }
  lifecycle {
    ignore_changes = [
      read_capacity,
      write_capacity
    ]
  }
}

resource "aws_dynamodb_table_item" "ddb_item" {
  table_name = aws_dynamodb_table.ddb_table.id
  hash_key   = var.ddb_hash_key
  item       = <<ITEM
  {
    "${var.ddb_hash_key}" : {"S" : "test" },
    "one" : {"S": "https://www.trobresume.com"},
    "two" : {"S": "13 Feb 22"},
    "three" : {"N": "0"}
  }
  ITEM
}