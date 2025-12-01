# Generate a new SSH key
resource "tls_private_key" "pk" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create the Key Pair in AWS
resource "aws_key_pair" "kp" {
  key_name   = "careconnect-key"
  public_key = tls_private_key.pk.public_key_openssh
}

# Save the private key to a file locally
resource "local_file" "ssh_key" {
  filename = "${path.module}/careconnect-key.pem"
  content  = tls_private_key.pk.private_key_pem
  file_permission = "0400"
}
