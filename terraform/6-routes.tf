# Step 1 - define the route tables. These are relatively simple. The private routes 
# map to the NAT. The public map to the IGW
# Step 2 - Associate the route tables to the subnets. Private goes to private, public goes to public
resource "aws_route_table" "private" {
    vpc_id = aws_vpc.main.id

    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.nat.id
    }

    tags = {
        Name = "${local.env}-private"
    }

}
resource "aws_route_table" "public" {
    vpc_id = aws_vpc.main.id
    route {
        cidr_block = "0.0.0.0/0"
        egress_only_gateway_id = aws_internet_gateway.igw.id
    }
    tags = {
        Name = "${local.env}-public"
    }
}
resource "aws_route_table_association" "private_zone1" {
    subnet_id = aws_subnet.private_zone1.id
    route_table_id = aws_route_table.private.id
}
resource "aws_route_table_association" "private_zone2" {
    subnet_id = aws_subnet.private_zone2.id
    route_table_id = aws_route_table.private.id
}
resource "aws_route_table_association" "public_zone1" {
    subnet_id = aws_subnet.public_zone1.id
    route_table_id = aws_route_table.public.id
}
resource "aws_route_table_association" "public_zone2" {
    subnet_id = aws_subnet.public_zone2.id
    route_table_id = aws_route_table.public.id
}
