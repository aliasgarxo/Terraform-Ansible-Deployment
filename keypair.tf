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