# ECR Variables
variable "image-name" {
  default = "infisical"
  type    = string
}

variable "image-mutability" {
  default = "IMMUTABLE"
  type    = string
}

# S3 Variables
variable "bucket-name" {
  default = "infisical-eks-backend"
  type    = string
}

variable "bucket-name-tag" {
  default = "infisical-eks-s3-bucket"
  type    = string
}

variable "object_ownership" {
  default = "BucketOwnerEnforced"
  type    = string
}

variable "versioning_configuration" {
  default = "Enabled"
  type    = string
}

variable "sse_algorithm" {
  default = "AES256"
  type    = string
}