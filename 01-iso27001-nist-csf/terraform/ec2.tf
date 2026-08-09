resource "aws_instance" "app_server" {
  tags = {
    Name               = "nimbus-app-server"
    Owner              = "bob"
    DataClassification = "Confidential"
    Environment        = var.environment
  }
}