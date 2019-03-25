---
apiVersion: eksctl.io/v1alpha4
kind: ClusterConfig

metadata:
  name: ${eks_cluster_name}
  region: ${region}
  version: "${version}"

iam:
  serviceRoleARN: ${iam_service_role_arn}

vpc:
  network:
    id: ${vpc_id}
  subnets:
    private:
${subnets_private}
    public:
${subnets_public}
  securityGroup: ${security_group}
  sharedNodeSecurityGroup: ${shared_node_security_group}
nodeGroups:
${nodegroups}
