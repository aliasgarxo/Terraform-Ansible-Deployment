resource "tls_private_key" "pri-terra-key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "terra-keypair" {
  key_name   = "terra-keypair"
  public_key = tls_private_key.pri-terra-key.public_key_openssh
}

resource "local_file" "private_key_pem" {
  content = tls_private_key.pri-terra-key.private_key_pem
  filename = "${path.module}/terra-keypair.pem"
}

# resource "aws_s3_bucket" "dull-bucket" {
#   bucket = "infra-bucket-storage" 
#   tags = {
#     Name        = "infra-bucket-storage"
#     Environment = "Dev"
#   }             
# }

# resource "aws_s3_object" "object" {
#   bucket = aws_s3_bucket.dull-bucket.id
#   key    = "terra-keypair.pem"
#   source = "${path.module}/terra-keypair.pem"
#   etag = filemd5("${path.module}/terra-keypair.pem")
# }