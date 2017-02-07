output "LBext_DNS" {
  description = "Internet facing load balancer DNS name."
  value       = "${aws_elb.web.dns_name}"
}

output "bastion_ip" {
  description = "Bastion Hosts private IP address."
  value       = ["${aws_instance.bastion.public_ip}"]
}

output "webservers_ip" {
  description = " Web Servers IP addresses."
  value       = ["${aws_instance.web.*.private_ip}"]
}

output "dbservers_ip" {
  description = "DB Servers IP address."
  value       = ["${aws_instance.db.*.private_ip}"]
}
