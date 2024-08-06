# allocate elastic ip. this eip will be used for the nat-gateway in the public subnet az1 and az2
resource "aws_eip" "eip1" {
  domain = "vpc"
  tags = {
    Name = "${var.project_name}-${var.environment}-eip1"
  }
}

# # allocate elastic ip. this eip will be used for the nat-gateway in the public subnet az2
# resource "aws_eip" "eip2" {
#   domain = "vpc"
#   tags = {
#     Name = "${var.project_name}-${var.environment}-eip2"
#   }
# }

# create nat gateway in public subnet az1
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.eip1.id
  subnet_id     = aws_subnet.public_subnet_az1.id

  tags = {
    Name = "${var.project_name}-${var.environment}-ng-az1"
  }

  depends_on = [aws_internet_gateway.internet_gateway]
}

# # create nat gateway in public subnet az2
# resource "aws_nat_gateway" "nat_gateway_az2" {
#   allocation_id = aws_eip.eip2.id
#   subnet_id     = aws_subnet.public_subnet_az2.id

#   tags = {
#     Name = "${var.project_name}-${var.environment}-ng-az2"
#   }

#   depends_on = [aws_internet_gateway.internet_gateway]
# }

# create private route table az1 and add route through nat gateway
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-private-rt"
  }
}

# associate private app subnet az1 with private route table
resource "aws_route_table_association" "private_app_subnet_az1_rt_association" {
  subnet_id      = aws_subnet.private_subnet_az1.id
  route_table_id = aws_route_table.private_route_table.id
}

# create private route table az2 and add route through nat gateway
# resource "aws_route_table" "private_route_table_az2" {
#   vpc_id = aws_vpc.vpc.id

#   route {
#     cidr_block     = "0.0.0.0/0"
#     nat_gateway_id = aws_nat_gateway.nat_gateway_az1.id
#   }

#   tags = {
#     Name = "${var.project_name}-${var.environment}-private-rt-az2"
#   }
# }

# associate private app subnet az2 with private route table az2
resource "aws_route_table_association" "private_app_subnet_az2_rt_association" {
  subnet_id      = aws_subnet.private_subnet_az2.id
  route_table_id = aws_route_table.private_route_table.id
}