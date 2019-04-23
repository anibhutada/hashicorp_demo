variable "region" {
  default = "us-east-1"
}
variable "function_name" {
  default = "hashicorp_demo_function"
}
variable "lambda_role" {
  default = "arn:aws:iam::677110755192:role/hashicorp_demo_function_iam_role"
}
