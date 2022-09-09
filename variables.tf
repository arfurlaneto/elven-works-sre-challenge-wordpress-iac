# Region used in AWS.
variable "region" {
  default =  "us-east-1"
}

# Name of key-pair that will be used in EC2. Must be an existing one.
variable "key_name" {
  default = "aws-terraform"
}

# Local path of your private key from key-pair above.
variable "private_key_path" {
  default = "~/aws-terraform.pem"
}

# Database user for RDS.
variable "db_user" {
  default = "admin"
}

# Database password for RDS.
variable "db_password" {
  default = "foobarbaz"
}
