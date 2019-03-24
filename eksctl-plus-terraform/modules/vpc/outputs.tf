output "aws_vpc_id" {
    value = "${aws_vpc.vpc.id}"
}

output "aws_subnet_ids_eks" {
    value = ["${aws_subnet.eks.*.id}"]
}

output "aws_subnet_ids_lb" {
    value = ["${aws_subnet.lb.*.id}"]
}
