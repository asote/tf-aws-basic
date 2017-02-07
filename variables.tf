variable "aws_key_name" {
  description = "MyKeyPair"
}

variable "count" {
  description = "Number of instances"
  default     = "1"
}

variable "AWS_DEFAULT_REGION" {
  description = "Default AWS region"
  default     = "us-east-1"
}
