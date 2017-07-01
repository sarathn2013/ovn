# Creating  AWS OpsWorks Stack
resource "aws_opsworks_stack" "test1" {
  name                          = "prototype"
  region                        = "us-east-2"
  configuration_manager_version = "12"
  default_os                    = "Ubuntu 16.04 LTS"
  manage_berkshelf              = true
  use_custom_cookbooks          = true

  default_ssh_key_name     = "${aws_key_pair.mykeypair.key_name}"
  manage_berkshelf         = true
  default_root_device_type = "ebs"

  provisioner "local-exec" {
    command = "aws opsworks register-elastic-ip --region ${var.region} --stack-id ${aws_opsworks_stack.test1.id} --elastic-ip  ${aws_eip.one.public_ip}; aws opsworks register-elastic-ip --region ${var.region} --stack-id ${aws_opsworks_stack.test1.id} --elastic-ip  ${aws_eip.two.public_ip}"
  }

  custom_cookbooks_source {
    type     = "s3"
    url      = "https://s3.us-east-2.amazonaws.com/opsworkssample/cookbooks-open.tar.gz"
    username = "${var.access_key}"
    password = "${var.secret_key}"
  }

  service_role_arn             = "arn:aws:iam::963984212387:role/aws-opsworks-service-role"
  default_instance_profile_arn = "arn:aws:iam::963984212387:instance-profile/aws-opsworks-ec2-role"

  vpc_id                       = "${aws_vpc.secondary-vpc.id}"
  default_subnet_id            = "${aws_subnet.secondary-private-1.id}"
  use_opsworks_security_groups = false
}

# Creating layer for vpn servers
resource "aws_opsworks_custom_layer" "openvpn" {
  name                      = "openvpn"
  short_name                = "openvpn"
  elastic_load_balancer     = "${aws_elb.openvpn-elb.name}"
  auto_assign_elastic_ips   = true
  auto_assign_public_ips    = true
  stack_id                  = "${aws_opsworks_stack.test1.id}"
  custom_security_group_ids = ["${aws_security_group.openvpn-sg.id}", "${aws_security_group.secondary-sg-public.id}"]
  custom_deploy_recipes     = ["openvpn::install", "openvpn::server"]
}

# Creating ec2 instances for vpn servers

resource "aws_opsworks_instance" "openvpn1" {
  stack_id = "${aws_opsworks_stack.test1.id}"

  layer_ids = [
    "${aws_opsworks_custom_layer.openvpn.id}",
  ]

  ssh_key_name       = "${aws_key_pair.mykeypair.key_name}"
  instance_type      = "t2.micro"
  subnet_id          = "${aws_subnet.secondary-public-1.id}"
  security_group_ids = ["${aws_security_group.openvpn-sg.id}"]
  ami_id             = "ami-8b92b4ee"
  state              = "running"
}

resource "aws_opsworks_instance" "openvpn2" {
  stack_id  = "${aws_opsworks_stack.test1.id}"
  public_ip = "13.467.234.34"

  layer_ids = [
    "${aws_opsworks_custom_layer.openvpn.id}",
  ]

  ssh_key_name       = "${aws_key_pair.mykeypair.key_name}"
  instance_type      = "t2.micro"
  subnet_id          = "${aws_subnet.secondary-public-1.id}"
  security_group_ids = ["${aws_security_group.openvpn-sg.id}"]
  ami_id             = "ami-8b92b4ee"
  state              = "running"
}

resource "aws_eip" "one" {
  vpc = true
}

resource "aws_eip" "two" {
  vpc = true
}
