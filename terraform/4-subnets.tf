resource "aws_subnet" "private_zone1" {

    vpc_id                  = aws_vpc.main.id
    cidr_block              = "10.0.0.0/19"
    availability_zone       = local.zone1

    tags = {
        Name                                                    = "${local.env}-private-${local.zone1}"
        "kubernetes.io/role/internal-elb"                       = 1
        "kubernetes.io/cluster/${local.env}-${local.eks_name}"  = "owned"
    }
}

resource "aws_subnet" "private_zone2" {

    vpc_id                  = aws_vpc.main.id
    # 32 is used here because the last IP for private zone 1 will be 10.0.31.255
    # Ref: https://mxtoolbox.com/subnetcalculator.aspx
    cidr_block              = "10.0.32.0/19"
    availability_zone       = local.zone2

    tags = {
        Name                                                    = "${local.env}-private-${local.zone2}"
        "kubernetes.io/role/internal-elb"                       = 1
        "kubernetes.io/cluster/${local.env}-${local.eks_name}"  = "owned"
    }
}

resource "aws_subnet" "public_zone1" {
    vpc_id                  = aws_vpc.main.id
    # 64 is used here because the last IP for private zone 2 will be 10.0.63.255
    cidr_block              = "10.0.64.0/19"
    availability_zone       = local.zone1

    map_public_ip_on_launch = true

    tags = {
        Name                                                    = "${local.env}-public-${local.zone1}"
        "kubernetes.io/role/elb"                                = 1
        "kubernetes.io/cluster/${local.env}-${local.eks_name}"  = "owned"
    }
}

resource "aws_subnet" "public_zone2" {
    vpc_id                  = aws_vpc.main.id
    # 64 is used here because the last IP for public zone 1 will be 10.0.95.255
    cidr_block              = "10.0.96.0/19"
    availability_zone       = local.zone2

    map_public_ip_on_launch = true

        tags = {
        Name                                                    = "${local.env}-public-${local.zone2}"
        "kubernetes.io/role/elb"                                = 1
        "kubernetes.io/cluster/${local.env}-${local.eks_name}"  = "owned"
    }
}