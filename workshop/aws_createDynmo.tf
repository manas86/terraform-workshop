resource "aws_dynamodb_table" "result-table" {
  name           = "result-table-${var.username}"
  billing_mode   = "PROVISIONED"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "ID"

  attribute {
    name = "ID"
    type = "S"
  }
}