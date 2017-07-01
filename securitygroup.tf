# Creating security group for primary vpc public subnet 
resource "aws_security_group" "primary-sg-public" {
  vpc_id      = "${aws_vpc.primary-vpc.id}"
  name        = "primary-sg-public"
  description = "security group that allows ssh and all egress traffic"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#Creating security group for Primary vpc private subnet
resource "aws_security_group" "primary-sg-private" {
  vpc_id      = "${aws_vpc.primary-vpc.id}"
  name        = "primary-sg-private"
  description = "security group that allows ssh and all egress traffic"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = ["${aws_security_group.primary-sg-public.id}"]
  }

  ingress {
    from_port       = 8
    to_port         = -1
    protocol        = "icmp"
    security_groups = ["${aws_security_group.primary-sg-public.id}"]
  }
}

# Creating security group for secondary vpc public subnet 
resource "aws_security_group" "secondary-sg-public" {
  vpc_id      = "${aws_vpc.secondary-vpc.id}"
  name        = "secondary-sg-public"
  description = "security group that allows ssh and all egress traffic"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

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
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Creating security group for secondary vpc private subnet
resource "aws_security_group" "secondary-sg-private" {
  vpc_id      = "${aws_vpc.secondary-vpc.id}"
  name        = "secondary-sg-private"
  description = "security group that allows ssh and all egress traffic"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = ["${aws_security_group.secondary-sg-public.id}"]
  }

  ingress {
    from_port       = 8
    to_port         = -1
    protocol        = "icmp"
    security_groups = ["${aws_security_group.secondary-sg-public.id}"]
  }
}

# Creating security group for staging security group
resource "aws_security_group" "staging-security-group" {
  vpc_id      = "${aws_vpc.secondary-vpc.id}"
  name        = "staging security group"
  description = "security group that allows all egress and ssh,80,443 on egress"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "staging-ingress-ssh" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.staging-security-group.id}"
  source_security_group_id = "${aws_security_group.secondary-sg-public.id}"
}

resource "aws_security_group_rule" "staging-ingress-http" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.staging-security-group.id}"
  source_security_group_id = "${aws_security_group.secondary-sg-public.id}"
}

resource "aws_security_group_rule" "staging-ingress-https" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.staging-security-group.id}"
  source_security_group_id = "${aws_security_group.secondary-sg-public.id}"
}

# Creating security group for database security group
resource "aws_security_group" "database-security-group" {
  vpc_id      = "${aws_vpc.secondary-vpc.id}"
  name        = "database-security-group"
  description = "security group that allows ssh and all egress traffic"
}

resource "aws_security_group_rule" "mysql-ingress" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.database-security-group.id}"
  source_security_group_id = "${aws_security_group.secondary-sg-public.id}"
}

resource "aws_security_group" "openvpn-sg" {
  vpc_id      = "${aws_vpc.secondary-vpc.id}"
  name        = "openvpn-sg"
  description = "security group for opnevpn"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 943
    to_port     = 943
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
    from_port   = 1194
    to_port     = 1194
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "openvpn-elb-sg" {
  vpc_id      = "${aws_vpc.secondary-vpc.id}"
  name        = "openvpn-elb-sg"
  description = "security group for openvpn-elb"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
