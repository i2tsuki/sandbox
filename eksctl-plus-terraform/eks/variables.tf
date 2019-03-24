variable "aws_vpc_cidr" {
  description = "CIDR Blocks for AWS VPC"
}

variable "aws_subnet_lb_cidr" {
  description = "CIDR Blocks for Load Balancer Public Subnet"
  type = "list"
}

variable "aws_subnet_eks_cidr" {
  description = "CIDR Blocks for EKS Public Subnet"
  type = "list"
}
