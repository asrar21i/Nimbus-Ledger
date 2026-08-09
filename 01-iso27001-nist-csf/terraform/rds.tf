resource "aws_db_instance" "main" {
  storage_encrypted  = true
  publicly_accessible = false

  tags = {
    Owner              = "Database Administrator"
    DataClassification = "Confidential"
  }
}