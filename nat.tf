#nat gw
resource "aws_eip" "nat-1" {
  vpc = true
}

resource "aws_nat_gateway" "primary-nat-gw" {
  allocation_id = "${aws_eip.nat-1.id}"
  subnet_id     = "${aws_subnet.primary-public-1.id}"
  depends_on    = ["aws_internet_gateway.primary-vpc-igw"]
}

#nat gw
resource "aws_eip" "nat-2" {
  vpc = true
}

resource "aws_nat_gateway" "secondary-nat-gw" {
  allocation_id = "${aws_eip.nat-2.id}"
  subnet_id     = "${aws_subnet.secondary-public-1.id}"
  depends_on    = ["aws_internet_gateway.secondary-vpc-igw"]
}
