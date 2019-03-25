terraform {
  required_version = ">= 0.11.6"
}

provider "aws" {
  profile = "test"
  region  = "ap-northeast-1"
}

data "aws_region" "current" {}
data "aws_availability_zones" "available" {}

module "aws_vpc" {
  source = "../modules/vpc"

  aws_vpc_cidr = "${var.aws_vpc_cidr}"
  aws_az = "${slice(data.aws_availability_zones.available.names,0,3)}"
  aws_subnet_lb_cidr = "${var.aws_subnet_lb_cidr}"
  aws_subnet_eks_cidr = "${var.aws_subnet_eks_cidr}"
}

module "aws_vpc_securitygroup" {
  source = "../modules/vpc-securitygroup"

  aws_vpc_id = "${module.aws_vpc.aws_vpc_id}"
  aws_subnet_ids_eks = "${module.aws_vpc.aws_subnet_ids_eks}"
  aws_eks_cluster_name = "${var.aws_eks_cluster_name}"
}

module "aws_iam" {
  source = "../modules/iam"

  aws_eks_cluster_name = "${var.aws_eks_cluster_name}"
}
