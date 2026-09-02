resource "aws_instance" "app_server" {
  ami           = "ami-0c55b159cbfafe1f0" # Amazon Linux 2 AMI placeholder
  instance_type = "t3.micro"

  tags = {
    Owner              = "SecOps"
    DataClassification = "Restricted"
  }
}