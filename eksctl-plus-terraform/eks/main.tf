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

data "template_file" "subnet_private" {
  template = "${file("${path.module}/../templates/cluster-subnet.tpl")}"
  count = "${length(slice(data.aws_availability_zones.available.names,0,3))}"
  vars {
    availability_zones = "${element(slice(data.aws_availability_zones.available.names,0,3), count.index)}"
    subnet_ids = "${element(module.aws_vpc.aws_subnet_ids_eks, count.index)}"
    subnet_cidrs = "${element(var.aws_subnet_eks_cidr, count.index)}"
  }
}

data "template_file" "subnet_public" {
  template = "${file("${path.module}/../templates/cluster-subnet.tpl")}"
  count = "${length(slice(data.aws_availability_zones.available.names,0,3))}"
  vars {
    availability_zones = "${element(slice(data.aws_availability_zones.available.names,0,3), count.index)}"
    subnet_ids = "${element(module.aws_vpc.aws_subnet_ids_lb, count.index)}"
    subnet_cidrs = "${element(var.aws_subnet_lb_cidr, count.index)}"
  }
}

data "template_file" "nodegroup" {
  template = "${file("${path.module}/../templates/cluster-nodegroup.tpl")}"
  vars {
    name = "ng-worker"
    instance_type = "t3.medium"
    private_networking = "false"
    security_groups = "${module.aws_vpc_securitygroup.eks_node_sg_id}"
    min_size = 1
    max_size = 1
    role = "worker"
    instance_profile_arn = "${module.aws_iam.node_group_aws_instance_profile_arn}"
  }
}

data "template_file" "cluster" {
  template = "${file("${path.module}/../templates/cluster.yaml.tpl")}"

  vars {
    eks_cluster_name = "${var.aws_eks_cluster_name}"
    region           = "${data.aws_region.current.name}"
    version          = "1.10"

    iam_service_role_arn = "${module.aws_iam.aws_eks_service_role_arn}"

    vpc_id = "${module.aws_vpc.aws_vpc_id}"
    subnets_private = "${join("\n", data.template_file.subnet_private.*.rendered)}"
    subnets_public  = "${join("\n", data.template_file.subnet_public.*.rendered)}"
    security_group = "${module.aws_vpc_securitygroup.eks_control_plane_sg_id}"
    shared_node_security_group = "${module.aws_vpc_securitygroup.eks_node_sg_id}"
    nodegroups  = "${join("\n", data.template_file.nodegroup.*.rendered)}"
  }
}

resource "null_resource" "cluster" {
  provisioner "local-exec" {
      command = "echo '${data.template_file.cluster.rendered}' > ${var.cluster_yaml_file}"
  }
  triggers {
      template = "${data.template_file.cluster.rendered}"
  }
}
