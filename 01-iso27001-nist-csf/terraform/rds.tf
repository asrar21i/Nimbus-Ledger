resource "aws_db_instance" "main" {

  engine                = "postgres"
  instance_class        = "db.t3.micro"
  allocated_storage     = 20
  password              = var.db_password
  storage_encrypted  = true
  publicly_accessible = false

  tags = {
    Owner              = "Database Administrator"
    DataClassification = "Confidential"
  }
}