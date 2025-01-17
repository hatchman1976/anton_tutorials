resource "aws_iam_user" "developer" {
    name = "developer"
  
}

resource "aws_iam_policy" "developer_eks" {
    name = "AmazonEKSDeveloperPolicy"

policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "eks:DescribeCluster",
                "eks:ListClusters"
            ],
            "Resource": "*"
        }
    ]
}
POLICY
}

resource "aws_iam_user_policy_attachment" "developer_eks" {
    user = aws_iam_user.developer.name
    policy_arn = aws_iam_policy.developer_eks.arn
}

# My viewer is defined in this file: lessons/196/1-example/1-viewer-cluster-role-binding.yaml
# At this point it makes me wonder why we don't move the YAML files run with kubectl into 
# terraform
resource "aws_eks_access_entry" "developer" {
    cluster_name = aws_eks_cluster.eks.name
    principal_arn = aws_iam_user.developer.arn
    kubernetes_groups = ["my-viewer"]
}
