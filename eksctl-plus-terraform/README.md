## eksctl + Terraform

This code is written for provisioning EKS clusters by combining Terraform and eksctl.
Eksctl command is very useful for provisioning EKS clusters from scratch.
But there may be places where it can not be difficulties in combination with the existing VPC network.
Also, AWS CloudFormation is slow than terraform, to avoid it if possible.
Eksctl is only for use in provisioning EKS in this code.

### Usage
These Terraform templates create the `cluster.yaml` file needed for provisioning with eksctl.

Run terraform:

```sh
terraform init --var-file ./eks.tfvars ./eks
terraform apply --state="eks.tfstate" --var-file ./eks.tfvars ./eks
```

Terraform create `cluster.yaml`, eksctl read this yaml file and provision EKS cluster.

```sh
eksctl create cluster -f ./cluster.yaml
```

### Trouble Shooting
#### aws-iam-authenticator
Eksctl require aws-iam-authenticator to authenticate EKS cluster using kubernetes webhook with AWS IAM.

Download aws-iam-authenticator:
```sh
curl -O 'https://amazon-eks.s3-us-west-2.amazonaws.com/1.11.5/2018-12-06/bin/linux/amd64/aws-iam-authenticator'
```
