# Create VPC
resource "aws_vpc" "default" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = false

  tags {
    Name          = "MyVPC2"
    Resource      = "VPC"
    ResourceGroup = "BasicRG"
    Environment   = "Lab"
  }
}

# Create public subnet
resource "aws_subnet" "tier1-sub" {
  vpc_id                  = "${aws_vpc.default.id}"
  availability_zone       = "us-east-1a"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags {
    Name          = "basic-10.0.1.0-us-east-1a"
    Resource      = "Subnet"
    ResourceGroup = "BasicRG"
    Environment   = "Lab"
  }
}

# Create private subnet

resource "aws_subnet" "tier2-sub" {
  vpc_id            = "${aws_vpc.default.id}"
  availability_zone = "us-east-1b"
  cidr_block        = "10.0.2.0/24"

  tags {
    Name          = "basic-10.0.2.0-us-east-1b"
    Resource      = "Subnet"
    ResourceGroup = "BasicRG"
    Environment   = "Lab"
  }
}

# Create IGW for public subnet
resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.default.id}"

  tags {
    Name          = "MyIGW2"
    Resource      = "IGW"
    ResourceGroup = "BasicRG"
    Environment   = "Lab"
  }
}

# Create Route table for public subnet
resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.default.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.default.id}"
  }

  tags {
    Name        = "MyPublicRoute2"
    Environment = "Lab"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = "${aws_subnet.tier1-sub.id}"
  route_table_id = "${aws_route_table.public.id}"
}

# Create NAT Gateway for private subnet
resource "aws_nat_gateway" "ngw" {
  allocation_id = "${aws_eip.nat.id}"
  subnet_id     = "${aws_subnet.tier1-sub.id}"
  depends_on    = ["aws_internet_gateway.default"]
}

resource "aws_eip" "nat" {
  vpc = true
}

# Create Route table for private subnet
resource "aws_route_table" "private" {
  vpc_id = "${aws_vpc.default.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_nat_gateway.ngw.id}"
  }

  tags {
    Environment = "Lab"
  }
}

resource "aws_route_table_association" "private" {
  subnet_id      = "${aws_subnet.tier2-sub.id}"
  route_table_id = "${aws_route_table.private.id}"
}

# Create NACL for public subnet
resource "aws_network_acl" "tier1-sub" {
  vpc_id     = "${aws_vpc.default.id}"
  subnet_ids = ["${aws_subnet.tier1-sub.id}"]

  tags {
    Name          = "nacl-tier1-sub"
    Resource      = "Subnet"
    ResourceGroup = "BasicRG"
    Environment   = "Lab"
  }
}

resource "aws_network_acl_rule" "http-in" {
  network_acl_id = "${aws_network_acl.tier1-sub.id}"
  rule_number    = 100
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 80
  to_port        = 80
}

resource "aws_network_acl_rule" "https-in" {
  network_acl_id = "${aws_network_acl.tier1-sub.id}"
  rule_number    = 200
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 443
  to_port        = 443
}

resource "aws_network_acl_rule" "ssh-in" {
  network_acl_id = "${aws_network_acl.tier1-sub.id}"
  rule_number    = 300
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 22
  to_port        = 22
}

resource "aws_network_acl_rule" "custom_tcp-in" {
  network_acl_id = "${aws_network_acl.tier1-sub.id}"
  rule_number    = 400
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 65535
}

resource "aws_network_acl_rule" "http-out" {
  network_acl_id = "${aws_network_acl.tier1-sub.id}"
  rule_number    = 100
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 80
  to_port        = 80
}

resource "aws_network_acl_rule" "https-out" {
  network_acl_id = "${aws_network_acl.tier1-sub.id}"
  rule_number    = 200
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 443
  to_port        = 443
}

resource "aws_network_acl_rule" "ssh-out" {
  network_acl_id = "${aws_network_acl.tier1-sub.id}"
  rule_number    = 300
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 22
  to_port        = 22
}

resource "aws_network_acl_rule" "custom_tcp-out" {
  network_acl_id = "${aws_network_acl.tier1-sub.id}"
  rule_number    = 400
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 65535
}

# Create SG for webDMZ
resource "aws_security_group" "web" {
  name        = "web-tier1-sg"
  description = "Security group for web that allows web traffic from internet"
  vpc_id      = "${aws_vpc.default.id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.0/24"]
  }

  # outbound  access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name          = "web-tier1-sg"
    Resource      = "SG"
    ResourceGroup = "BasicRG"
    Environment   = "Lab"
  }
}

# Create SG for Bastion host
resource "aws_security_group" "bastion" {
  name        = "bastion-tier1-sg"
  description = "Security group for bastion host"
  vpc_id      = "${aws_vpc.default.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound  access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name          = "bastion-tier1-sg"
    Resource      = "SG"
    ResourceGroup = "BasicRG"
    Environment   = "Lab"
  }
}

# Create SG for DB servers
resource "aws_security_group" "db" {
  name        = "db-tier2-sg"
  description = "Security group for bastion host"
  vpc_id      = "${aws_vpc.default.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound  access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name          = "db-tier2-sg"
    Resource      = "SG"
    ResourceGroup = "BasicRG"
    Environment   = "Lab"
  }
}

# Create internet facing lb for public subnet
resource "aws_elb" "web" {
  name = "myvpc2-tier1-elb"

  subnets         = ["${aws_subnet.tier1-sub.id}"]
  security_groups = ["${aws_security_group.web.id}"]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  instances = ["${aws_instance.web.*.id}"]

  health_check {
    healthy_threshold   = 10
    unhealthy_threshold = 2
    timeout             = 5
    target              = "HTTP:80/index.html"
    interval            = 30
  }

  tags {
    Name          = "myvpc2-tier1-elb"
    Resource      = "ELB"
    ResourceGroup = "BasicRG"
    Environment   = "Lab"
  }
}

# Create instances
resource "aws_instance" "web" {
  count                  = "1"
  ami                    = "ami-0b33d91d"                   # Amazon Linux AMI 2016.09.1 (HVM), SSD Volume Type - ami-0b33d91d
  instance_type          = "t2.micro"
  vpc_security_group_ids = ["${aws_security_group.web.id}"]

  subnet_id         = "${aws_subnet.tier1-sub.id}"
  source_dest_check = true
  key_name          = "${var.aws_key_name}"

  user_data = "${file("install-web.sh")}"

  tags = {
    Name          = "web-vm${count.index + 1}"
    Resource      = "Instance"
    ResourceGroup = "BasicRG"
    Environment   = "Lab"
  }
}
