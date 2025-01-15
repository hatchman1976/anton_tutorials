# NAT's need to be associated with an Elastic IP address so they can accept/transmit traffic
# from the internet. They need to exist in the public zones and have routes to the IGW
resource "aws_eip" "nat" {
    domain = "vpc"

    tags = {
        Name = "${local.env}-nat"
    }
}

resource "aws_nat_gateway" "nat" {
    allocation_id = aws_eip.nat.id
    subnet_id = aws_subnet.public_zone1.id

    tags = {
        Name = "${local.env}-nat"
    }

    depends_on = [ aws_internet_gateway.igw ]
}