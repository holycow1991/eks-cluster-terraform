data "aws_vpc" "default" {
  default = true 
}

data "aws_subnets" "publicSubnets" {
  filter {
    name = "vpc-id"
    values = [ data.aws_vpc.default.id]
  }
}

###############
# EKS CLUSTER #
###############

resource "aws_eks_cluster" "playgroundCluster" {
  name     = "playgroundCluster"
  role_arn = aws_iam_role.clusterRole.arn

  vpc_config {
    subnet_ids = data.aws_subnets.publicSubnets.ids
  }


  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.playground-AmazonEKSClusterPolicy,
    # aws_iam_role_policy_attachment.example-AmazonEKSVPCResourceController,
  ]
}

###############
# NODE GROUP  #
###############
resource "aws_eks_node_group" "playgroundNodeGrp" {
  cluster_name    = aws_eks_cluster.playgroundCluster.name
  node_group_name = "playground-node-grp"
  node_role_arn   = aws_iam_role.nodeGroupRole.arn
  subnet_ids      = data.aws_subnets.publicSubnets.ids

  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }
  instance_types = [ "t2.micro" ]
  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.playground-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.playground-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.playground-AmazonEC2ContainerRegistryReadOnly,
  ]
}