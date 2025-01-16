resource "aws_iam_role" "nodes"{
    name = "${local.env}-${local.eks_name}-eks-nodes"

    assume_role_policy = <<POLICY
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Action": "sts:AssumeRole",
                "Principal": {
                    "Service": "ec2.amazonaws.com"
                }
            }
        ]
    }
    POLICY
}

# Worker nodes IAM policy so that all the EC2 instances can participate
resource "aws_iam_role_policy_attachment" "amazon_eks_worker_node_policy" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
    role = aws_iam_role.nodes.name
}

# This policy is needed to manage secondary IPs. Specifically, The Amazon VPC 
# CNI plugin for Kubernetes add-on is deployed on each Amazon EC2 node in your 
# Amazon EKS cluster. The add-on creates elastic network interfaces and attaches 
# them to your Amazon EC2 nodes. The add-on also assigns a private IPv4 or IPv6 
# address from your VPC to each Pod.
resource "aws_iam_role_policy_attachment" "amazon_eks_cni_policy" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
    role = aws_iam_role.nodes.name
}

# Needed so that you can pull the Docker images from the ECR registry for using 
# on the Nodes
resource "aws_iam_role_policy_attachment" "amazon_ec2_container_registry_read_only" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
    role = aws_iam_role.nodes.name
}

resource "aws_eks_node_group" "general" {
    cluster_name = aws_eks_cluster.eks.name
    version = local.eks_version
    node_group_name = "general"
    node_role_arn = aws_iam_role.nodes.arn

    subnet_ids = [
        aws_subnet.private_zone1.id,
        aws_subnet.private_zone2.id,
    ]

    capacity_type = "ON_DEMAND"
    instance_types = ["t3.large"]

    scaling_config {
      desired_size = 1
      max_size = 10
      min_size = 0
    }

    update_config {
      max_unavailable = 1
    }

    labels = {
      role = "general"
    }

    depends_on = [ 
        aws_iam_role_policy_attachment.amazon_ec2_container_registry_read_only,
        aws_iam_role_policy_attachment.amazon_eks_cni_policy,
        aws_iam_role_policy_attachment.amazon_eks_worker_node_policy
     ]  

    # Allow external changes without Terraform plan difference. These avoids destroying or
    # adding new items
     lifecycle {
       ignore_changes = [ scaling_config[0].desired_size ]
     }

}