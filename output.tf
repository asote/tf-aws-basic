output "LBext_DNS" {
  value = "${aws_elb.web.dns_name}"
}
