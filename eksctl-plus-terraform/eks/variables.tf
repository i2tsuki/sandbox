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

variable "aws_eks_cluster_name" {
  description = "AWS EKS Cluster Name"
  type = "string"
}

variable "cluster_yaml_file" {
  description = "Where to store the generated cluster yaml file"
  type = "string"
}
