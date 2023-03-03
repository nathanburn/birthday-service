resource "aws_dynamodb_table" "terraform_backend_lock" {
  name           = var.name
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "LockID"
  attribute {
    # primary key to be used to lock the state in dynamoDB
    name = "LockID"
    # "string" type
    type = "S"
  }
  tags = {
    "Name" = "DynamoDB Terraform State Lock Table"
  }
}
