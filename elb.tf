resource "aws_elb" "openvpn-elb" {
  name            = "openvpn-elb"
  subnets         = ["${aws_subnet.secondary-public-1.id}"]
  security_groups = ["${aws_security_group.secondary-sg-public.id}"]

  # access_logs {
  #   bucket        = "foo"
  #   bucket_prefix = "bar"
  #   interval      = 60
  # }

  listener {
    instance_port      = 443
    instance_protocol  = "https"
    lb_port            = 443
    lb_protocol        = "https"
    ssl_certificate_id = "arn:aws:iam::963984212387:server-certificate/MyCertificate"
  }
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/index.html"
    interval            = 30
  }
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400
  tags {
    Name = "openvpn-elb"
  }
}
