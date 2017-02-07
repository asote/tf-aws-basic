output "LBext_DNS" {
  value = "${aws_elb.web.dns_name}"
}

output "bastion_ip" {
  value = ["${aws_instance.bastion.public_ip}"]
}

output "webservers_ip" {
  value = ["${aws_instance.web.*.private_ip}"]
}

output "dbservers_ip" {
  value = ["${aws_instance.db.*.private_ip}"]
}
