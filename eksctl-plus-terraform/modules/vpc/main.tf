resource "aws_vpc" "vpc" {
  cidr_block       = "${var.aws_vpc_cidr}"
  instance_tenancy = "default"
  enable_dns_support = true
  enable_dns_hostnames = true
  enable_classiclink = false
  enable_classiclink_dns_support = false
  assign_generated_ipv6_cidr_block = false

  tags = "${merge(local.default_tags, map("Name", "vpc"))}"
}

resource "aws_vpc_dhcp_options" "vpc" {
  domain_name_servers  = ["10.0.0.2", "169.254.169.253"]
  ntp_servers          = ["169.254.169.123"]

  tags = "${merge(local.default_tags, map("Name", "vpc"))}"
}

resource "aws_vpc_dhcp_options_association" "vpc" {
  vpc_id          = "${aws_vpc.vpc.id}"
  dhcp_options_id = "${aws_vpc_dhcp_options.vpc.id}"
}

resource "aws_internet_gateway" "vpc" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags = "${merge(local.default_tags, map("Name", "main"))}"
}

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.vpc.id}"
  }

  tags = "${merge(local.default_tags, map("Name", "route_table_public"))}"
}

resource "aws_subnet" "lb" {
  count = "${length(var.aws_az)}"
  availability_zone = "${element(var.aws_az, count.index)}"
  cidr_block = "${element(var.aws_subnet_lb_cidr, count.index)}"
  map_public_ip_on_launch = false
  assign_ipv6_address_on_creation = false
  vpc_id     = "${aws_vpc.vpc.id}"

  tags = "${merge(local.default_tags, map("Name", "lb"))}"
}

resource "aws_subnet" "eks" {
  count = "${length(var.aws_az)}"
  availability_zone = "${element(var.aws_az, count.index)}"
  cidr_block = "${element(var.aws_subnet_eks_cidr, count.index)}"
  map_public_ip_on_launch = false
  assign_ipv6_address_on_creation = false
  vpc_id     = "${aws_vpc.vpc.id}"

  tags = "${merge(local.default_tags, map("Name", "eks"))}"
}

resource "aws_route_table_association" "lb" {
  count = "${length(var.aws_az)}"
  subnet_id      = "${element(aws_subnet.lb.*.id, count.index)}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_route_table_association" "eks" {
  count = "${length(var.aws_az)}"
  subnet_id      = "${element(aws_subnet.eks.*.id, count.index)}"
  route_table_id = "${aws_route_table.public.id}"
}
