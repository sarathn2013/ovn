# Creating ec2 instance and attaching it to public subnet of the primary vpc
# resource "aws_instance" "primary-vpc-public-instance" {
#  ami           = "${lookup(var.AMIS, var.region)}"
#  instance_type = "t2.micro"
#
#  subnet_id = "${aws_subnet.primary-public-1.id}"

#  vpc_security_group_ids = ["${aws_security_group.primary-sg-public.id}"]

#  key_name = "${aws_key_pair.mykeypair.key_name}"

#  tags {
#    Name = "primary-vpc-public-instance"
#  }
# }

# Creating ec2 instance and attaching it to private subnet of the primary vpc
# resource "aws_instance" "primary-vpc-private-instance" {
#  ami           = "${lookup(var.AMIS, var.region)}"
#  instance_type = "t2.micro"

#  subnet_id = "${aws_subnet.primary-private-1.id}"

#  vpc_security_group_ids = ["${aws_security_group.primary-sg-private.id}"]

#  associate_public_ip_address = false

#  key_name = "${aws_key_pair.mykeypair.key_name}"

#  tags {
#    Name = "primary-vpc-private-instance"
#  }
# }

# Creating VPN SERVER ec2 instance and attaching it to public subnet of the secondary vpc
resource "aws_instance" "VPN_Server" {
  ami           = "${lookup(var.AMIS, var.region)}"
  instance_type = "t2.micro"

  subnet_id = "${aws_subnet.secondary-public-1.id}"

  vpc_security_group_ids = ["${aws_security_group.secondary-sg-public.id}"]

  key_name = "${aws_key_pair.mykeypair.key_name}"

  tags {
    Name = "VPN server"
  }
}

# Creating staging server and attaching private subnet of the secondary vpc
# resource "aws_instance" "staging-server" {
#  ami           = "${lookup(var.AMIS, var.region)}"
#  instance_type = "t2.micro"


#  subnet_id = "${aws_subnet.secondary-private-1.id}"


#  vpc_security_group_ids = ["${aws_security_group.staging-security-group.id}"]


#  associate_public_ip_address = false


#  key_name = "${aws_key_pair.mykeypair.key_name}"


#  tags {
#    Name = "staging server"
#  }
# }


# Creating database server and attaching private subnet of the secondary vpc
# resource "aws_instance" "database-server" {
#  ami           = "${lookup(var.AMIS, var.region)}"
#  instance_type = "t2.micro"


#  subnet_id = "${aws_subnet.secondary-private-1.id}"


#  vpc_security_group_ids = ["${aws_security_group.database-security-group.id}"]


#  associate_public_ip_address = false


#  key_name = "${aws_key_pair.mykeypair.key_name}"


#  tags {
#    Name = "database-server"
#  }
# }

