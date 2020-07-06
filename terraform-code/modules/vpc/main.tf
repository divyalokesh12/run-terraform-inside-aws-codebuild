/*data "aws_availability_zones" "available" {
  state = "available"
}*/
resource "aws_vpc" "main" {
  #count      = "${length(var.vpc_cidr)}"
  #cidr_block = "${var.vpc_cidr[count.index]}"
   cidr_block = "${var.vpc_cidr}"
   tags = {
    Name = "Demo-VPC"
}
}

resource "aws_subnet" "private_sub" {
  vpc_id     = "${aws_vpc.main.id}"
  count      = "${length(var.private_subnet)}"
  cidr_block = "${var.private_subnet[count.index]}"
 # availability_zone = data.aws_availability_zones.available.names[0]
  depends_on = [
    aws_vpc.main,
  ]
  tags = {
   Name = "${format("%s-%s-pri%d", upper(var.env), upper(var.service), count.index)}"
}
}

resource "aws_subnet" "public_sub" {
  vpc_id     = "${aws_vpc.main.id}"
  count      = "${length(var.public_subnet)}"
  cidr_block = "${var.public_subnet[count.index]}"
  depends_on = [
    aws_vpc.main,
  ]
  tags = {
   Name = "${format("%s-%s-pub%d", upper(var.env), upper(var.service), count.index)}"
}
}

resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.main.id}"
  tags = {
    Name = "demo-igw"
  }
}

resource "aws_eip" "nat_eip" {
  vpc = true
  depends_on = [
    aws_internet_gateway.igw,
  ]
}

resource "aws_nat_gateway" "nat" {
  allocation_id = "${aws_eip.nat_eip.id}"
  subnet_id     = "${element(aws_subnet.public_sub.*.id, 0)}"

  tags = {
    Name = "gw NAT"
  }
}


resource "aws_route_table" "rtb_public" {
  vpc_id = "${aws_vpc.main.id}"

  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = "${aws_internet_gateway.igw.id}"
  }

  tags = {
    Name = "Public_route_table"
  }
}

resource "aws_route_table_association" "public" {
  count = "${length(var.public_subnet)}"

  subnet_id      = "${element(aws_subnet.public_sub.*.id, count.index)}"
  route_table_id = "${aws_route_table.rtb_public.id}"
  depends_on = [
    aws_subnet.public_sub,
  ]
}

resource "aws_route_table" "rtb_private" {
  vpc_id = "${aws_vpc.main.id}"

  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = "${aws_nat_gateway.nat.id}"
  }

  tags = {
    Name = "Private_route_table"
  }
}

resource "aws_route_table_association" "private" {
  count = "${length(var.private_subnet)}"

  subnet_id      = "${element(aws_subnet.private_sub.*.id, count.index)}"
  route_table_id = "${aws_route_table.rtb_private.id}"
  depends_on = [
    aws_subnet.private_sub,
  ]
}

output "vpc-out" {
  value = "${aws_vpc.main.id}"
  depends_on = [
    aws_vpc.main,
  ]
}


output "sub-out" {
  value = "1"
  depends_on = [
    aws_subnet.private_sub,
  ]
}

